//
//  DetailViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/02.
//

import Foundation

import RxSwift
import RxCocoa
import RxOptional

typealias schduleResultData = (scheduleData : [ResultSchdule], cellData: MainTableViewCellData)

class DetailViewModel{
    // MODEL
    let loadModel : TotalLoadModel
    let model : LoadModel
    
    let detailModel = DetailModel()
    let headerViewModel = DetailTableHeaderViewModel()
    let arrivalCellModel = DetailTableArrivalCellModel()
    let scheduleCellModel = DetailTableScheduleCellModel()
    
    // INPUT
    let detailViewData = BehaviorRelay<MainTableViewCellData>(value: .init(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "지원하지 않는 호선이에요.", subWayId: "", stationName: "", lastStation: "", lineNumber: "", isFast: "", useLine: "", group: "", id: "", stationCode: "", exceptionLastStation: "", type: .real, backStationId: "", nextStationId: "",  korailCode: ""))
    let exceptionLastStationRemoveReload = PublishRelay<Void>()
    
    // OUTPUT
    let cellData : Driver<[DetailTableViewSectionData]>
    let moreBtnClickData : Driver<schduleResultData>
    let exceptionLastStationRemoveBtnClick : Driver<MainTableViewCellData>
    
    // DATA
    let nowData = BehaviorRelay<[DetailTableViewSectionData]>(value: [])
    let scheduleData = PublishRelay<[ResultSchdule]>()
    
    var bag = DisposeBag()
    var timerBag = DisposeBag()
    
    deinit{
        print("DetailViewModel DEINIT")
    }
    
    init(loadModel : LoadModel = .init()){
        // Model Init
        self.loadModel = TotalLoadModel(loadModel: loadModel)
        self.model = loadModel
        
        self.cellData = self.nowData
            .asDriver(onErrorDriveWith: .empty())
        
        self.scheduleData
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: self.scheduleCellModel.scheduleData)
            .disposed(by: self.bag)
        
        let showData = self.scheduleData
            .withLatestFrom(self.detailViewData){ schedule, cell -> schduleResultData in
                schduleResultData(scheduleData: schedule, cellData: cell)
            }
        
        self.moreBtnClickData = self.scheduleCellModel.moreBtnClick
            .withLatestFrom(showData)
            .map{ data -> schduleResultData? in
                if data.scheduleData.first?.startTime == "정보없음" || data.scheduleData.isEmpty{
                    return nil
                }else{
                    return data
                }
            }
            .filterNil()
            .asDriver(onErrorDriveWith: .empty())
        
        self.exceptionLastStationRemoveBtnClick = self.headerViewModel.exceptionLastStationBtnClick
            .withLatestFrom(self.detailViewData)
            .asDriver(onErrorDriveWith: .empty())
        
        // 재로딩 버튼 클릭 시 exception Station 제거
        self.exceptionLastStationRemoveReload
            .withLatestFrom(self.detailViewData)
            .map{
                var now = $0
                now.exceptionLastStation = ""
                return now
            }
            .bind(to: self.detailViewData)
            .disposed(by: self.bag)
        
        // 15초 타이머 초기화
        self.exceptionLastStationRemoveReload
            .withUnretained(self)
            .subscribe(onNext:{ viewModel, _ in
                viewModel.timerBag = DisposeBag()
            })
            .disposed(by: self.bag)
        
        // 15초 타이머 / 처음에만 / 설정 값이 켜져있을때만
        if FixInfo.saveSetting.detailAutoReload{
            Observable<Int>.timer(.seconds(1),period: .seconds(1), scheduler: MainScheduler.instance)
                .bind(to: self.arrivalCellModel.superTimer)
                .disposed(by: self.timerBag)
        }
        
