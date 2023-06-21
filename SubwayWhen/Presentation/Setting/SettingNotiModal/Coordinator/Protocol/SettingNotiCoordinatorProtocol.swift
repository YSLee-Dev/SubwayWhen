//
//  SettingNotiCoordinatorProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/21.
//

import Foundation

protocol SettingNotiCoordinatorProtocol: AnyObject {
    func didDisappear(settingNotiCoordinator: Coordinator)
    func dismiss()
}
