//
//  MainModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/30.
//

import Foundation

import RxSwift

class MainModel {
    private var session : URLSession
    
    init(session : URLSession = .shared){
        self.session = session
    }
    
    // live 지하철 통신
    private func stationArrivalRequest(stationName : String) -> Single<Result<LiveStationModel, URLError>>{
        guard let url = URL(string: "http://swopenapi.seoul.go.kr/api/subway/524365677079736c313034597a514e41/json/realtimeStationArrival/0/30/\(stationName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {return .just(.failure(.init(.badURL)))}
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return self.session.rx.data(request: request)
            .map{
                do {
                    let json = try JSONDecoder().decode(LiveStationModel.self, from: $0)
                    return .success(json)
                }catch{
                    return .failure(.init(.cannotDecodeContentData))
                }
            }
            .asSingle()
    }
    
    // 저장된 지하철역 로드
    private func realTimeStationLoad() -> Single<Result<[SaveStation], URLError>>{
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
    func totalLiveDataLoad() -> Observable<[MainTableViewSection]>{
        let saveStation = self.realTimeStationLoad()
            .asObservable()
            .flatMap{ data -> Observable<SaveStation> in
                guard case .success(let value) = data else {return .never()}
                return Observable.from(value)
            }
        
        let liveStation = saveStation
            .concatMap{
                self.stationArrivalRequest(stationName: $0.useStationName)
            }.map{ data -> LiveStationModel? in
                guard case .success(let value) = data else {return nil}
                return value
            }
            .filter{$0 != nil}
        
        return Observable
            .zip(saveStation, liveStation){ station, data -> MainTableViewSection in
                for x in data!.realtimeArrivalList{
                    if station.lineCode == x.subWayId && station.updnLine == x.upDown && station.useStationName == x.stationName && !(station.exceptionLastStation.contains(x.lastStation)){
                        return .init(section: "\(station.group)", stationID: station.id, items: [MainTableViewCellData(upDown: x.upDown, arrivalTime: x.arrivalTime, previousStation: x.previousStation, subPrevious: x.subPrevious, code: x.code, subWayId: x.subWayId, stationName: station.stationName, lastStation: "\(x.lastStation)행", lineNumber: station.line, isFast: x.isFast ?? "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation)])
                    }
                }
                if station.lineCode != ""{
                    return .init(section: "\(station.group)", stationID: station.id, items: [MainTableViewCellData(upDown: "", arrivalTime: "", previousStation: "현재 실시간 열차 데이터가 없어요.", subPrevious: "", code: "", subWayId: "", stationName: station.stationName, lastStation: "\(station.exceptionLastStation)행 제외", lineNumber: station.line, isFast: "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation)])
                }else{
                    return .init(section: "\(station.group)", stationID: station.id, items: [MainTableViewCellData(upDown: "", arrivalTime: "", previousStation: "지원하지 않는 호선이에요.", subPrevious: "", code: "", subWayId: "", stationName: station.stationName, lastStation: "", lineNumber: station.line, isFast: "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation)])
                }
            }
            .toArray()
            .asObservable()
    }
    
    // 지하철 시간표 데이터 통신
    private func scheduleStationLoad(scheduleSearch : ScheduleSearch, count: Int) -> Single<Result<ScheduleStationModel, URLError>>{
        // 코레일 시간표 지원하지 않음
        if scheduleSearch.stationCode.contains("K"){
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
        
        if today == 0{
            weekday = 3
        }else if today == 6{
            weekday = 2
        }else{
            weekday = 1
        }
        
        guard let url = URL(string: "http://openapi.seoul.go.kr:8088/4a7242674979736c37346143586d63/json/SearchSTNTimeTableByFRCodeService/1/\(count)/\(scheduleSearch.stationCode)/\(weekday)/\(inOut)") else {return .just(.failure(.init(.badURL)))}
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
    }
    
    // 현재 시각에 맞는 지하철 시간표
    func nowScheduleStationLoad(scheduleSearch : ScheduleSearch) -> Observable<ScheduleStationArrival>{
        let count = 300
        var inOut = ""
        
        // 9호선은 상하행이 반대
        if scheduleSearch.line == "09호선"{
            inOut = scheduleSearch.upDown.contains("상행") ? "2" : "1"
        }else{
            inOut = scheduleSearch.upDown.contains("상행") || scheduleSearch.upDown.contains("내선") ? "1" : "2"
        }
        
        guard let now = Int(self.timeFormatter(date: Date())) else {return .empty()}
        
        let schedule = self.scheduleStationLoad(scheduleSearch: scheduleSearch, count: count)
            .map{ data -> [ScheduleStationArrival]? in
                guard case .success(let value) = data else {return nil}
                return value.SearchSTNTimeTableByFRCodeService.row
            }
            .filter{$0 != nil}
            .map{$0!}
            .asObservable()
        
        return schedule.map{ data -> ScheduleStationArrival? in
            let scheduleData = data.filter{
                guard let scheduleTime = Int($0.startTime.components(separatedBy: ":").joined()) else {return false}
                if scheduleSearch.stationCode == $0.stationCode && now <= scheduleTime && inOut == $0.upDown && !(scheduleSearch.exceptionLastStation.contains($0.lastStation)){
                    return true
                }else{
                    return false
                }
            }
            guard let first = scheduleData.first else {return nil}
            return first
        }
        .filter{$0 != nil}
        .map{$0!}
    }
    
    private func timeFormatter(date : Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmmss"
        return formatter.string(from: date)
    }
}
