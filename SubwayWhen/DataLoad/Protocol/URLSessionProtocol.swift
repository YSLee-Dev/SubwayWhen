//
//  URLSessionProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/01.
//

import Foundation

import RxSwift

protocol URLSessionProtocol{
    func response(request: URLRequest) -> Observable<(response: HTTPURLResponse, data: Data)>
}

extension URLSession : URLSessionProtocol{
    func response(request: URLRequest) -> Observable<(response: HTTPURLResponse, data: Data)> {
        return self.rx.response(request: request)
    }
}
