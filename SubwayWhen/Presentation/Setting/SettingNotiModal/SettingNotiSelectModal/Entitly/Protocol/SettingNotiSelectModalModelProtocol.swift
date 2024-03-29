//
//  SettingNotiSelectModalModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/26.
//

import Foundation

import RxSwift

protocol SettingNotiSelectModalModelProtocol {
    func notiSelectList(loadGroup: SaveStationGroup) -> Single<[SaveStation]>
    func saveStationToSectionData(data: [SaveStation], id: String) -> Single<[SettingNotiSelectModalSectionData]>
}
