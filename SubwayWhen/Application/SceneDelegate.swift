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
        
        // 네트워크 감지 class
        NetworkMonitor.shared.monitorStart()
        
        // 딥링크 처리
        self.deepLinkMove(url: connectionOptions.urlContexts.first?.url)
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // 뱃지 제거
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        SubwayWhenDetailWidgetManager.shared.stop()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        self.deepLinkMove(url: URLContexts.first?.url)
    }
}

private extension SceneDelegate {
    func deepLinkMove(url: URL?) {
        guard let url = url,
              let urlString = url.absoluteString.removingPercentEncoding,
              let startIndex = urlString.lastIndex(of: "=") // text = 부분만 추출
        else {return}
         
        let deepLinkText = String(urlString[urlString.index(after: startIndex) ..< urlString.endIndex])
        let seletedStation = FixInfo.saveStation.filter {$0.widgetUseText == deepLinkText}.first
        
        if let seletedStation = seletedStation {
            self.appCoordinator?.deepLinkAction(data: seletedStation)
        }
    }
}
