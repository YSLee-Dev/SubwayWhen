//
//  SceneDelegate.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/29.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var appDefaultManager : AppDefaultManager?
    
    var model = AppDefaultModel()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        UINavigationBar.appearance().barTintColor = .systemBackground
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25),
        ]
        
        self.window = UIWindow(windowScene: windowScene)
        self.window?.tintColor = .label
        let appCoordinator = AppCoordinator(window: self.window!)
        appCoordinator.start()
        
        self.appDefaultManager = AppDefaultManager(window: self.window ?? UIWindow())
        
        // 설정 로드
        self.appDefaultManager?.settingLoad()
        
        // 저장된 지하철 로드
        self.appDefaultManager?.stationLoad()
        
        // 인터넷 연결 팝업
        self.appDefaultManager?.networkNotConnectedView()
        
        // 버전 확인
        self.appDefaultManager?.appstoreUpdateAlert()
        
        // 팝업 로드
        self.appDefaultManager?.popup()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        SubwayWhenDetailWidgetManager.shared.stop()
        print("sceneDidDisconnect")
    }
    
    
    
}

