//
//  SearchModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import Foundation

import RxSwift
import RxCocoa
import FirebaseDatabase

class SearchModel{
    private let session : URLSession
    private var database : DatabaseReference
    
    init(session : URLSession = .shared){
        self.session = session
        self.database = Database.database().reference()
    }
    
    // 지하철 역명 통신
    func stationSearch(station: String) -> Single<Result<SearchStaion,URLError>>{
        guard let url = URL(string: ("http://openapi.seoul.go.kr:8088/4a7242674979736c37346143586d63/json/SearchInfoBySubwayNameService/1/5/\(station)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")) else { return .just(.failure(.init(.badURL))) }
        let urlString = url.absoluteString.replacingOccurrences(of: "=", with: "")
        
        var request = URLRequest(url: URL(string: urlString) ?? url)
        request.httpMethod = "GET"
        return self.session.rx.data(request: request)
            .map{
                do {
                    let json = try JSONDecoder().decode(SearchStaion.self, from: $0)
                    return .success(json)
                }catch{
                    return .failure(.init(.cannotDecodeContentData))
                }
            }
            .asSingle()
    }
    
    // 추천 역 통신 (파이어베이스)
    func defaultViewListRequest() -> Observable<[String]>{
        let listData = PublishRelay<[String]>()
        
        self.database.observe(.value){
            guard let value = $0.value as? [String : [String:[String]]] else {return}
            let subwaySearchDefaultList = value["SubwaySearchDefaultList"]
            let list = subwaySearchDefaultList?["List"]
            
            listData
                .accept(list ?? [])
        }
        return listData
            .asObservable()
    }
}
