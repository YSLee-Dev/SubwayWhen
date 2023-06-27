//
//  SettingNotiModalVCAction.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/21.
//

import Foundation

protocol SettingNotiModalVCAction: AnyObject {
    func didDisappear()
    func dismiss()
    func stationTap(type: SaveStationGroup, id: String)
}
