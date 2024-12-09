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
    private var coreDataManager: CoreDataScheduleManagerProtocol
    private let bag = DisposeBag()
    private var stationIDList: [DetailStationId] {
        guard let fileUrl = Bundle.main.url(forResource: "DetailStationIdList", withExtension: "plist") else {return  []}
        guard let data = try? Data(contentsOf: fileUrl) else {return  []}
        guard let decodingData = try? PropertyListDecoder().decode([DetailStationId].self, from: data) else {return  []}
        return decodingData
    }
    
    init(loadModel : LoadModel = .init(), coreDataManager: CoreDataScheduleManager = CoreDataScheduleManager.shared){
        self.loadModel = loadModel
        self.coreDataManager = coreDataManager
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
                        
                        return (.init(upDown: x.upDown, arrivalTime: x.arrivalTime, previousStation: x.previousStation ?? "", subPrevious: x.subPrevious, code: code, subWayId: station.lineCode, stationName: station.stationName, lastStation: "\(x.lastStation)행", lineNumber: station.line, isFast: x.isFast ?? "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation, type: .real, backStationId: x.backStationId, nextStationId: x.nextStationId,  korailCode: station.korailCode, stateMSG: x.useState), saveStation.offset)
                    }else if station.lineCode == x.subWayId && station.updnLine == x.upDown && spaceRemoveStationName == x.stationName{
                        backId = x.backStationId
                        nextId = x.nextStationId
                    }
                }
                
                if station.lineCode != ""{
                    let exceptionLastStation = station.exceptionLastStation == "" ? "" : "\(station.exceptionLastStation)행 제외"
                    return (.init(upDown: station.updnLine, arrivalTime: "", previousStation: "", subPrevious: "", code: "현재 실시간 열차 데이터가 없어요.", subWayId: station.lineCode, stationName: station.stationName, lastStation: "\(exceptionLastStation)", lineNumber: station.line, isFast: "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation, type: .real, backStationId: backId, nextStationId: nextId, korailCode: station.korailCode, stateMSG: "현재 실시간 열차 데이터가 없어요."), saveStation.offset)
                }else{
                    return (.init(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "지원하지 않는 호선이에요.", subWayId: station.lineCode, stationName: station.stationName, lastStation: "", lineNumber: station.line, isFast: "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation, type: .real, backStationId: "", nextStationId: "",  korailCode: station.korailCode, stateMSG: "지원하지 않는 호선이에요."), saveStation.offset)
                }
            }
            .asObservable()
    }
    
    // live 정보만 반환하되, 필터링을 거침
    func singleLiveDataLoad(requestModel: DetailArrivalDataRequestModel) -> Observable< [TotalRealtimeStationArrival]> {
        self.loadModel.stationArrivalRequest(stationName: requestModel.stationName)
            .map{ data -> LiveStationModel in
                guard case .success(let value) = data else {return .init(realtimeArrivalList: [])}
                return value
            }
            .map { data -> [TotalRealtimeStationArrival] in
                let errorModel = TotalRealtimeStationArrival(realTimeStationArrival: .init(upDown: requestModel.upDown, arrivalTime: "", previousStation: "", subPrevious: "", code: "", subWayId: "", stationName: requestModel.stationName, lastStation: "\(requestModel.exceptionLastStation)행 제외", lineNumber: requestModel.line.rawValue, isFast: nil, backStationId: requestModel.backStationId ?? "", nextStationId: requestModel.nextStationId ?? "", trainCode: ""), backStationName: "", nextStationName: "", nowStateMSG: "")
                
                if data.realtimeArrivalList.isEmpty {
                    return [errorModel, errorModel]
                } else {
                    var arrivalData: [TotalRealtimeStationArrival] = []
                    for x in data.realtimeArrivalList {
                        if requestModel.upDown == x.upDown && requestModel.line.lineCode == x.subWayId && !(requestModel.exceptionLastStation.contains(x.lastStation)){
                            let backNextStation = self.nextAndBackStationSearch(backId: x.backStationId, nextId: x.nextStationId, lineCode: requestModel.line.lineCode)
                            arrivalData.append(.init(realTimeStationArrival: x, backStationName: backNextStation.first ?? "", nextStationName: backNextStation.last ?? "", nowStateMSG: x.useState))
                        }
                        if arrivalData.count >= 2 {
                            break
                        }
                    }
                    
                    if arrivalData.count < 2 {
                        for _ in 0 ..< 2 - arrivalData.count {
                            arrivalData.append(errorModel)
                        }
                    }
                    return arrivalData
                }
            }
            .asObservable()
    }
    
    // 코레일 시간표 계산
    func korailSchduleLoad(scheduleSearch : ScheduleSearch, isFirst : Bool, isNow : Bool, isWidget: Bool, requestDate: Date) ->  Observable<[ResultSchdule]>{
        guard let now = Int(self.timeFormatter(date: requestDate)) else {return .empty()}
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
        
        var realDataIn = false
        let filterData = schedule.map{ data in
            data.filter{
                if !(scheduleSearch.exceptionLastStation.contains($0.lastStation)){
                    if isNow{
                        if now <= Int($0.startTime) ?? 0 {
                            return true
                        } else {
                            if !realDataIn {
                                realDataIn = true
                            }
                        }
                    } else {
                        return true
                    }
                }
                return false
            }
        }
        
        return filterData
            .map{ list in
                if list.isEmpty{
                    var result: ResultSchdule!
                    if isWidget && realDataIn {
                        result = ResultSchdule(startTime: "-", type: .Seoul, isFast: "", startStation: "", lastStation: "")
                    } else {
                        result = ResultSchdule(startTime: "정보없음", type: .Seoul, isFast: "", startStation: "정보없음", lastStation: "정보없음")
                    }
                    return [result]
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
    func seoulScheduleLoad(_ scheduleSearch : ScheduleSearch, isFirst : Bool, isNow : Bool, isWidget: Bool, requestDate: Date) -> Observable<[ResultSchdule]>{
        guard let now = Int(self.timeFormatter(date: requestDate)) else {return .empty()}
        
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
        
        var realDataIn = false
        return schedule.map{ data -> [ScheduleStationArrival] in
            let scheduleData = data.filter{
                guard let scheduleTime = Int($0.startTime.components(separatedBy: ":").joined()) else {return false}
                
                if scheduleSearch.stationCode == $0.stationCode && inOut == $0.upDown && !(scheduleSearch.exceptionLastStation.contains($0.lastStation)){
                    if isNow {
                        if now <= scheduleTime {
                            return true
                        } else {
                            if !realDataIn {
                               realDataIn = true
                           }
                        }
                    } else {
                        return true
                    }
                }
                return false
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
                var result: ResultSchdule!
                if isWidget && realDataIn {
                    result = ResultSchdule(startTime: "-", type: .Seoul, isFast: "", startStation: "", lastStation: "")
                } else {
                    result = ResultSchdule(startTime: "정보없음", type: .Seoul, isFast: "", startStation: "정보없음", lastStation: "정보없음")
                }
                return [result]
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
    
    // Rx 버전은 삭제 예정
    func defaultViewListLoad() -> Observable<[String]>{
        self.loadModel.defaultViewListRequest()
    }
    
    // Rx 버전은 삭제 예정
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
    
    func vicinityStationsDataLoad(x: Double, y: Double) async -> [VicinityTransformData] {
        return await withCheckedContinuation { continuation in
            let loadModelData = self.loadModel.vicinityStationsLoad(x: x, y: y)
                .map { data -> [VicinityDocumentData] in
                    guard case .success(let value) = data else {return []}
                    return value.documents
                }
                .map { data in
                    // SW8 = 지하철이 아닌 정보는 filter해요.
                    return data.filter {$0.category == "SW8" || $0.category == "정보없음"}
                }
                .map { data in
                    data.sorted {
                        // 가장 가까운 지하철 순서로 정렬해요.
                        let first = Int($0.distance) ?? 0
                        let second = Int($1.distance) ?? 1
                        return first < second
                    }
                }
                .map { data in
                    data.map {
                        VicinityTransformData(
                            id: $0.distance + $0.name,
                            name: self.stationNameSeparation(oldValue: $0.name),
                            line: self.lineSeparation(oldValue: $0.name),
                            distance: self.distanceTransform(oldValue: $0.distance)
                        )
                    }
                }
                .asObservable()
               
            loadModelData.subscribe(onNext: { data in
                continuation.resume(returning: data)
            })
            .disposed(by: self.bag)
        }
    }
    
    func defaultViewListLoad() async -> [String] {
        return await withCheckedContinuation { continuation in
            self.loadModel.defaultViewListRequest()
                .subscribe(onNext: {
                    continuation.resume(returning: $0)
                })
                .disposed(by: self.bag)
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
    
    func shinbundangScheduleLoad(scheduleSearch: ScheduleSearch, isFirst: Bool, isNow: Bool, isWidget: Bool, requestDate: Date, isDisposable: Bool) -> Observable<[ResultSchdule]> {
        let requestWeek = Calendar.current.component(.weekday, from: requestDate)
        let requestWeekString = (requestWeek == 1 || requestWeek == 7) ? "주말" : "평일"
        guard let nowTime = Int(self.timeFormatter(date: requestDate, isSecondIncludes: false)) else {return .empty()}
        
        let shinbundangVersionObserverable = self.loadModel.shinbundangScheduleVersionRequest()
        let localSchedule = self.coreDataManager.shinbundangScheduleDataLoad(stationName: scheduleSearch.stationName)
        
        var shinbundangVersion = 0.0
        var newSave = false
        
        // A-1. 저장된 신분당선 데이터가 있는지 확인합니다.
       return Observable.zip(shinbundangVersionObserverable, Observable.just(localSchedule))
            .map {($0, $1)}
            .flatMap { version,  localSchedule -> Observable<[ShinbundangScheduleModel]> in
                shinbundangVersion = version
                
                // A-2. 저장된 신분당선의 버전을 확인합니다.
                if (Double(localSchedule?.scheduleVersion ?? "0")) ?? 0.0 >= version, let localScheduleData = localSchedule?.scheduleData {
                    // A-3. 저장된 신분당선 시간표를 반환합니다.
                    return Observable.just(localScheduleData)
                } else {
                    // B-1. 저장된 신분당선 데이터가 없거나 버전이 낮으면 데이터를 요청합니다.
                    newSave = !isDisposable
                    return self.loadModel.shinbundangScheduleReqeust(scheduleSearch: scheduleSearch)
                }
            }
            .do(onNext: { data in
                if newSave  {
                    if localSchedule?.scheduleData != nil  {   // B-2. 저장된 신분당선 데이터를 삭제 후 저장합니다. (일회성 보기가 아닐 때만 저장)
                        self.coreDataManager.shinbundangScheduleDataRemove(stationName: scheduleSearch.stationName)
                    }
                    self.coreDataManager.shinbundangScheduleDataSave(to: [scheduleSearch.stationName: data], scheduleVersion: "\(shinbundangVersion)")
                }
            })
            .map { data in
                let filterData = data.filter {
                    guard let scheduleTime = Int($0.startTime.components(separatedBy: ":").joined()) else {return false}
                    if $0.updown == scheduleSearch.upDown && $0.week == requestWeekString && !scheduleSearch.exceptionLastStation.contains($0.endStation) {
                        if isNow {
                            return nowTime <= scheduleTime
                        } else {
                            return true
                        }
                    } else {
                        return false
                    }
                }
                
                var resultScheduleData = filterData.map {
                    ResultSchdule(startTime: $0.startTime, type: .Shinbundang, isFast: "", startStation: $0.startStation, lastStation: $0.endStation)
                }
                
                if resultScheduleData.isEmpty {
                    if isWidget {
                        resultScheduleData.append(ResultSchdule(startTime: "-", type: .Shinbundang, isFast: "", startStation: "", lastStation: ""))
                    } else {
                        resultScheduleData.append(ResultSchdule(startTime: "정보없음", type: .Shinbundang, isFast: "", startStation: "정보없음", lastStation: "정보없음"))
                    }
                }
                
                if isFirst {
                    guard let first = resultScheduleData.first else {return []}
                    return [first]
                } else {
                    return resultScheduleData
                }
            }
    }
    
    private func timeFormatter(date : Date, isSecondIncludes: Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = isSecondIncludes ?  "HHmmss" : "HHmm"
        return formatter.string(from: date)
    }
    
    private func distanceTransform(oldValue: String) -> String {
        guard let doubleValue = Int(oldValue) else {return "정보없음"}
        let numberFomatter = NumberFormatter()
        numberFomatter.numberStyle = .decimal
        
        guard let newValue = numberFomatter.string(for: doubleValue) else {return "정보없음"}
        return "\(newValue)m"
    }
    
    private func stationNameSeparation(oldValue: String) -> String {
        guard let wordIndex = oldValue.lastIndex(of: "역") else {return "정보없음"}
        return String(oldValue[oldValue.startIndex ..< wordIndex])
    }
    
    private func lineSeparation(oldValue: String) -> String {
        guard let wordIndex = oldValue.lastIndex(of: "역") else {return "정보없음"}
        return String(oldValue[oldValue.index(after: wordIndex) ..< oldValue.endIndex]).replacingOccurrences(of: " ", with: "")
    }
    
    private func nextAndBackStationSearch(backId : String?, nextId : String?, lineCode: String) -> [String]{
        var backStation : String = ""
        var nextStation : String = ""
        let decodingData = self.stationIDList
        
        for x in decodingData{
            if x.stationId == backId{
                backStation = x.stationName
            }
            
            if x.stationId == nextId{
                nextStation = x.stationName
            }
            
            if backStation != "" && nextStation != ""{
                break
            }
        }
        if lineCode == "1065" { // 공항철도는 반대
            return  [nextStation, backStation]
        } else {
            return  [backStation, nextStation]
        }
    }
}
