//
//  LoadModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/30.
//

import Foundation

import RxSwift
import RxOptional

class LoadModel {
    private var session : URLSession
    private let token = RequestToken()
    
    init(session : URLSession = .shared){
        self.session = session
    }
    
    // live 지하철 통신
    func stationArrivalRequest(stationName : String) -> Single<Result<LiveStationModel, URLError>>{
        guard let url = URL(string: "http://swopenapi.seoul.go.kr/api/subway/\(token.liveArrivalToken)/json/realtimeStationArrival/0/50/\(stationName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {return .just(.failure(.init(.badURL)))}
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return self.session.rx.data(request: request)
            .map{
                do {
                    let json = try JSONDecoder().decode(LiveStationModel.self, from: $0)
                    return .success(json)
                }catch{
                    print(error)
                    return .failure(.init(.cannotDecodeContentData))
                }
            }
            .asSingle()
            .timeout(.seconds(5), other: .just(.failure(.init(.timedOut))), scheduler: MainScheduler.instance)
    }
    
    // 저장된 지하철역 로드
    private func saveStationLoad() -> Single<Result<[SaveStation], URLError>>{
        let udValue = UserDefaults.standard.value(forKey: "saveStation")
        guard let data = udValue as? Data else {return .just(.failure(.init(.badURL)))}
        
        do {
            let list = try PropertyListDecoder().decode([SaveStation].self, from: data)
            FixInfo.saveStation = list
            return .just(.success(list))
        }catch{
            print(error)
            return .just(.failure(.init(.cannotDecodeContentData)))
        }
    }
    
    // 지하철역 + live 지하철역 정보를 합쳐서 return
    func totalLiveDataLoad() -> Observable<MainTableViewCellData>{
        let saveStation = self.saveStationLoad()
            .asObservable()
            .flatMap{ data -> Observable<SaveStation> in
                guard case .success(let value) = data else {return .never()}
                return Observable.from(value)
            }
            .share()
        
        let liveStation = saveStation
            .concatMap{
                self.stationArrivalRequest(stationName: $0.useStationName)
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
                        
                        return .init(upDown: x.upDown, arrivalTime: x.arrivalTime, previousStation: x.previousStation ?? "", subPrevious: x.subPrevious, code: code, subWayId: x.subWayId, stationName: station.stationName, lastStation: "\(x.lastStation)행", lineNumber: station.line, isFast: x.isFast ?? "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation, type: .real, backStationId: x.backStationId, nextStationId: x.nextStationId, totalStationId: station.totalStationCode)
                    }else if station.lineCode == x.subWayId && station.updnLine == x.upDown && station.useStationName == x.stationName{
                        backId = x.backStationId
                        nextId = x.nextStationId
                    }
                }
                
                if station.lineCode != ""{
                    return .init(upDown: station.updnLine, arrivalTime: "", previousStation: "현재 실시간 열차 데이터가 없어요.", subPrevious: "", code: "", subWayId: "", stationName: station.stationName, lastStation: "\(station.exceptionLastStation)행 제외", lineNumber: station.line, isFast: "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation, type: .real, backStationId: backId, nextStationId: nextId, totalStationId: station.totalStationCode)
                }else{
                    return .init(upDown: "", arrivalTime: "", previousStation: "지원하지 않는 호선이에요.", subPrevious: "", code: "", subWayId: "", stationName: station.stationName, lastStation: "", lineNumber: station.line, isFast: "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation, type: .real, backStationId: "", nextStationId: "", totalStationId: station.totalStationCode)
                }
            }
            .asObservable()
    }
    
    // 타고 지하철 시간표 통신
    func TagoStationSchduleLoad(_ scheduleSearch : ScheduleSearch) -> Single<Result<TagoSchduleStation, URLError>>{
        let line = scheduleSearch.upDown == "상행" ||  scheduleSearch.upDown == "내선" ? "U" : "D"
        
        // 평일, 주말, 공휴일 여부
        var weekday = "0"
        let today = Calendar.current.component(.weekday, from: Date())
        
        if today == 1{
            weekday = "03"
        }else if today == 7{
            weekday = "02"
        }else{
            weekday = "01"
        }
        
        let urlString = "https://apis.data.go.kr/1613000/SubwayInfoService/getSubwaySttnAcctoSchdulList?serviceKey=\(token.tagoToken)&pageNo=1&numOfRows=500&_type=json&subwayStationId=\(scheduleSearch.stationCode)&dailyTypeCode=\(weekday)&upDownTypeCode=\(line)"
        guard let url = URL(string: urlString) else {return .just(.failure(.init(.badURL)))}
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return self.session.rx.data(request: request)
            .map{
                do{
                    let result = try JSONDecoder().decode(TagoSchduleStation.self, from: $0)
                    return .success(result)
                }catch{
                    print(error)
                    return .failure(.init(.cannotDecodeContentData))
                }
            }
            .asSingle()
            .timeout(.seconds(5), other: .just(.failure(.init(.timedOut))), scheduler: MainScheduler.instance)
    }
    
    // 서울 지하철 시간표 데이터 통신
    func seoulStationScheduleLoad(scheduleSearch : ScheduleSearch) -> Single<Result<ScheduleStationModel, URLError>>{
        // 코레일/신분당선 시간표 지원하지 않음
        if scheduleSearch.stationCode.contains("K") || scheduleSearch.stationCode.contains("D"){
            return .just(.failure(.init(.badURL)))
        }
        
        // 상하행
        var inOut = 0
        
        // 9호선은 상하행이 반대
        if scheduleSearch.line == "09호선"{
            inOut = scheduleSearch.upDown.contains("상행") ? 2 : 1
        }else{
            inOut = scheduleSearch.upDown.contains("상행") || scheduleSearch.upDown.contains("내선") ? 1 : 2
        }
        
        // 평일, 주말, 공휴일 여부
        var weekday = 0
        let today = Calendar.current.component(.weekday, from: Date())
        
        if today == 1{
            weekday = 3
        }else if today == 7{
            weekday = 2
        }else{
            weekday = 1
        }
        
        guard let url = URL(string: "http://openapi.seoul.go.kr:8088/\(token.seoulToken)/json/SearchSTNTimeTableByFRCodeService/1/500/\(scheduleSearch.stationCode)/\(weekday)/\(inOut)") else {return .just(.failure(.init(.badURL)))}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return self.session.rx.data(request: request)
            .map{
                do{
                    let json = try JSONDecoder().decode(ScheduleStationModel.self, from: $0)
                    return .success(json)
                }catch{
                    return .failure(.init(.cannotDecodeContentData))
                }
                
            }
            .asSingle()
            .timeout(.seconds(5), other: .just(.failure(.init(.timedOut))), scheduler: MainScheduler.instance)
    }
    
    // 현재 시각에 맞는 지하철 시간표
    func totalScheduleStationLoad(_ scheduleSearch : ScheduleSearch, isFirst : Bool, isNow : Bool) -> Observable<[ResultSchdule]>{
        guard let now = Int(self.timeFormatter(date: Date())) else {return .empty()}
        
        if scheduleSearch.type == .Tago{
            let schedule = self.TagoStationSchduleLoad(scheduleSearch)
                .map{ data -> [TagoItem]? in
                    guard case .success(let value) = data else {return nil}
                    return value.response.body.items.item
                }
                .filter{$0 != nil}
                .map{$0!}
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
            .filterEmpty()
            .map{ list in
                list.map{
                    ResultSchdule(startTime: $0.arrTime, type: .Tago, lastStation: $0.endSubwayStationNm ?? "")
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
            
            let schedule = self.seoulStationScheduleLoad(scheduleSearch: scheduleSearch)
                .map{ data -> [ScheduleStationArrival]? in
                    guard case .success(let value) = data else {return nil}
                    return value.SearchSTNTimeTableByFRCodeService.row
                }
                .filter{$0 != nil}
                .map{$0!}
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
            .filterEmpty()
            .map{ list in
                list.map{
                    ResultSchdule(startTime: $0.startTime, type: .Seoul, lastStation: $0.lastStation)
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
