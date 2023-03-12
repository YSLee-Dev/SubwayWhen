//
//  SettingCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit
 
class SettingCoordinator : Coordinator{
    weak var parentCoordinator : Coordinator?
    var childCoordinator: [Coordinator] = []
    var naviagation : UINavigationController
    
    init(){
        self.naviagation = .init()
    }
    
    func start() {
        let settingVC = SettingVC(viewModel: SettingViewModel())
        settingVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "gearshape"), tag: 2)
        self.naviagation.pushViewController(settingVC, animated: true)
    }
    
}
