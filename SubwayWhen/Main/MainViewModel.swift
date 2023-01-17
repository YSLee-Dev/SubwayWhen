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
    let model = LoadModel()
    let mainTableViewModel = MainTableViewModel()
    let groupViewModel = GroupViewModel()
    
    let bag = DisposeBag()
    
    // 현재 데이터
    private let groupData = BehaviorRelay<[MainTableViewSection]>(value: [MainTableViewSection(section: "", stationID: "", items: [])])
    private let totalData = BehaviorRelay<[MainTableViewSection]>(value: [MainTableViewSection(section: "", stationID: "", items: [])])
    
    // INPUT
    let reloadData = PublishRelay<Void>()
    
    // OUTPUT
    let stationPlusBtnClick : Driver<Void>
    let editBtnClick : Driver<Void>
    let clickCellData : Driver<MainTableViewCellData>
    
    init(){
        // footer 버튼 클릭 시
        self.stationPlusBtnClick = self.mainTableViewModel.mainTableViewFooterViewModel.plusBtnClick
            .asDriver(onErrorDriveWith: .empty())
        
        // edit 버튼 클릭 시
        self.editBtnClick = self.mainTableViewModel.mainTableViewFooterViewModel.editBtnClick
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
                    }else if 8...9 ~= nowHour{
                        return 10
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
        
        // 데이터 리프레쉬 할 때 데이터 삭제(세션 값이 같으면 오류 발생)
        dataReload
            .map{ _ in
                var value = self.totalData.value
                value.removeAll()
                return value
            }
            .bind(to: self.totalData)
            .disposed(by: self.bag)
        
        // 지하철 데이터를 하나 씩 받음, 기존 total데이터를 받아, 배열 형태에 추가한 후 totalData에 전달
        dataReload
            .flatMap{
               self.model.totalLiveDataLoad()
            }
            .map{
                var now = self.totalData.value
                now.append($0)
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
        Observable.combineLatest(self.totalData, self.groupViewModel.groupSeleted){ data, group in
            return data.filter{
                $0.section == group.rawValue
            }
        }
       .bind(to: self.groupData)
       .disposed(by: self.bag)
        
        self.groupData
            .bind(to: self.mainTableViewModel.resultData)
            .disposed(by: self.bag)
        
        // 시간표 불러오기
        let clickCellRow = self.mainTableViewModel.mainTableViewCellModel.cellTimeChangeBtnClick
            .withLatestFrom(self.groupData){ id, data in
                data[id.section].items[id.row]
            }
        
        let scheduleData = clickCellRow
            .map{ item -> ScheduleSearch? in
                if item.type == .real{
                    if item.stationCode.contains("K") || item.stationCode.contains("D") || item.stationCode.contains("A"){
                        return ScheduleSearch(stationCode: item.totalStationId, upDown: item.upDown, exceptionLastStation: item.exceptionLastStation, line: item.lineNumber, type: .Tago)
                    }else{
                        return ScheduleSearch(stationCode: item.stationCode, upDown: item.upDown, exceptionLastStation: item.exceptionLastStation, line: item.lineNumber, type: .Seoul)
                    }
                }else{
                    return nil
                }
            }
            .filterNil()
            
        let scheduleTotalData = scheduleData
            .flatMap{
                if $0.type == .Tago{
                    return self.model.nowScheduleStationLoad($0, type: .Tago, count: 1, isNow: true)
                }else{
                    return self.model.nowScheduleStationLoad($0, type: .Seoul, count: 1, isNow: true)
                }
            }
        
        scheduleTotalData
            .withLatestFrom(self.mainTableViewModel.mainTableViewCellModel.cellTimeChangeBtnClick){ scheduleData, index -> [MainTableViewSection] in
                guard let data = scheduleData.first else {return []}
                let nowData = self.groupData.value[index.section].items[index.row]
                let newData = MainTableViewCellData(upDown: nowData.upDown, arrivalTime: data.useArrTime, previousStation: "⏱️\(data.useArrTime)", subPrevious: "\(data.useTime)", code: "", subWayId: nowData.subWayId, stationName: nowData.stationName, lastStation: "\(data.lastStation)행", lineNumber: nowData.lineNumber, isFast: "", useLine: nowData.useLine, group: nowData.group, id: nowData.id, stationCode: nowData.stationCode, exceptionLastStation: nowData.exceptionLastStation, type: .schedule, backStationId: nowData.backStationId, nextStationId: nowData.nextStationId, totalStationId: nowData.totalStationId)
               
                var now = self.groupData.value
                now[index.section].items[index.row] = newData
                return now
            }
            .filterEmpty()
            .bind(to: self.groupData)
            .disposed(by: self.bag)
        
    }
}
