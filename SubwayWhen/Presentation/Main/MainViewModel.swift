//
//  MainViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/30.
//

import Foundation

import RxSwift
import RxCocoa
import RxOptional

class MainViewModel{
    // MODEL
    let model : TotalLoadModel
    let mainTableViewModel = MainTableViewModel()
    
    let bag = DisposeBag()
    
    // 현재 데이터
    private let groupData = BehaviorRelay<[MainTableViewCellData]>(value: [])
    private let totalData = BehaviorRelay<[MainTableViewCellData]>(value: [])
    
    // INPUT
    let reloadData = PublishRelay<Void>()
    
    // OUTPUT
    let reportBtnClick : Driver<Void>
    let stationPlusBtnClick : Driver<Void>
    let editBtnClick : Driver<Void>
    let clickCellData : Driver<MainTableViewCellData>
    let mainTitle : Driver<String>
    let mainTitleHidden : Driver<Void>
    
    init(loadModel : LoadModel = .init()){
        // Model Init
        self.model = TotalLoadModel(loadModel: loadModel)
        
        // 메인 타이틀(요일마다 변경)
        self.mainTitle = Observable<String>.create{
            let data = Calendar.current.component(.weekday, from: Date())
            if data == 1 || data == 7{
                // 주말
                let weekend = ["행복하고 즐거운 주말\n좋은 하루 보내세요!",
                "행복한 일만 가득한 주말\n행복한 주말 보내세요!",
                               ]
                $0.onNext(weekend.randomElement() ?? "행복하고 즐거운 주말이에요!\n좋은 하루 보내세요!")
            }else if data == 2{
                // 월요일
                $0.onNext("월요일,\n한 주도 화이팅해봐요!")
            }else if data == 3{
                // 화요일
                $0.onNext("화요일,\n평범하지만 행복한 날로 만들어봐요!")
            }else if data == 4{
                // 수요일
                $0.onNext("수요일, \n수많은 즐거움이 가득할거에요!")
            }else if data == 5{
                // 목요일
                $0.onNext("목요일,\n주말까지 단 2일 남았어요!")
            }else if data == 6{
                // 금요일
                $0.onNext("금요일,\n행복한 하루 보내세요!")
            }
            $0.onCompleted()
            
            return Disposables.create()
        }
        .asDriver(onErrorDriveWith: .empty())
        
        // 민원 버튼 클릭 시
        self.reportBtnClick = self.mainTableViewModel.mainTableViewHeaderViewModel.reportBtnClick
            .asDriver(onErrorDriveWith: .empty())
        
        // 검색,플러스 버튼 클릭 시
        self.stationPlusBtnClick = self.mainTableViewModel.plusBtnClick
            .asDriver(onErrorDriveWith: .empty())
        
        // edit 버튼 클릭 시
        self.editBtnClick = self.mainTableViewModel.mainTableViewHeaderViewModel.editBtnClick
            .asDriver(onErrorDriveWith: .empty())
        
        // 그룹 변경 시 타이틀 제거
        self.mainTitleHidden = self.mainTableViewModel.mainTableViewGroupModel.groupSeleted
            .map{_ in Void()}
            .asDriver(onErrorDriveWith: .empty())
        
        // 셀 클릭 시
        self.clickCellData = self.mainTableViewModel.cellClick
            .asDriver(onErrorDriveWith: .empty())
        
        // 혼잡도 set
        let mainHeader = Observable.just(1)
            .map{ _ in
                let nowHour = Calendar.current.component(.hour, from: Date())
                let week =  Calendar.current.component(.weekday, from: Date())
            
                if week == 1 || week == 7{
                    return 5
                }else{
                    if 1...5 ~= nowHour {
                        return 1
                    }else if 6 == nowHour{
                        return 4
                    }else if 7 == nowHour{
                        return 6
                    }else if 8 == nowHour{
                        return 10
                    }else if 9 == nowHour{
                        return 7
                    }else if 10 == nowHour{
                        return 6
                    }else if 11...16 ~= nowHour{
                        return 4
                    }else if 17 == nowHour{
                        return 5
                    }else if 18 == nowHour{
                        return 7
                    }else if 19...22 ~= nowHour{
                        return 5
                    }else if 23 == nowHour{
                        return 3
                    }else {
                        return 1
                    }
                }
            }
          
        mainHeader
            .bind(to: self.mainTableViewModel.mainTableViewHeaderViewModel.congestionData)
            .disposed(by: self.bag)
        
        // 데이터 리로드 할 때(메인VC 데이터 리로드는 2초에 한번으로 제한)
        let dataReload = Observable
            .merge(self.reloadData.asObservable()
                .throttle(.seconds(2), latest: false ,scheduler: MainScheduler.instance),
                   self.mainTableViewModel.refreshOn.asObservable()
            )
            .share()
        
        dataReload
            .map{ _ -> SaveStationGroup? in
                let nowHour = Calendar.current.component(.hour, from: Date())
                
                let groupOne = Int(FixInfo.saveSetting.mainGroupOneTime)
                let groupTwo = Int(FixInfo.saveSetting.mainGroupTwoTime)
                
                if FixInfo.saveSetting.mainGroupOneTime == 0 && FixInfo.saveSetting.mainGroupTwoTime == 0{
                    return nil
                }else if groupOne < groupTwo{
                    if groupTwo <= nowHour{
                        return .two
                    }else if groupOne <= nowHour{
                        return .one
                    }else {
                        return nil
                    }
                }else if groupOne > groupTwo{
                    if groupOne <= nowHour{
                        return .one
                    }else if groupTwo <= nowHour{
                        return .two
                    }else {
                        return nil
                    }
                }else{
                    return nil
                }
            }
            .filterNil()
            .delay(.milliseconds(150), scheduler: MainScheduler.instance)
            .bind(to: self.mainTableViewModel.mainTableViewGroupModel.groupSeleted)
            .disposed(by: self.bag)
        
        // 데이터 리프레쉬 할 때 데이터 삭제(세션 값이 같으면 오류 발생)
        dataReload
            .withUnretained(self)
            .map{ viewModel, _ in
                var value = viewModel.totalData.value
                value.removeAll()
                return value
            }
            .bind(to: self.totalData)
            .disposed(by: self.bag)
        
        // 지하철 데이터를 하나 씩 받음, 기존 total데이터를 받아, 배열 형태에 추가한 후 totalData에 전달
        dataReload
            .withUnretained(self)
            .flatMap{ viewModel, _ in
                viewModel.model.totalLiveDataLoad(stations: FixInfo.saveStation)
            }
            .withUnretained(self)
            .map{viewModel, data in
                var now = viewModel.totalData.value
                now.append(data)
                return now
            }
            .bind(to: self.totalData)
            .disposed(by: self.bag)
        
        // 데이터, 업데이트 시 메인 헤더도 업데이트
        dataReload
            .flatMap{
                mainHeader
            }
            .bind(to: self.mainTableViewModel.mainTableViewHeaderViewModel.congestionData)
            .disposed(by: self.bag)
        
        
        // 모든 데이터를 받은 후 그룹에 맞춰서 return
        Observable.combineLatest(self.totalData, self.mainTableViewModel.mainTableViewGroupModel.groupSeleted){ data, group in
            return data.filter{
                $0.group == group.rawValue
            }
        }
       .bind(to: self.groupData)
       .disposed(by: self.bag)
        
        self.groupData
            .map{data -> [MainTableViewSection]in
                let header = MainTableViewSection(id : "header", sectionName: "", items: [.init(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "", subWayId: "", stationName: "header", lastStation: "", lineNumber: "", isFast: "", useLine: "", group: "", id: "header", stationCode: "", exceptionLastStation: "", type: .real, backStationId: "", nextStationId: "",  korailCode: "")])
                let group = MainTableViewSection(id : "group", sectionName: "실시간 현황", items: [.init(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "", subWayId: "", stationName: "group", lastStation: "", lineNumber: "", isFast: "", useLine: "", group: "", id: "group", stationCode: "", exceptionLastStation: "", type: .real, backStationId: "", nextStationId: "", korailCode: "")])
                
                var groupData = MainTableViewSection(id: "live", sectionName: "", items: [])
                
                if data.isEmpty{
                    groupData.items = [.init(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "", subWayId: "", stationName: "", lastStation: "", lineNumber: "", isFast: "", useLine: "", group: "", id: "NoData", stationCode: "", exceptionLastStation: "", type: .real, backStationId: "", nextStationId: "", korailCode: "")]
                }else{
                    groupData.items = data
                }
                
                return [header,group,groupData]
            }
            .bind(to: self.mainTableViewModel.resultData)
            .disposed(by: self.bag)
        
        // 시간표 불러오기
        let clickCellRow = self.mainTableViewModel.mainTableViewCellModel.cellTimeChangeBtnClick
            .withLatestFrom(self.groupData){ id, data in
                data[id.row]
            }
        
        let scheduleData = clickCellRow
            .map{ item -> ScheduleSearch? in
                if item.type == .real{
                    if item.stationCode.contains("K") || item.stationCode.contains("D") || item.stationCode.contains("A"){
                        return ScheduleSearch(stationCode: item.stationCode, upDown: item.upDown, exceptionLastStation: item.exceptionLastStation, line: item.lineNumber, type: .Korail, korailCode: item.korailCode)
                    }else{
                        return ScheduleSearch(stationCode: item.stationCode, upDown: item.upDown, exceptionLastStation: item.exceptionLastStation, line: item.lineNumber, type: .Seoul, korailCode: item.korailCode)
                    }
                }else{
                    return nil
                }
            }
            .filterNil()
            
        let scheduleTotalData = scheduleData
            .withUnretained(self)
            .flatMap{viewModel, data in
                viewModel.model.totalScheduleStationLoad(data, isFirst: true, isNow: true)
            }
        
        scheduleTotalData
            .withLatestFrom(self.mainTableViewModel.mainTableViewCellModel.cellTimeChangeBtnClick){[weak self] scheduleData, index -> [MainTableViewCellData] in
                guard let data = scheduleData.first else {return []}
                guard let nowData = self?.groupData.value[index.row] else {return []}
                let newData = MainTableViewCellData(upDown: nowData.upDown, arrivalTime: data.useArrTime, previousStation: "", subPrevious: "\(data.useTime)", code: "⏱️\(data.useArrTime)", subWayId: nowData.subWayId, stationName: nowData.stationName, lastStation: "\(data.lastStation)행", lineNumber: nowData.lineNumber, isFast: "", useLine: nowData.useLine, group: nowData.group, id: nowData.id, stationCode: nowData.stationCode, exceptionLastStation: nowData.exceptionLastStation, type: .schedule, backStationId: nowData.backStationId, nextStationId: nowData.nextStationId, korailCode: nowData.korailCode)
               
                guard var now = self?.groupData.value else {return []}
                now[index.row] = newData
                return now
            }
            .filterEmpty()
            .bind(to: self.groupData)
            .disposed(by: self.bag)
        
    }
}
