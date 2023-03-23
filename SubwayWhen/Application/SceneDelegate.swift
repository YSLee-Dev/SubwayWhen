//
//  SceneDelegate.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/29.
//

import UIKit

import SnapKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var model = AppDefaultModel()
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25),
        ]
        
        self.window = UIWindow(windowScene: windowScene)
        self.window?.tintColor = .label
        let appCoordinator = AppCoordinator(window: self.window!)
        appCoordinator.start()
        
        // 설정 로드
        let settingResult = self.model.saveSettingLoad()
        
        switch settingResult{
        case .success():
            print("setting load success")
        case .failure(let error):
            FixInfo.saveSetting = SaveSetting(mainCongestionLabel: "☹️", mainGroupOneTime: 0, mainGroupTwoTime: 0, detailAutoReload: true, detailScheduleAutoTime: true, searchOverlapAlert : true)
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
        
        // 인터넷 연결 팝업
        let noNetworkView = NoNetworkView()
    
        self.window?.addSubview(noNetworkView)
        noNetworkView.snp.makeConstraints{
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        
        // 앱 진입 시 바로
        if !NetworkMonitor.shared.isConnected{
            noNetworkView.snp.updateConstraints{
                $0.height.equalTo(100)
            }
        }
            
        NetworkMonitor.shared.pathUpdate{ [weak self] status in
            if !status{
                noNetworkView.snp.updateConstraints{
                    $0.height.equalTo(100)
                }
            }else{
                noNetworkView.snp.updateConstraints{
                    $0.height.equalTo(0)
                }
            }
            self?.window?.layoutIfNeeded()
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
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // 백그라운드에서 돌아올 때 메인 뷰 업데이트
        // RootVC > NavigationC > MainVC
        let root = self.window?.rootViewController?.children.first?.children.first
        root?.viewWillAppear(true)
    }
}

