//
//  AppCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit

import RxSwift
import RxCocoa

class AppCoordinator : Coordinator{
    var childCoordinator: [Coordinator] = []
    var window : UIWindow
    var tabbar : UITabBarController
    
    var mainCoordinator: MainCoordinator?
    
    let bag = DisposeBag()
    
    init(window : UIWindow){
        self.window = window
        self.window.makeKeyAndVisible()
        self.tabbar = UITabBarController()
    }
    
    func start() {
        self.tabbar = self.setTabbarController()
        self.window.rootViewController = self.tabbar
        
        self.notiTapResponse()
    }
    
    func setTabbarController() -> UITabBarController{
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        
        let tabbarC = UITabBarController()
        tabbarC.tabBar.itemWidth = 50.0
        tabbarC.tabBar.itemPositioning = .centered
        tabbarC.tabBar.backgroundColor = .systemBackground
        tabbarC.tabBar.tintColor = UIColor(named: "AppIconColor")
        
        let mainC = MainCoordinator()
        mainC.delegate = self
        self.childCoordinator.append(mainC)
        
        mainC.start()
        
        self.mainCoordinator = mainC
        
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

private extension AppCoordinator {
    func notiTapResponse() {
        NotificationManager.shared.notiOpen
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                guard let data = data else {return}
                viewModel.notiTapAction(data: data)
            })
            .disposed(by: self.bag)
    }
    
    func notiTapAction(data: SaveStation) {
        guard let mainCoordinator = self.mainCoordinator else {return}
        self.tabbar.selectedIndex = 0
        mainCoordinator.notiTap(saveStation: data)
    }
}
