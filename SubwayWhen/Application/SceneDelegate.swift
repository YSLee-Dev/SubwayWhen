//
//  SceneDelegate.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/29.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var model = AppDefaultModel()
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25),
        ]
        
        self.window = UIWindow(windowScene: windowScene)
        let appCoordinator = AppCoordinator(window: self.window!)
        appCoordinator.start()
        
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
                let alert = UIAlertController(title: "업데이트 안내", message: "새로운 버전으로 업데이트 후 앱을 이용해주세요!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .cancel){ _ in
                    // 앱스토어 구문
                })
                self?.window?.rootViewController?.children.first?.children.first?.present(alert, animated: true)
            }
        }
        
        // 팝업 로드
        self.model.popupRequest{[weak self] title, subTitle, contents in
            if title != "Nil"{
                let popup = PopupModal(modalHeight: 400, popupTitle: title, subTitle: subTitle, popupValue: contents)
                popup.modalPresentationStyle = .overFullScreen
                self?.window?.rootViewController?.children.first?.children.first?.present(popup, animated: false)
            }
        }
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // 백그라운드에서 돌아올 때 메인 뷰 업데이트
        // RootVC > NavigationC > MainVC
        let root = self.window?.rootViewController?.children.first?.children.first
        root?.viewWillAppear(true)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

