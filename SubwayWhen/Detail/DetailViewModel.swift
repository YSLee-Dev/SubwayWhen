//
//  DetailViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/02.
//

import Foundation

import RxSwift
import RxCocoa

class DetailViewModel{
    // MODEL
    let detailModel = DetailModel()
    let loadModel = LoadModel()
    let arrivalCellModel = DetailTableArrivalCellModel()
    
    // INPUT
    let detailViewData = PublishRelay<MainTableViewCellData>()
    
    // OUTPUT
    let cellData : Driver<[DetailTableViewSectionData]>
    
    // DATA
    let nowData = PublishRelay<[DetailTableViewSectionData]>()
    
    let bag = DisposeBag()
    
    init(){
        self.cellData = self.nowData
            .asDriver(onErrorDriveWith: .empty())
        
        self.detailViewData
            .map{
                let backNext = self.detailModel.nextAndBackStationSearch(backId: $0.backStationId, nextId: $0.nextStationId)
                return [
                    DetailTableViewSectionData(sectionName: "", items: [DetailTableViewCellData(id: $0.id, stationCode: $0.stationCode, exceptionLastStation: $0.exceptionLastStation, subWayId: $0.subWayId, upDown: $0.upDown, lineNumber: $0.lineNumber, useLine: $0.useLine, stationName: $0.stationName, backStationName: backNext[0], nextStationName: backNext[1])]),
                    DetailTableViewSectionData(sectionName: "실시간 현황", items:  [DetailTableViewCellData(id: $0.id, stationCode: $0.stationCode, exceptionLastStation: $0.exceptionLastStation, subWayId: $0.subWayId, upDown: $0.upDown, lineNumber: $0.lineNumber, useLine: $0.useLine, stationName: $0.stationName, backStationName: backNext[0], nextStationName: backNext[1])]),
                    DetailTableViewSectionData(sectionName: "시간표", items:  [DetailTableViewCellData(id: $0.id, stationCode: $0.stationCode, exceptionLastStation: $0.exceptionLastStation, subWayId: $0.subWayId, upDown: $0.upDown, lineNumber: $0.lineNumber, useLine: $0.useLine, stationName: $0.stationName, backStationName: backNext[0], nextStationName: backNext[1])])
                ]
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
        let onRefresh = self.arrivalCellModel.refreshBtnClick
            .withLatestFrom(self.detailViewData)
        
        let realTimeData = onRefresh
            .flatMapLatest{
                self.loadModel.stationArrivalRequest(stationName: $0.stationName)
            }
            .map{ data -> [RealtimeStationArrival] in
                guard case .success(let value) = data else {return []}
                return value.realtimeArrivalList
            }
            .filter{!$0.isEmpty}
        
        Observable.combineLatest(self.detailViewData, realTimeData){station, realTime -> [RealtimeStationArrival] in
            var list = [RealtimeStationArrival(upDown: station.upDown, arrivalTime: "", previousStation: "현재 실시간 열차 데이터가 없어요.", subPrevious: "", code: station.code, subWayId: station.subWayId, stationName: station.stationName, lastStation: "\(station.exceptionLastStation)행 제외", lineNumber: station.lineNumber, isFast: "", backStationId: station.backStationId, nextStationId: station.nextStationId, trainCode: "")]
            
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
        }
        .bind(to: self.arrivalCellModel.realTimeData)
        .disposed(by: self.bag)
        
    }
}
