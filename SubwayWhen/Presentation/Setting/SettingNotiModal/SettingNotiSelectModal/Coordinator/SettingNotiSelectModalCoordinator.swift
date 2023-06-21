//
//  SettingNotiSelectCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/21.
//

import UIKit

class SettingNotiSelectCoordinator: Coordinator {
    var childCoordinator: [Coordinator] = []
    var navigation: UINavigationController
    weak var delegate: SettingNotiSelectModalCoordinatorProtocol?
    
    init (
        navigation: UINavigationController
    ) {
        self.navigation = navigation
    }
    
    func start() {
        let viewModel = SettingNotiSelectModalViewModel()
        viewModel.delegate = self
        let selectVC = SettingNotiSelectModalVC(title: "지하철역 선택", titleViewHeight: 30, viewModel: viewModel)
        
        self.navigation.pushViewController(selectVC, animated: true)
    }
}

extension SettingNotiSelectCoordinator: SettingNotiSelectModalVCAction {
    func didDisappear() {
        self.delegate?.didDisappear(settingNotiSelectModalCoordinator: self)
    }
    
    func pop() {
        self.delegate?.pop()
    }
}
