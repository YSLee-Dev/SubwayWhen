//
//  TotalLoadModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/01.
//

import Foundation

import RxSwift
import RxOptional
import RxCocoa

class TotalLoadModel{
    var loadModel : LoadModelProtocol
    
    init(loadModel : LoadModelProtocol){
        self.loadModel = loadModel
    }
    
    // 지하철역 + live 지하철역 정보를 합쳐서 return
    func totalLiveDataLoad() -> Observable<MainTableViewCellData>{
        let saveStation = self.loadModel.saveStationLoad()
            .asObservable()
            .flatMap{ data -> Observable<SaveStation> in
                guard case .success(let value) = data else {return .never()}
                return Observable.from(value)
            }
            .share()
        
        let liveStation = saveStation
            .concatMap{[weak self] in
                self!.loadModel.stationArrivalRequest(stationName: $0.useStationName)
            }.map{ data -> LiveStationModel in
                guard case .success(let value) = data else {return .init(realtimeArrivalList: [RealtimeStationArrival(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "", subWayId: "", stationName: "", lastStation: "", lineNumber: "", isFast: "", backStationId: "", nextStationId: "", trainCode: "")])}
                return value
            }
        
        return Observable
            .zip(saveStation, liveStation){ station, data -> MainTableViewCellData in
                // 실시간 데이터가 없을 때
                var backId = ""
                var nextId = ""
                
                for x in data.realtimeArrivalList{
                    if station.lineCode == x.subWayId && station.updnLine == x.upDown && station.useStationName == x.stationName && !(station.exceptionLastStation.contains(x.lastStation)){
                        let code = x.previousStation != nil ? x.code : ""
                        backId = x.backStationId
                        nextId = x.nextStationId
                        
                        return .init(upDown: x.upDown, arrivalTime: x.arrivalTime, previousStation: x.previousStation ?? "", subPrevious: x.subPrevious, code: code, subWayId: x.subWayId, stationName: station.stationName, lastStation: "\(x.lastStation)행", lineNumber: station.line, isFast: x.isFast ?? "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation, type: .real, backStationId: x.backStationId, nextStationId: x.nextStationId,  korailCode: station.korailCode)
                    }else if station.lineCode == x.subWayId && station.updnLine == x.upDown && station.useStationName == x.stationName{
                        backId = x.backStationId
                        nextId = x.nextStationId
                    }
                }
                
                if station.lineCode != ""{
                    return .init(upDown: station.updnLine, arrivalTime: "", previousStation: "현재 실시간 열차 데이터가 없어요.", subPrevious: "", code: "", subWayId: "", stationName: station.stationName, lastStation: "\(station.exceptionLastStation)행 제외", lineNumber: station.line, isFast: "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation, type: .real, backStationId: backId, nextStationId: nextId, korailCode: station.korailCode)
                }else{
                    return .init(upDown: "", arrivalTime: "", previousStation: "지원하지 않는 호선이에요.", subPrevious: "", code: "", subWayId: "", stationName: station.stationName, lastStation: "", lineNumber: station.line, isFast: "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation, type: .real, backStationId: "", nextStationId: "",  korailCode: station.korailCode)
                }
            }
            .asObservable()
    }
    
    // total 지하철 시간표
    func totalScheduleStationLoad(_ scheduleSearch : ScheduleSearch, isFirst : Bool, isNow : Bool) -> Observable<[ResultSchdule]>{
        guard let now = Int(self.timeFormatter(date: Date())) else {return .empty()}
        
        if scheduleSearch.type == .Tago{
            let schedule = self.loadModel.TagoStationSchduleLoad(scheduleSearch)
                .map{ data -> [TagoItem] in
                    // success 되지 않으면 > 오류 발생 시
                    guard case .success(let value) = data else {return []}
                    return value.response.body.items.item
                }
                .asObservable()
            
            print("Tago")
            
            return schedule.map{ data -> [TagoItem] in
                let scheduleData = data.filter{
                    guard let scheduleTime = Int($0.arrTime.components(separatedBy: ":").joined()) else {return false}
                    
                    if isNow{
                        if now <= scheduleTime && !(scheduleSearch.exceptionLastStation.contains($0.endSubwayStationNm ?? "")){
                            return true
                        }else{
                            return false
                        }
                    }else{
                        if !(scheduleSearch.exceptionLastStation.contains($0.endSubwayStationNm ?? "")){
                            return true
                        }else{
                            return false
                        }
                    }
                   
                }
                
                if isFirst{
                    guard let first = scheduleData.first else {return []}
                    return [first]
                }else{
                    return scheduleData
                }
                
            }
            .map{ list in
                if list.isEmpty{
                    return [ResultSchdule(startTime: "정보없음", type: .Tago, lastStation:"정보없음")]
                }else{
                    return list.map{
                        ResultSchdule(startTime: $0.arrTime, type: .Tago, lastStation: $0.endSubwayStationNm ?? "")
                    }
                }
                
            }
        }else{
            var inOut = ""
            
            // 9호선은 상하행이 반대
            if scheduleSearch.line == "09호선"{
                inOut = scheduleSearch.upDown.contains("상행") ? "2" : "1"
            }else{
                inOut = scheduleSearch.upDown.contains("상행") || scheduleSearch.upDown.contains("내선") ? "1" : "2"
            }
            
            guard let now = Int(self.timeFormatter(date: Date())) else {return .empty()}
            
            let schedule = self.loadModel.seoulStationScheduleLoad(scheduleSearch: scheduleSearch)
                .map{ data -> [ScheduleStationArrival] in
                    // success 되지 않으면 > 오류 발생 시
                    guard case .success(let value) = data else {return []}
                    return value.SearchSTNTimeTableByFRCodeService.row
                }
                .asObservable()
            
            print("SEOUL")
            
            return schedule.map{ data -> [ScheduleStationArrival] in
                let scheduleData = data.filter{
                    guard let scheduleTime = Int($0.startTime.components(separatedBy: ":").joined()) else {return false}
                    
                    if isNow{
                        if scheduleSearch.stationCode == $0.stationCode && now <= scheduleTime && inOut == $0.upDown && !(scheduleSearch.exceptionLastStation.contains($0.lastStation)){
                            return true
                        }else{
                            return false
                        }
                    }else{
                        if scheduleSearch.stationCode == $0.stationCode && inOut == $0.upDown && !(scheduleSearch.exceptionLastStation.contains($0.lastStation)){
                            return true
                        }else{
                            return false
                        }
                    }
                    
                }
                
                if isFirst{
                    guard let first = scheduleData.first else {return []}
                    return [first]
                }else{
                    return scheduleData
                }
            }
            .map{ list in
                if list.isEmpty{
                    return [ResultSchdule(startTime: "정보없음", type: .Seoul, lastStation: "정보없음")]
                }else{
                    return list.map{
                        ResultSchdule(startTime: $0.startTime, type: .Seoul, lastStation: $0.lastStation)
                    }
                }
            }
        }
    }
    
    private func timeFormatter(date : Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmmss"
        return formatter.string(from: date)
    }
}
