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
    
    
    // live 지하철 통신
    internal func stationArrivalRequest(stationName : String) -> Single<Result<LiveStationModel, URLError>>{
        let url = "http://swopenapi.seoul.go.kr/api/subway/\(Bundle.main.tokenLoad("LIVE_TOKEN"))/json/realtimeStationArrival/0/50/\(self.arrivalStationNameChack(stationName: stationName))"
        
        return self.networkManager.requestData(url, dataType: LiveStationModel.self)
    }
    
    // 서울 지하철 시간표 데이터 통신
    internal func seoulStationScheduleLoad(scheduleSearch : ScheduleSearch, dayType: DayType) -> Single<Result<ScheduleStationModel, URLError>>{
        // 코레일/신분당선 시간표 지원하지 않음
        if scheduleSearch.stationCode.contains("K") || scheduleSearch.stationCode.contains("D"){
            return .just(.failure(.init(.badURL)))
        }
        
        // 상하행
        var inOut = 0
        
        // 9호선은 상하행이 반대
        if scheduleSearch.line == "09호선"{
            inOut = scheduleSearch.upDown.isUpDirection ? 2 : 1
        } else {
            inOut = scheduleSearch.upDown.isUpDirection ? 1 : 2
        }
        
        // 평일, 주말, 공휴일 여부
        let weekday = switch dayType {
        case .weekday: 1
        case .saturday: 2
        case .holiday: 3
        }
        
        let url =  "http://openapi.seoul.go.kr:8088/\(Bundle.main.tokenLoad("SEOUL_TOKEN"))/json/SearchSTNTimeTableByFRCodeService/1/500/\(scheduleSearch.stationCode)/\(weekday)/\(inOut)"
        
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
    internal func korailSchduleLoad(scheduleSearch: ScheduleSearch, dayType: DayType) -> Single<Result<KorailHeader, URLError>> {
        // 평일, 주말, 공휴일 여부
        let weekday = dayType == .weekday ? 8 : 9

        let url = "https://openapi.kric.go.kr/openapi/trainUseInfo/subwayTimetable?serviceKey=\(Bundle.main.tokenLoad("KORAIL_TOKEN"))&format=JSON&railOprIsttCd=KR&dayCd=\(weekday)&lnCd=\(scheduleSearch.korailCode)&stinCd=\(scheduleSearch.stationCode)"
        
        return self.networkManager.requestData(url, dataType: KorailHeader.self)
    }
    
    // 지하철 역명 통신
    internal func stationSearch(station: String) -> Single<Result<SearchStaion,URLError>>{
        let url = "http://openapi.seoul.go.kr:8088/\(Bundle.main.tokenLoad("SEOUL_TOKEN"))/json/SearchInfoBySubwayNameService/1/5/\(station)"
        
        return self.networkManager.requestData(url, dataType: SearchStaion.self)
    }
    
    // 추천 역 통신 (파이어베이스)
    internal func defaultViewListRequest() -> Observable<[String]>{
        let listData = PublishSubject<[String]>()
        
        self.database.observe(.value){dataBase, _ in
            guard let data = dataBase.value as? [String : [String :Any]] else {listData.onCompleted(); return}
            let subwayWhen = data["SubwayWhen"]
            let search = subwayWhen?["SearchDefaultList"]
            let list = search as? [String]
            
            listData.onNext(list ?? [])
            listData.onCompleted()
        }
        return listData
            .asObservable()
    }
    
    // 카카오 근접 지하철 역 통신
    func vicinityStationsLoad(x: Double, y: Double) -> Single<Result<VicinityStationsData,URLError>>{
        let url = "https://dapi.kakao.com/v2/local/search/category.json"
        let query = [
            ["category_group_code": "SW8"],
            ["radius": "3000"],
            ["x": "\(x)"],
            ["y": "\(y)"]
        ]
        let headers = [
            ["Authorization": "\(Bundle.main.tokenLoad("KAKAO_TOKEN"))"]
        ]
        
        return self.networkManager.requestData(url, decodingType: VicinityStationsData.self, headers: headers, queryList: query)
    }
    
    func importantDataLoad() -> Observable<ImportantData> {
        let importantData = PublishSubject<ImportantData>()
        
        self.database.observe(.value){ dataBase, _ in
            guard let data = dataBase.value as? [String : [String :Any]] else {importantData.onCompleted(); return}
            let subwayWhen = data["SubwayWhen"]
            let search = subwayWhen?["ImportantData"]
            let list = search as? [String]
            
            if let infoData = list {
                if infoData[0] == "Nil" {
                    importantData.onNext(.init(title: "", contents: ""))
                } else {
                    importantData.onNext(.init(title: infoData[0], contents: infoData[1]))
                }
            }
            importantData.onCompleted();
        }
        
        return importantData
            .asObservable()
    }
    
    // 신분당선 시간표
    func shinbundangScheduleReqeust(scheduleSearch: ScheduleSearch) -> Observable<[ShinbundangScheduleModel]> {
        let scheduleListSubject = PublishSubject<[ShinbundangScheduleModel]>()
        
        func close() {
            scheduleListSubject.onNext([]);
            scheduleListSubject.onCompleted();
        }
        
        self.database.observe(.value) { dataBase, _ in
            guard let dataBaseRoot = dataBase.value as? [String : [String :Any]] else {close();  return}
            // 신분당선 시간표는 기존 데이터베이스와 다른 root를 가지고 있음
            let subwayWhenSinbundangRoot = dataBaseRoot["SubwayWhenShinbundangScheduleData"]
            
            // 시간표 데이터가 많기 때문에 key에 맞는 데이터만 조회하기 위해 key를 먼저 조회
            guard let stationKeys = subwayWhenSinbundangRoot?["Keys"]  as? [String] else {close(); return}
            guard let stationIndex = stationKeys.firstIndex(of: scheduleSearch.stationName) else {close(); return}
            
            guard let scheduleList = subwayWhenSinbundangRoot?["ScheduleList"] as? [[Any]] else {close(); return}
            if scheduleList.count < stationIndex {close(); return}
            
            let matchingStationSchedule =  scheduleList[stationIndex]
            guard let matchingStationScheduleTypeCheck = matchingStationSchedule as? [[String: String]] else {close(); return}
            
            guard let data = try? PropertyListEncoder().encode(matchingStationScheduleTypeCheck) else {close(); return}
            guard let successData = try? PropertyListDecoder().decode([ShinbundangScheduleModel].self, from: data) else {close();return}
            
            scheduleListSubject.onNext(successData)
            scheduleListSubject.onCompleted()
        }
        
        return scheduleListSubject
            .asObservable()
    }
    
    // 신분당선 시간표 버전
    func shinbundangScheduleVersionRequest() -> Observable<Double> {
        let scheduleVersion = PublishSubject<Double>()
        
        self.database.observe(.value){ dataBase, _ in
            guard let data = dataBase.value as? [String : [String :Any]] else {scheduleVersion.onCompleted(); return}
            let subwayWhen = data["SubwayWhen"]
            let version = subwayWhen?["ShinbundangLineScheduleVersion"] as? [String: Double]
            scheduleVersion.onNext(version?["version"] ?? 0.0)
            scheduleVersion.onCompleted();
        }
        
        return scheduleVersion
            .asObservable()
    }
    
    func searchQueryRecommendListRequest() -> Observable<[SearchQueryRecommendData]> {
        let recommendListData = PublishSubject<[SearchQueryRecommendData]>()
        
        self.database.observe(.value){ dataBase, _ in
            guard let data = dataBase.value as? [String : [String :Any]] else {recommendListData.onCompleted(); return}
            let subwayWhen = data["SubwayWhen"]
            let search = subwayWhen?["SearchQueryRecommendList"]
            guard let list = search as? [String : [[String : String]]] else  {return}
            guard let encoding = try? PropertyListEncoder().encode(list["value"]),
                  let decodingData = try? PropertyListDecoder().decode([SearchQueryRecommendData].self, from: encoding) else {
                recommendListData.onCompleted()
                return
            }
            
            recommendListData.onNext(decodingData)
            recommendListData.onCompleted()
        }
        
        return recommendListData
            .asObservable()
    }
    
    func subwayNoticeRequest() -> Single<Result<SubwayNoticeResponse, URLError>> {
        let url = "http://openapi.seoul.go.kr:8088/\(Bundle.main.tokenLoad("SEOUL_TOKEN"))/json/getNtceList/1/5/"
        return self.networkManager.requestData(url, dataType: SubwayNoticeResponse.self)
    }

    // 노선별 실시간 열차 위치
    func realtimePositionRequest(subwayLine: SubwayLineData) -> Single<Result<RealtimeTrainPositionResponse, URLError>> {
        let url = "http://swopenapi.seoul.go.kr/api/subway/\(Bundle.main.tokenLoad("REALTIME_TOKEN"))/json/realtimePosition/0/100/\(subwayLine.realtimeLineName)"
        return self.networkManager.requestData(url, dataType: RealtimeTrainPositionResponse.self)
    }
    
    private func arrivalStationNameChack(stationName: String) -> String {
        // 부역명 필수 지하철역
        switch stationName{
        case "쌍용":
            return "쌍용(나사렛대)"
        case "총신대입구":
            return "총신대입구(이수)"
        case "신정":
            return "신정(은행정)"
        case "오목교":
            return "오목교(목동운동장앞)"
        case "군자":
            return "군자(능동)"
        case "아차산":
            return "아차산(어린이대공원후문)"
        case "광나루":
            return "광나루(장신대)"
        case "천호":
            return "천호(풍납토성)"
        case "굽은다리":
            return "굽은다리(강동구민회관앞)"
        case "새절":
            return "새절(신사)"
        case "증산":
            return "증산(명지대앞)"
        case "월드컵경기장":
            return "월드컵경기장(성산)"
        case "대흥":
            return "대흥(서강대앞)"
        case "안암":
            return "안암(고대병원앞)"
        case "월곡":
            return "월곡(동덕여대)"
        case "상월곡":
            return "상월곡(한국과학기술연구원)"
        case "화랑대":
            return "화랑대(서울여대입구)"
        case "공릉":
            return "공릉(서울산업대입구)"
        case "어린이대공원":
            return "어린이대공원(세종대)"
        case "이수":
            return "총신대입구(이수)"
        case "숭실대입구":
            return "숭실대입구(살피재)"
        case "몽촌토성":
            return "몽촌토성(평화의문)"
        case "남한산성입구":
            return "남한산성입구(성남법원, 검찰청)"
        case "서울" :
            return "서울역"
        default:
            return stationName
        }
    }
}
