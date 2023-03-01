//
//  LoadModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/30.
//

import Foundation

import RxSwift
import RxOptional

class LoadModel : LoadModelProtocol{
    private var networkManger = NetworkManger()
    private let token = RequestToken()
    
    // live 지하철 통신
    internal func stationArrivalRequest(stationName : String) -> Single<Result<LiveStationModel, URLError>>{
        let url = "http://swopenapi.seoul.go.kr/api/subway/\(token.liveArrivalToken)/json/realtimeStationArrival/0/50/\(stationName)"
        
        return self.networkManger.requestData(url, dataType: LiveStationModel.self)
    }
    
    // 저장된 지하철역 로드
    internal func saveStationLoad() -> Single<Result<[SaveStation], URLError>>{
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
    
    // Korail 시간표 통신
    /*
    func korailScduleLoad(_ scheduleSearch : ScheduleSearch) -> Single<Result<KorailBody, URLError>>{
        // 평일, 주말, 공휴일 여부
        var weekday = "0"
        let today = Calendar.current.component(.weekday, from: Date())
        
        if today == 1{
            weekday = "9"
        }else if today == 7{
            weekday = "7"
        }else{
            weekday = "8"
        }
        
        let urlString = "https://openapi.kric.go.kr/openapi/trainUseInfo/subwayTimetable?serviceKey=\(self.token.korailToken)&format=JSON&railOprIsttCd=\(scheduleSearch.korailBrandCode)&dayCd=\(weekday)&lnCd=\(scheduleSearch.korailLineCode)&stinCd=\(scheduleSearch.stationCode)"
        guard let url = URL(string: urlString) else {return .just(.failure(.init(.badURL)))}
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return self.session.rx.data(request: request)
            .map{
                do{
                    let result = try JSONDecoder().decode(KorailBody.self, from: $0)
                    
                    let sortData = result.body.filter{
                        guard let last = $0.trainCode.last else {return false}
                        guard let number = Int(String(last)) else {return false}
                        
                        if number % 2 == 0{
                            
                        }
                    }
                }catch{
                    return .failure(.init(.cannotDecodeContentData))
                }
            }
            .asSingle()
            .timeout(.seconds(5), other: .just(.failure(.init(.timedOut))), scheduler: MainScheduler.instance)
    }
     */
    
    // 타고 지하철 시간표 통신
    internal func TagoStationSchduleLoad(_ scheduleSearch : ScheduleSearch) -> Single<Result<TagoSchduleStation, URLError>>{
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
        
        let url = "https://apis.data.go.kr/1613000/SubwayInfoService/getSubwaySttnAcctoSchdulList?serviceKey=\(token.tagoToken)&pageNo=1&numOfRows=500&_type=json&subwayStationId=\(scheduleSearch.stationCode)&dailyTypeCode=\(weekday)&upDownTypeCode=\(line)"
        
        return self.networkManger.requestData(url, dataType: TagoSchduleStation.self)
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
        
        return self.networkManger.requestData(url, dataType: ScheduleStationModel.self)
    }
    
}
