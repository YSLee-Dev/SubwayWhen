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

class TotalLoadModel : TotalLoadProtocol {
    private var loadModel : LoadModelProtocol
    private let bag = DisposeBag()
    
    init(loadModel : LoadModel = .init()){
        self.loadModel = loadModel
    }
    
    // 지하철역 + live 지하철역 정보를 합쳐서 return
    func totalLiveDataLoad(stations: [SaveStation]) -> Observable<(MainTableViewCellData, Int)>{
        let saveStation = Observable.from(stations.enumerated())
        
        let liveStation = saveStation
            .concatMap{[weak self] in
                return self!.loadModel.stationArrivalRequest(stationName: $0.element.stationName)
            }.map{ data -> LiveStationModel in
                guard case .success(let value) = data else {return .init(realtimeArrivalList: [RealtimeStationArrival(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "", subWayId: "", stationName: "", lastStation: "", lineNumber: "", isFast: "", backStationId: "", nextStationId: "", trainCode: "")])}
                return value
            }
        
        return Observable
            .zip(saveStation, liveStation){ saveStation, data -> (MainTableViewCellData, Int) in
                // 실시간 데이터가 없을 때
                let station = saveStation.element
                var backId = ""
                var nextId = ""
                
                for x in data.realtimeArrivalList{
                    let spaceRemoveStationName = x.stationName.replacingOccurrences(of: " ", with: "")
                    
                    if station.lineCode == x.subWayId && station.updnLine == x.upDown && spaceRemoveStationName == x.stationName && !(station.exceptionLastStation.contains(x.lastStation)){
                        let code = x.previousStation != nil ? x.code : ""
                        backId = x.backStationId
                        nextId = x.nextStationId
                        
                        return (.init(upDown: x.upDown, arrivalTime: x.arrivalTime, previousStation: x.previousStation ?? "", subPrevious: x.subPrevious, code: code, subWayId: station.lineCode, stationName: station.stationName, lastStation: "\(x.lastStation)행", lineNumber: station.line, isFast: x.isFast ?? "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation, type: .real, backStationId: x.backStationId, nextStationId: x.nextStationId,  korailCode: station.korailCode), saveStation.offset)
                    }else if station.lineCode == x.subWayId && station.updnLine == x.upDown && spaceRemoveStationName == x.stationName{
                        backId = x.backStationId
                        nextId = x.nextStationId
                    }
                }
                
                if station.lineCode != ""{
                    let exceptionLastStation = station.exceptionLastStation == "" ? "" : "\(station.exceptionLastStation)행 제외"
                    return (.init(upDown: station.updnLine, arrivalTime: "", previousStation: "", subPrevious: "", code: "현재 실시간 열차 데이터가 없어요.", subWayId: station.lineCode, stationName: station.stationName, lastStation: "\(exceptionLastStation)", lineNumber: station.line, isFast: "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation, type: .real, backStationId: backId, nextStationId: nextId, korailCode: station.korailCode), saveStation.offset)
                }else{
                    return (.init(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "지원하지 않는 호선이에요.", subWayId: station.lineCode, stationName: station.stationName, lastStation: "", lineNumber: station.line, isFast: "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation, type: .real, backStationId: "", nextStationId: "",  korailCode: station.korailCode), saveStation.offset)
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
            .delay(.microseconds(10), scheduler: MainScheduler.asyncInstance)
            .asObservable()
    }
    
    // 코레일 시간표 계산
    func korailSchduleLoad(scheduleSearch : ScheduleSearch, isFirst : Bool, isNow : Bool) ->  Observable<[ResultSchdule]>{
        guard let now = Int(self.timeFormatter(date: Date())) else {return .empty()}
        let weekDay = Calendar.current.component(.weekday, from: Date())
        var retry = false
        
        let requestRry = BehaviorSubject<Void>(value: Void())
        var searchInfo = scheduleSearch
        
        let number = self.loadModel.korailTrainNumberLoad()
        let request = requestRry
            .flatMap{[weak self] _ in
                self?.loadModel.korailSchduleLoad(scheduleSearch: searchInfo) ?? .never()
            }
            .asObservable()
        
        let success = request
            .map{data -> [KorailScdule]? in
                guard case .success(let value) = data else {
                    searchInfo.stationCode = searchInfo.stationCode.lowercased()
                    requestRry.onNext(Void())
                    requestRry.onCompleted()
                    
                    if !retry {
                        retry = true
                        return nil
                    } else {
                        return []
                    }
                }
                requestRry.onCompleted()
                return value.body
            }
        
        let numberCheck = number.map{ data in
            data.filter{
                if weekDay == 1 || weekDay == 7{
                    return $0.week == "주말" ? true : false
                }else{
                    return $0.week == "평일" ? true : false
                }
            }
        }
        
        // 상하행 구분 / 짝수일 경우 상행, 홀수일 경우 하행
        let updownCheck = success.filter {$0 != nil}.map {$0!}.map{data in
            return data.filter{
                let updownRequest = Int(String($0.trainCode.last ?? "9")) ?? 9
                if updownRequest % 2 == 0{
                    return scheduleSearch.upDown == "상행" ? true : false
                }else{
                    return scheduleSearch.upDown == "하행" ? true : false
                }
            }
            .filter{
                $0.time != nil && $0.time != ""
            }
        }
        
        let schedule = Observable<[ResultSchdule]>.combineLatest(numberCheck, updownCheck){number, updownCheck -> [ResultSchdule] in
            var result : [ResultSchdule] = []
            
            // lastStation 값 주입
            for r in updownCheck.enumerated(){
                if r.element.stationId == searchInfo.stationCode{
                    result.append(ResultSchdule.init(startTime: r.element.time ?? "", type: .Korail, isFast: "", startStation: "", lastStation: ""))
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
    
    func stationNameSearchReponse(_ stationName : String) -> Observable<SearchStaion> {
        self.loadModel.stationSearch(station: stationName)
            .map{ data -> SearchStaion? in
                guard case .success(let value) = data else {return nil}
                return value
            }
            .asObservable()
            .filterNil()
    }
    
    func defaultViewListLoad() -> Observable<[String]>{
        self.loadModel.defaultViewListRequest()
    }
    
    func vicinityStationsDataLoad(x: Double, y: Double) -> Observable<[VicinityDocumentData]> {
        self.loadModel.vicinityStationsLoad(x: x, y: y)
            .map { data -> VicinityStationsData? in
                guard case .success(let value) = data else {return nil}
                return value
            }
            .asObservable()
            .replaceNilWith(.init(documents: [.init(name: "정보없음", distance: "정보없음", category: "정보없음")]))
            .map {
                $0.documents
            }
            .map { data in
                let filter = data.filter {
                    $0.category == "SW8" || $0.category == "정보없음"
                }
                
                return filter.sorted {
                    let first = Int($0.distance) ?? 0
                    let second = Int($1.distance) ?? 1
                    return first < second
                }
            }
    }
    
    func importantDataLoad() -> RxSwift.Observable<ImportantData> {
        self.loadModel.importantDataLoad()
    }
    
    func scheduleDataFetchAsyncData(_ scheduleData: Observable<[ResultSchdule]>) async -> [ResultSchdule] {
        return await withCheckedContinuation { continuation in
            scheduleData
                .subscribe(onNext: { data in
                    continuation.resume(returning: data)
                })
                .disposed(by: self.bag)
        }
    }
    
    private func timeFormatter(date : Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmmss"
        return formatter.string(from: date)
    }
}
