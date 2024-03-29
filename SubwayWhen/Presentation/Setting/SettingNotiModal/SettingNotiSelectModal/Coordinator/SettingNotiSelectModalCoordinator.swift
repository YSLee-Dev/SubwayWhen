//
//  SettingNotiSelectCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/21.
//

import UIKit

class SettingNotiSelectCoordinator: Coordinator {
    var childCoordinator: [Coordinator] = []
    weak var delegate: SettingNotiSelectModalCoordinatorProtocol?

    var navigation: UINavigationController
    let group: SaveStationGroup
    let id: String
    
    init (
        navigation: UINavigationController,
        group: SaveStationGroup,
        id: String
    ) {
        self.navigation = navigation
        self.group = group
        self.id = id
    }
    
    func start() {
        let model = SettingNotiSelectModalModel()
        let viewModel = SettingNotiSelectModalViewModel(settingNotiSelectModalModel: model, group: self.group, id: id)
        viewModel.delegate = self
        
        let title = self.group == .one ? "출근" : "퇴근"
        let selectVC = SettingNotiSelectModalVC(title: "\(title)알림", titleViewHeight: 30, viewModel: viewModel)
        
        
        self.navigation.pushViewController(selectVC, animated: true)
    }
}

extension SettingNotiSelectCoordinator: SettingNotiSelectModalVCAction {
    func stationTap(item: SettingNotiSelectModalCellData, group: SaveStationGroup) {
        self.delegate?.stationTap(item: item, group: group)
    }
    
    func didDisappear() {
        self.delegate?.didDisappear(settingNotiSelectModalCoordinator: self)
    }
    
    func pop() {
        self.delegate?.pop()
    }
}
