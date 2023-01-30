//
//  ModalModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/11.
//

import Foundation

import RxSwift

struct ModalModel{
    let session : URLSession
    let token : RequestToken
    
    init(session : URLSession = .shared){
        self.session = session
        self.token = RequestToken()
    }
    
    // 공공데이터 포털 지하철 역 검색
    func totalStationSearchRequest(_ stationName: String) -> Single<Result<TotalStationSearch, URLError>>{
        guard let urlString = "http://apis.data.go.kr/1613000/SubwayInfoService/getKwrdFndSubwaySttnList?serviceKey=\(self.token.tagoToken)&subwayStationName=\(stationName)&numOfRows=10&pageNo=1&_type=json".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return .just(.failure(.init(.badURL))) }
        
        let fixString = urlString.replacingOccurrences(of: "%25", with: "%")
        
        guard let url = URL(string: fixString) else { return .just(.failure(.init(.badURL))) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return self.session.rx.data(request: request)
            .map{
                do{
                    let result = try JSONDecoder().decode(TotalStationSearch.self, from: $0)
                    return .success(result)
                }catch{
                    return .failure(.init(.cannotDecodeContentData))
                }
            }
            .asSingle()
            .timeout(.seconds(10), other: .just(.failure(.init(.badURL))), scheduler: MainScheduler.instance)
    }
}
