//
//  SceneDelegate.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/29.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    var model = AppDefaultModel()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // 네비게이션 바
        UINavigationBar.appearance().barTintColor = .systemBackground
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25),
        ]
        
        // UIWindow, Coordinator 세팅
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        self.window?.tintColor = .label
        
        // App Coordinator 선언
        self.appCoordinator = AppCoordinator(window: self.window!)
        self.appCoordinator?.start()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // 뱃지 제거
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        SubwayWhenDetailWidgetManager.shared.stop()
    }
}

