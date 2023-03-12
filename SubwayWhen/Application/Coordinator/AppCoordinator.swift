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
    var model = AppDefaultModel()
    
    init(window : UIWindow){
        self.window = window
        self.window.makeKeyAndVisible()
    }
    
    func start() {
        self.window.rootViewController = self.setTabbarController()
        self.setUp()
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
    
    func setUp(){
        // 설정 로드
        let settingResult = self.model.saveSettingLoad()
        
        switch settingResult{
        case .success():
            print("setting load success")
        case .failure(let error):
            FixInfo.saveSetting = SaveSetting(mainCongestionLabel: "😵", mainGroupOneTime: 0, mainGroupTwoTime: 0, detailAutoReload: true)
            print("setting not load, 초기 값 세팅 완료\n", error)
        }
        
        // 저장된 지하철 로드
        let stationResult = self.model.saveStationLoad()
        
        switch stationResult{
        case .success():
            print("station load success")
        case .failure(let error):
            print("station not load, 초기 값 없음", error)
        }
        
        
        // 버전 확인
        self.model.versionRequest{[weak self] version in
            let nowVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
            
            if nowVersion <= version{
               // 수정 필요
            }
        }
        
        // 팝업 로드
        self.model.popupRequest{[weak self] title, subTitle, contents in
            if title != "Nil"{
                // 수정 필요
            }
        }
    }
}
