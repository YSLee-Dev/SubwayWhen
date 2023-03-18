//
//  LoadModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/30.
//

import Foundation

import FirebaseDatabase
import RxSwift
import RxOptional

final class LoadModel : LoadModelProtocol{
    private let database : DatabaseReference
    let networkManager : NetworkManagerProtocol
    
    init(networkManager : NetworkManager = .init()){
        self.networkManager = networkManager
        self.database = Database.database().reference()
    }
    
    private let token = RequestToken()
    
    // live 지하철 통신
    internal func stationArrivalRequest(stationName : String) -> Single<Result<LiveStationModel, URLError>>{
        let url = "http://swopenapi.seoul.go.kr/api/subway/\(token.liveArrivalToken)/json/realtimeStationArrival/0/50/\(stationName)"
        
        return self.networkManager.requestData(url, dataType: LiveStationModel.self)
    }
    
    // 서울 지하철 시간표 데이터 통신
    internal func seoulStationScheduleLoad(scheduleSearch : ScheduleSearch) -> Single<Result<ScheduleStationModel, URLError>>{
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
        
        let url =  "http://openapi.seoul.go.kr:8088/\(token.seoulToken)/json/SearchSTNTimeTableByFRCodeService/1/500/\(scheduleSearch.stationCode)/\(weekday)/\(inOut)"
        
        return self.networkManager.requestData(url, dataType: ScheduleStationModel.self)
    }
    
    // 코레일 트레인 넘버 통신
    internal func korailTrainNumberLoad() -> Observable<[KorailTrainNumber]> {
        let loadData = PublishSubject<[KorailTrainNumber]>()
        
        self.database.observe(.value){ snaphot, _ in
            guard let data = snaphot.value as? [String : [String : Any]] else {return}
            let subwayWhen = data["SubwayWhen"]
            let korailTrainData = subwayWhen?["KorailTrainData"]
            
            let value = korailTrainData as? [String : [[String : String]]]
            let result = value?["value"]
            
            guard let encoding = try? PropertyListEncoder().encode(result) else {return}
            let decodingData = try? PropertyListDecoder().decode([KorailTrainNumber].self, from: encoding)
            
            loadData.onNext(decodingData ?? [])
            
        }
        
        return loadData
    }
    
    // 코레일 지하철 통신
    internal func korailSchduleLoad(scheduleSearch: ScheduleSearch) -> Single<Result<KorailHeader, URLError>> {
        // 평일, 주말, 공휴일 여부
        var weekday = 8
        let today = Calendar.current.component(.weekday, from: Date())
        
        if today == 1 || today == 7{
            weekday = 9
        }
        
        let url = "https://openapi.kric.go.kr/openapi/trainUseInfo/subwayTimetable?serviceKey=\(self.token.korailToken)&format=JSON&railOprIsttCd=KR&dayCd=\(weekday)&lnCd=\(scheduleSearch.korailCode)&stinCd=\(scheduleSearch.stationCode)"
        
        return self.networkManager.requestData(url, dataType: KorailHeader.self)
    }
}
