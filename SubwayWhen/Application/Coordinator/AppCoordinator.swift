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
    var appDefaultManager : AppDefaultManager?
    
    let bag = DisposeBag()
    
    init(
        window : UIWindow
    ) {
        self.window = window
        self.window.makeKeyAndVisible()
        self.tabbar = UITabBarController()
        
        self.appDefaultManager = AppDefaultManager(window: self.window)
        
        // 노티 로드
        self.notiTapResponse()
        
        // 설정 로드
        self.appDefaultManager?.settingLoad()
        
        // 저장된 지하철 로드
        self.appDefaultManager?.stationLoad()
    }
    
    func start() {
        if (!FixInfo.saveSetting.tutorialSuccess) && FixInfo.saveStation.isEmpty {
            let navigation = UINavigationController()
            navigation.view.backgroundColor = .systemBackground
            navigation.setNavigationBarHidden(true, animated: false)
            
            let tutorialC = TutorialCoordinator(navigationController: navigation)
            self.childCoordinator.append(tutorialC)
            tutorialC.deleagate = self
            
            self.window.rootViewController = navigation
            tutorialC.start()
        } else {
            self.mainLoad()
        }
    }
    
    func setTabbarController() -> UITabBarController{
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        
        let tabbarC = self.tabbar
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
    
    func deepLinkAction(data: SaveStation) {
        guard let mainCoordinator = self.mainCoordinator else {return}
        self.tabbar.selectedIndex = 0
        mainCoordinator.notiTap(saveStation: data)
    }
}

private extension AppCoordinator {
    func notiTapResponse() {
        NotificationManager.shared.notiOpen
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                guard let data = data else {return}
                viewModel.deepLinkAction(data: data)
            })
            .disposed(by: self.bag)
    }

    func mainLoad() {
        let tabbar = self.setTabbarController()
        self.window.rootViewController = tabbar
        FixInfo.saveSetting.tutorialSuccess = true
        
        // 인터넷 연결 팝업
        self.appDefaultManager?.networkNotConnectedView()
        
        // 버전 확인
        self.appDefaultManager?.appstoreUpdateAlert()
        
        // 팝업 로드
        self.appDefaultManager?.popup()
    }
}

extension AppCoordinator : MainCoordinatorDelegate{
    func stationPlusBtnTap(_ coordinator: MainCoordinator) {
        self.tabbar.selectedIndex = 1
    }
}

extension AppCoordinator: TutorialVCCoordinatorProtocol {
    func didDisappear(coordinator: Coordinator) {
        self.childCoordinator = self.childCoordinator.filter {
            $0 !== coordinator
        }
    }
    
    func lastBtnTap() {
        self.mainLoad()
    }
}
