//
//  NetworkManger.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/01.
//

import Foundation

import RxSwift

final class NetworkManger{
    let session : URLSessionProtocol
    
    init(session : URLSessionProtocol = URLSession.shared){
        self.session = session
    }
    
    func requestData<T : Decodable>(_ url :String, dataType: T.Type) -> Single<Result<T,URLError>>{
        guard let url = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {return .just(.failure(.init(.badURL)))}
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return self.session.response(request: request)
            .map{
                do{
                    if 200...300 ~= $0.statusCode{
                        let data = try JSONDecoder().decode(T.self, from: $1)
                        return .success(data)
                    }else if 300...400 ~= $0.statusCode{
                        return .failure(.init(.badServerResponse))
                    }else{
                        return .failure(.init(.badURL))
                    }
                   
                }catch{
                    return .failure(.init(.cannotParseResponse))
                }
            }
            .timeout(.seconds(5), scheduler: MainScheduler.asyncInstance)
            .catch{error in
                print(error)
                return .just(.failure(.init(.notConnectedToInternet)))
            }
            .asSingle()
    }
}
