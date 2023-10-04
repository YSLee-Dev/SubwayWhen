//
//  AppDefaultManager.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/23.
//

import UIKit

class AppDefaultManager{
    let window : UIWindow
    let model : AppDefaultModelProtocol
    
    init(window: UIWindow, model : AppDefaultModel = .init()) {
        self.window = window
        self.model = model
    }
}

extension AppDefaultManager{
    func appstoreUpdateAlert(){
        self.model.versionRequest{[weak self] version in
            let nowVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
            
            if nowVersion <= version{
                let popup = PopupModal(modalHeight: 400, popupTitle: "업데이트 안내", subTitle: "새로운 버전으로 업데이트 후 앱을 이용해주세요!",iconName: "Report", isUpdate: true)
                popup.modalPresentationStyle = .overFullScreen
                self?.window.rootViewController?.children.first?.children.first?.present(popup, animated: false)
            }
        }
    }
    
    func popup(){
        self.model.popupRequest{[weak self] title, subTitle, contents in
            if title != "Nil"{
                let popup = PopupModal(modalHeight: 400, popupTitle: title, subTitle: subTitle, popupValue: contents)
                popup.modalPresentationStyle = .overFullScreen
                self?.window.rootViewController?.children.first?.children.first?.present(popup, animated: false)
            }
        }
    }
    
    func networkNotConnectedView(){
        let noNetworkView = NoNetworkView()
    
        self.window.addSubview(noNetworkView)
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
            self?.window.layoutIfNeeded()
        }
    }
    
    func settingLoad(){
        let settingResult = self.model.saveSettingLoad()
        
        switch settingResult{
        case .success(let setting):
            FixInfo.saveSetting = setting
            print("setting load success")
        case .failure(let error):
            FixInfo.saveSetting = SaveSetting(
                mainCongestionLabel: "☹️",
                mainGroupOneTime: 0,
                mainGroupTwoTime: 0,
                detailAutoReload: true,
                detailScheduleAutoTime: true,
                liveActivity: true,
                searchOverlapAlert : true,
                alertGroupOneID: "",
                alertGroupTwoID: "",
                tutorialSuccess: false
            )
            print("setting not load, 초기 값 세팅 완료\n", error)
        }
    }
    
    func stationLoad(){
        let stationResult = self.model.saveStationLoad()
        
        switch stationResult{
        case .success(let list):
            FixInfo.saveStation = list
            print("station load success")
        case .failure(let error):
            print("station not load, 초기 값 없음", error)
        }
    }
}
