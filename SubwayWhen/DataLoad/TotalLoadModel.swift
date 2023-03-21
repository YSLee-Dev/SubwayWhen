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

class TotalLoadModel : TotalLoadProtocol{
    private var loadModel : LoadModelProtocol
    
    init(loadModel : LoadModel = .init()){
        self.loadModel = loadModel
    }
    
    // 지하철역 + live 지하철역 정보를 합쳐서 return
    func totalLiveDataLoad(stations : [SaveStation]) -> Observable<MainTableViewCellData>{
        let saveStation = Observable.from(stations)
        
        let liveStation = saveStation
            .concatMap{[weak self] in
                self!.loadModel.stationArrivalRequest(stationName: $0.stationName)
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
                    if station.lineCode == x.subWayId && station.updnLine == x.upDown && station.stationName == x.stationName && !(station.exceptionLastStation.contains(x.lastStation)){
                        let code = x.previousStation != nil ? x.code : ""
                        backId = x.backStationId
                        nextId = x.nextStationId
                        
                        return .init(upDown: x.upDown, arrivalTime: x.arrivalTime, previousStation: x.previousStation ?? "", subPrevious: x.subPrevious, code: code, subWayId: station.lineCode, stationName: station.stationName, lastStation: "\(x.lastStation)행", lineNumber: station.line, isFast: x.isFast ?? "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation, type: .real, backStationId: x.backStationId, nextStationId: x.nextStationId,  korailCode: station.korailCode)
                    }else if station.lineCode == x.subWayId && station.updnLine == x.upDown && station.stationName == x.stationName{
                        backId = x.backStationId
                        nextId = x.nextStationId
                    }
                }
                
                if station.lineCode != ""{
                    return .init(upDown: station.updnLine, arrivalTime: "", previousStation: "", subPrevious: "", code: "현재 실시간 열차 데이터가 없어요.", subWayId: station.lineCode, stationName: station.stationName, lastStation: "\(station.exceptionLastStation)행 제외", lineNumber: station.line, isFast: "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation, type: .real, backStationId: backId, nextStationId: nextId, korailCode: station.korailCode)
                }else{
                    return .init(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "지원하지 않는 호선이에요.", subWayId: station.lineCode, stationName: station.stationName, lastStation: "", lineNumber: station.line, isFast: "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation, type: .real, backStationId: "", nextStationId: "",  korailCode: station.korailCode)
                }
            }
            .asObservable()
    }
    
    // live 정보만 반환
    func singleLiveDataLoad(station: String) -> Observable<LiveStationModel> {
        self.loadModel.stationArrivalRequest(stationName: station)
            .map{ data -> LiveStationModel in
                guard case .success(let value) = data else {return .init(realtimeArrivalList: [RealtimeStationArrival(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "현재 실시간 열차 데이터가 없어요.", subWayId: "", stationName: "\(station)", lastStation: "", lineNumber: "", isFast: "", backStationId: "", nextStationId: "", trainCode: "")])}
                return value
            }
            .asObservable()
    }
    
    // 코레일 시간표 계산
    func korailSchduleLoad(scheduleSearch : ScheduleSearch, isFirst : Bool, isNow : Bool) ->  Observable<[ResultSchdule]>{
        guard let now = Int(self.timeFormatter(date: Date())) else {return .empty()}
        
        let requestRry = BehaviorSubject<Void>(value: Void())
        var searchInfo = scheduleSearch
        
        let number = self.loadModel.korailTrainNumberLoad()
        let request = requestRry
            .flatMap{[weak self] _ in
                self?.loadModel.korailSchduleLoad(scheduleSearch: searchInfo) ?? .never()
            }
            .asObservable()
        
        let success = request
            .map{data -> [KorailScdule] in
                guard case .success(let value) = data else {
                    searchInfo.stationCode = searchInfo.stationCode.lowercased()
                    requestRry.onNext(Void())
                    requestRry.onCompleted()
                    return []
                }
                requestRry.onCompleted()
                return value.body
            }
        
        // 상하행 구분 / 짝수일 경우 상행, 홀수일 경우 하행
        let updownCheck = success.map{data in
            return data.filter{
                let updownRequest = Int(String($0.trainCode.last ?? "9")) ?? 9
                if updownRequest % 2 == 0{
                    return scheduleSearch.upDown == "상행" ? true : false
                }else{
                    return scheduleSearch.upDown == "하행" ? true : false
                }
            }
        }
        
        let schedule = Observable<[ResultSchdule]>.combineLatest(number, updownCheck){number, updownCheck -> [ResultSchdule] in
            var result : [ResultSchdule] = []
            
            // lastStation 값 주입
            for r in updownCheck.enumerated(){
                if r.element.stationId == searchInfo.stationCode{
                    result.append(ResultSchdule.init(startTime: r.element.time, type: .Korail, isFast: "", startStation: "", lastStation: ""))
                    for n in number{
                        if r.element.trainCode == n.trainNumber{
                            result[r.offset].lastStation = n.endStation
                            result[r.offset].startStation = n.startStation
                            result[r.offset].isFast = n.isFast == "급행" ? "급행" : ""
                            break
                        }
                    }
                }
            }
            
            return result
                .sorted{
                    let one = Int($0.startTime) ?? 0
                    let two = Int($1.startTime) ?? 1
                    
                    return one<two
                }
        }
        
        let filterData = schedule.map{ data in
            data.filter{
                if isNow{
                    if now <= Int($0.startTime) ?? 0 && !(scheduleSearch.exceptionLastStation.contains($0.lastStation)){
                        return true
                    }else{
                        return false
                    }
                }else{
                    if !(scheduleSearch.exceptionLastStation.contains($0.lastStation)){
                        return true
                    }else{
                        return false
                    }
                }
            }
        }
        
        return filterData
            .map{ list in
                if list.isEmpty{
                    return [ResultSchdule(startTime: "정보없음", type: .Korail, isFast: "", startStation: "정보없음", lastStation: "정보없음")]
                }else{
                    if isFirst{
                        return [list.first!]
                        }else{
                            return list
                        }
                    }
                }
            
    }
    
    // 서울 시간표 계산
    func seoulScheduleLoad(_ scheduleSearch : ScheduleSearch, isFirst : Bool, isNow : Bool) -> Observable<[ResultSchdule]>{
        guard let now = Int(self.timeFormatter(date: Date())) else {return .empty()}
        
        var inOut = ""
        
        // 9호선은 상하행이 반대
        if scheduleSearch.line == "09호선"{
            inOut = scheduleSearch.upDown.contains("상행") ? "2" : "1"
        }else{
            inOut = scheduleSearch.upDown.contains("상행") || scheduleSearch.upDown.contains("내선") ? "1" : "2"
        }
        
        let schedule = self.loadModel.seoulStationScheduleLoad(scheduleSearch: scheduleSearch)
            .map{ data -> [ScheduleStationArrival] in
                // success 되지 않으면 > 오류 발생 시
                guard case .success(let value) = data else {return []}
                return value.SearchSTNTimeTableByFRCodeService.row
            }
            .asObservable()
        
        
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
                return [ResultSchdule(startTime: "정보없음", type: .Seoul, isFast: "", startStation: "정보없음", lastStation: "정보없음")]
            }else{
                return list.map{
                    ResultSchdule(startTime: $0.startTime, type: .Seoul, isFast: $0.isFast == "D" ? "급행" : "", startStation: $0.startStation, lastStation: $0.lastStation)
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
