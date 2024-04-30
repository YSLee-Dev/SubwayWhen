//
//  NetworkManagerProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/03.
//

import Foundation

import RxSwift

protocol NetworkManagerProtocol{
    func requestData<T : Decodable>(_ url :String, dataType: T.Type) -> Single<Result<T,URLError>>
    func requestData<T: Decodable>(_ url: String, decodingType: T.Type, headers: [[String: String]], queryList: [[String: String]]) -> Single<Result<T,URLError>>
}
