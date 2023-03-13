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
    
    init(window : UIWindow){
        self.window = window
        self.window.makeKeyAndVisible()
    }
    
    func start() {
        self.window.rootViewController = self.setTabbarController()
    }
    
    func setTabbarController() -> UITabBarController{
        let tabbarC = UITabBarController()
        tabbarC.tabBar.itemWidth = 50.0
        tabbarC.tabBar.itemPositioning = .centered
        tabbarC.tabBar.tintColor = .black
        
        let mainC = MainCoordinator()
        mainC.parentCoordinator = self
        self.childCoordinator.append(mainC)
        
        mainC.start()
        
        let searchC = SearchCoordinator()
        searchC.parentCoordinator = self
        self.childCoordinator.append(searchC)
        
        searchC.start()
        
        let settingC = SettingCoordinator()
        searchC.parentCoordinator = self
        self.childCoordinator.append(searchC)
        
        settingC.start()
        
        tabbarC.viewControllers = [mainC.navigation, searchC.navigation, settingC.naviagation]
        
        return tabbarC
    }
}
