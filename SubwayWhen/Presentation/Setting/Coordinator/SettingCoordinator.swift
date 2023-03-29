//
//  SettingCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit

import AcknowList
 
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
        settingVC.delegate = self
        
        self.naviagation.pushViewController(settingVC, animated: true)
    }
    
}

extension SettingCoordinator : SettingVCDelegate{
    func licensesTap() {
        let vc = AcknowListViewController(fileNamed: "Pods-SubwayWhen-acknowledgements")
        vc.hidesBottomBarWhenPushed = true
        vc.headerText = "SubwayWhen Licenses"
        vc.footerText = "YSLee-Dev"
        self.naviagation.pushViewController(vc, animated: true)
    }
}
