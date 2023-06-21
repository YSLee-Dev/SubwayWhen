//
//  SettingNotiSelectModalCoordinatorProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/21.
//

import Foundation

protocol SettingNotiSelectModalCoordinatorProtocol: AnyObject {
    func didDisappear(settingNotiSelectModalCoordinator: Coordinator)
    func pop()
}
