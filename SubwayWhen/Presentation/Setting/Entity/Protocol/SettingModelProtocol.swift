//
//  SettingModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift

protocol SettingModelProtocol{
    func createSettingList() -> Observable<[SettingTableViewCellSection]>
    func indexMatching<T>(index : IndexPath, matchIndex : IndexPath, data : T) -> T?
}
