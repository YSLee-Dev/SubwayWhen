//
//  AppCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit

class AppCoordinator : Coordinator{
    var childCoordinator: [Coordinator] = []
    var window : UIWindow
    var tabbar : UITabBarController
    
    init(window : UIWindow){
        self.window = window
        self.window.makeKeyAndVisible()
        self.tabbar = UITabBarController()
    }
    
    func start() {
        self.tabbar = self.setTabbarController()
        self.window.rootViewController = self.tabbar
    }
    
    func setTabbarController() -> UITabBarController{
        let tabbarC = UITabBarController()
        tabbarC.tabBar.itemWidth = 50.0
        tabbarC.tabBar.itemPositioning = .centered
        tabbarC.tabBar.tintColor = UIColor(named: "AppIconColor")
        
        let mainC = MainCoordinator()
        mainC.delegate = self
        self.childCoordinator.append(mainC)
        
        mainC.start()
        
        let searchC = SearchCoordinator()
        self.childCoordinator.append(searchC)
        
        searchC.start()
        
        let settingC = SettingCoordinator()
        self.childCoordinator.append(searchC)
        
        settingC.start()
        
        tabbarC.viewControllers = [mainC.navigation, searchC.navigation, settingC.naviagation]
        
        return tabbarC
    }
}

extension AppCoordinator : MainCoordinatorDelegate{
    func stationPlusBtnTap(_ coordinator: MainCoordinator) {
        self.tabbar.selectedIndex = 1
    }
}
