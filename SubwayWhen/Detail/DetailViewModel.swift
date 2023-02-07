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

class DetailViewModel{
    // MODEL
    let detailModel = DetailModel()
    let loadModel = LoadModel()
    let headerViewModel = DetailTableHeaderViewModel()
    let arrivalCellModel = DetailTableArrivalCellModel()
    let scheduleCellModel = DetailTableScheduleCellModel()
    
    // INPUT
    let detailViewData = PublishRelay<MainTableViewCellData>()
    let exceptionLastStationRemoveReload = PublishRelay<Void>()
    
    // OUTPUT
    let cellData : Driver<[DetailTableViewSectionData]>
    let moreBtnClickData : Driver<DetailResultScheduleViewModel>
    let exceptionLastStationRemoveBtnClick : Driver<MainTableViewCellData>
    
    // DATA
    let nowData = BehaviorRelay<[DetailTableViewSectionData]>(value: [])
    let scheduleData = PublishRelay<[ResultSchdule]>()
    
    let bag = DisposeBag()
    
    init(){
        lazy var resultViewModel = DetailResultScheduleViewModel()
        
        self.cellData = self.nowData
            .asDriver(onErrorDriveWith: .empty())
        
        self.scheduleData
            .bind(to: self.scheduleCellModel.scheduleData)
            .disposed(by: self.bag)
        
        self.moreBtnClickData = self.scheduleCellModel.moreBtnClick
            .map{
                resultViewModel
            }
            .asDriver(onErrorDriveWith: .empty())
        
        self.scheduleCellModel.moreBtnClick
            .withLatestFrom(self.detailViewData)
            .bind(to: resultViewModel.cellData)
            .disposed(by: self.bag)
        
        self.scheduleCellModel.moreBtnClick
            .withLatestFrom(self.scheduleData)
            .bind(to: resultViewModel.scheduleData)
            .disposed(by: self.bag)
        
        // 제외 행 제거 클릭 시
        self.exceptionLastStationRemoveBtnClick = self.headerViewModel.exceptionLastStationBtnClick
            .withLatestFrom(self.detailViewData)
            .asDriver(onErrorDriveWith: .empty())
        
        self.exceptionLastStationRemoveReload
            .withLatestFrom(self.detailViewData)
            .map{
                var now = $0
                now.exceptionLastStation = ""
                return now
            }
            .bind(to: self.detailViewData)
            .disposed(by: self.bag)
        
        // 기본 셀 구성
        self.detailViewData
            .map{
                let backNext = self.detailModel.nextAndBackStationSearch(backId: $0.backStationId, nextId: $0.nextStationId)
                return [
                    DetailTableViewSectionData(sectionName: "", items: [DetailTableViewCellData(id: "Header", stationCode: $0.stationCode, exceptionLastStation: $0.exceptionLastStation, subWayId: $0.subWayId, upDown: $0.upDown, lineNumber: $0.lineNumber, useLine: $0.useLine, stationName: $0.stationName, backStationName: backNext[0], nextStationName: backNext[1])]),
                    DetailTableViewSectionData(sectionName: "실시간 현황", items:  [DetailTableViewCellData(id:  "Live", stationCode: $0.stationCode, exceptionLastStation: $0.exceptionLastStation, subWayId: $0.subWayId, upDown: $0.upDown, lineNumber: $0.lineNumber, useLine: $0.useLine, stationName: $0.stationName, backStationName: backNext[0], nextStationName: backNext[1])]),
                    DetailTableViewSectionData(sectionName: "시간표", items:  [DetailTableViewCellData(id:  "Schedule", stationCode: $0.stationCode, exceptionLastStation: $0.exceptionLastStation, subWayId: $0.subWayId, upDown: $0.upDown, lineNumber: $0.lineNumber, useLine: $0.useLine, stationName: $0.stationName, backStationName: backNext[0], nextStationName: backNext[1])])
                ]
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
        self.detailViewData
            .map{ item -> ScheduleSearch in
                var searchData = ScheduleSearch(stationCode: "", upDown: item.upDown, exceptionLastStation: item.exceptionLastStation, line: item.lineNumber, type: .Seoul)
                if item.stationCode.contains("K") || item.stationCode.contains("D") || item.stationCode.contains("A"){
                    searchData.stationCode = item.totalStationId
                    searchData.type = .Tago
                    return searchData
                }else{
                    searchData.stationCode = item.stationCode
                    
                    return searchData
                }
            }
            .flatMap{
                self.loadModel.totalScheduleStationLoad($0, isFirst: false, isNow: false)
            }
            .bind(to: self.scheduleData)
            .disposed(by: self.bag)
        
        
        // 실시간 새로고침 버튼 클릭 시
        let onRefresh = self.arrivalCellModel.refreshBtnClick
            .withLatestFrom(self.detailViewData)
        
        // 실시간 데이터 불러오기
        let realTimeData = onRefresh
            .flatMapLatest{
                self.loadModel.stationArrivalRequest(stationName: $0.stationName)
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
