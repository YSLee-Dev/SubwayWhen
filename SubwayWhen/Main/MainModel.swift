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
    private func stationLoad() -> Single<Result<[SaveStation], URLError>>{
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
    func totalLiveDataLoad() -> Observable<[RealtimeStationArrival]>{
        let saveStation = self.stationLoad()
            .asObservable()
            .flatMap{ data -> Observable<SaveStation> in
                guard case .success(let value) = data else {return .never()}
                return Observable.from(value)
            }
            
        let liveStation = saveStation
            .concatMap{
                self.stationArrivalRequest(stationName: $0.stationName)
            }.map{ data -> LiveStationModel? in
                guard case .success(let value) = data else {return nil}
                return value
            }
            .filter{$0 != nil}
        
      return Observable
            .zip(saveStation, liveStation){ station, data -> RealtimeStationArrival in
                for x in data!.realtimeArrivalList{
                    if station.lineCode == x.subWayId && station.updnLine == x.upDown && station.stationName == x.stationName && !(station.exceptionLastStation.contains(x.lastStation)){
                        return .init(upDown: x.upDown, arrivalTime: x.arrivalTime, previousStation: x.previousStation, subPrevious: x.subPrevious, code: x.code, subWayId: x.subWayId, stationName: station.stationName, lastStation: "\(x.lastStation)행", lineNumber: station.line, isFast: x.isFast, useLine: station.useLine, group: station.group.rawValue, id: station.id)
                    }
                }
                if station.lineCode != ""{
                    return .init(upDown: "", arrivalTime: "", previousStation: "현재 실시간 열차 데이터가 없어요.", subPrevious: "", code: "", subWayId: "", stationName: station.stationName, lastStation: "\(station.exceptionLastStation)행 제외", lineNumber: station.line, isFast: nil, useLine: station.useLine, group: station.group.rawValue, id: station.id)
                }else{
                    return .init(upDown: "", arrivalTime: "", previousStation: "지원하지 않는 호선이에요.", subPrevious: "", code: "", subWayId: "", stationName: station.stationName, lastStation: "", lineNumber: station.line, isFast: nil, useLine: station.useLine, group: station.group.rawValue, id: station.id)
                }
            }
            .toArray()
            .asObservable()
    }
}
