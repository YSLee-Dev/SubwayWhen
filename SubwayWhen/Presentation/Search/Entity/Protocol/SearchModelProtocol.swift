//
//  SearchModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift

protocol SearchModelProtocol{
    func fireBaseDefaultViewListLoad() -> Observable<[String]>
    func stationNameSearchRequest(_ name : String) -> Observable<SearchStaion>
    func stationNameMatching(_ searchData : SearchStaion) -> [ResultVCSection]
}