        // 기본 셀 구성
        self.detailViewData
            .withUnretained(self)
            .map{
                let backNext = $0.detailModel.nextAndBackStationSearch(backId: $1.backStationId, nextId: $1.nextStationId)
                var stationNameCut = ""
                
                if $1.stationName.count >= 6{
                    stationNameCut = "\(String($1.stationName[$1.stationName.startIndex ... $1.stationName.index($1.stationName.startIndex, offsetBy: 5)])).."
                }else{
                    stationNameCut = $1.stationName
                }
                
                return [
                    DetailTableViewSectionData(sectionName: "", items: [DetailTableViewCellData(id: "Header", stationCode: $1.stationCode, exceptionLastStation: $1.exceptionLastStation, subWayId: $1.subWayId, upDown: $1.upDown, lineNumber: $1.lineNumber, useLine: $1.useLine, stationName: stationNameCut, backStationName: backNext[0], nextStationName: backNext[1])]),
                    DetailTableViewSectionData(sectionName: "실시간 현황", items:  [DetailTableViewCellData(id:  "Live", stationCode: $1.stationCode, exceptionLastStation: $1.exceptionLastStation, subWayId: $1.subWayId, upDown: $1.upDown, lineNumber: $1.lineNumber, useLine: $1.useLine, stationName: stationNameCut, backStationName: backNext[0], nextStationName: backNext[1])]),
                    DetailTableViewSectionData(sectionName: "시간표", items:  [DetailTableViewCellData(id:  "Schedule", stationCode: $1.stationCode, exceptionLastStation: $1.exceptionLastStation, subWayId: $1.subWayId, upDown: $1.upDown, lineNumber: $1.lineNumber, useLine: $1.useLine, stationName: stationNameCut, backStationName: backNext[0], nextStationName: backNext[1])])
                ]
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
        self.detailViewData
            .map{ item -> ScheduleSearch in
                var searchData = ScheduleSearch(stationCode: item.stationCode, upDown: item.upDown, exceptionLastStation: item.exceptionLastStation, line: item.lineNumber, type: .Seoul, korailCode: item.korailCode)
                
                if item.stationCode.contains("K") || item.stationCode.contains("D") || item.stationCode.contains("A"){
                    searchData.type = .Korail
                    
                    return searchData
                }else{
                    return searchData
                }
            }
            .withUnretained(self)
            .skip(1)
            .flatMap{
                $0.loadModel.totalScheduleStationLoad($1, isFirst: false, isNow: false)
            }
            .bind(to: self.scheduleData)
            .disposed(by: self.bag)
        
        // 실시간 새로고침 버튼 클릭 시
        let onRefresh = self.arrivalCellModel.refreshBtnClick
            .withLatestFrom(self.detailViewData)
        
        // 실시간 데이터 불러오기
        let realTimeData = onRefresh
            .withUnretained(self)
            .flatMapLatest{
                $0.model.stationArrivalRequest(stationName: $1.stationName)
            }
            .map{ data -> [RealtimeStationArrival] in
                /*
                #if DEBUG
                let debugData = RealtimeStationArrival(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "", subWayId: "123", stationName: "", lastStation: "", lineNumber: "", isFast: "", backStationId: "", nextStationId: "", trainCode: "")
                return [debugData]
                #else
                 */
                guard case .success(let value) = data else {return []}
                return value.realtimeArrivalList
                //#endif
              
            }
            .filter{!$0.isEmpty}
        
        Observable.combineLatest(self.detailViewData, realTimeData){station, realTime -> [RealtimeStationArrival] in
            var list = [RealtimeStationArrival(upDown: station.upDown, arrivalTime: "", previousStation: "현재 실시간 열차 데이터가 없어요.", subPrevious: "", code: station.code, subWayId: station.subWayId, stationName: station.stationName, lastStation: "\(station.exceptionLastStation)행 제외", lineNumber: station.lineNumber, isFast: "", backStationId: station.backStationId, nextStationId: station.nextStationId, trainCode: "")]
            /*
            #if DEBUG
            list.insert(RealtimeStationArrival(upDown: station.upDown, arrivalTime: "1분", previousStation: "station2", subPrevious: "station2", code: "3", subWayId: station.subWayId, stationName: station.stationName, lastStation: "\(station.exceptionLastStation)행 제외", lineNumber: station.lineNumber, isFast: "", backStationId: station.backStationId, nextStationId: station.nextStationId, trainCode: ""),at : 0)
            return list
            #else
             */
            for x in realTime{
                if station.upDown == x.upDown && station.subWayId == x.subWayId && !(station.exceptionLastStation.contains(x.lastStation)){
                    if list.count == 1{
                        list.insert(x, at: 0)
                    }else if list.count == 2{
                        list.insert(x, at: 1)
                        list.removeLast()
                        return list
                    }
                }
            }
            
            return list
            // #endif
        }
        .bind(to: self.arrivalCellModel.realTimeData)
        .disposed(by: self.bag)
        
    }
}