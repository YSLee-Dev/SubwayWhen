//
//  TabbarVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import UIKit

import Then
import SnapKit

class TabbarVC : UITabBarController{
    let tabbarModel = TabbarModel()
    
    let mainVC = MainVC().then{
        $0.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), tag: 0)
    }
    
    let searchVC = SearchVC(nibName: nil, bundle: nil).then{
        $0.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "magnifyingglass"), tag: 1)
    }
    
    let settingVC = SettingVC(title: "설정", titleViewHeight: 30).then{
        $0.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "gearshape"), tag: 2)
    }
    
    override func viewDidLoad() {
        self.attribute()
        self.viewLoad()
    }
}


extension TabbarVC{
    private func attribute(){
        self.tabBar.backgroundColor = .systemBackground
        self.viewControllers = [UINavigationController(rootViewController: self.mainVC),
                                UINavigationController(rootViewController: self.searchVC),
                                UINavigationController(rootViewController: self.settingVC)
        ]
        
        self.tabBar.itemWidth = 50.0
        self.tabBar.itemPositioning = .centered
    }
    
    private func viewLoad(){
        // 설정 로드
        let result = self.tabbarModel.saveSettingLoad()
        
        switch result{
        case .success():
            print("setting load success")
        case .failure(let error):
            FixInfo.saveSetting = SaveSetting(mainCongestionLabel: "😵", mainGroupOneTime: 0, mainGroupTwoTime: 0, detailAutoReload: true)
            print("setting not load, 초기 값 세팅 완료\n", error)
        }
        
        // 버전 확인
        self.tabbarModel.versionRequest{[weak self] version in
            let nowVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
            
            if nowVersion <= version{
                self?.updateAlertShow()
            }
        }
        
        // 팝업 로드
        self.tabbarModel.popupRequest{[weak self] title, subTitle, contents in
            if title != "Nil"{
                let popup = PopupModal(modalHeight: 400, popupTitle: title, subTitle: subTitle, popupValue: contents)
                popup.modalPresentationStyle = .overFullScreen
                self?.present(popup, animated: false)
            }
        }
    }
    
    private func updateAlertShow(){
        let alert = UIAlertController(title: "버전 업데이트 안내", message: "새로운 버전으로 업데이트 후 앱을 이용해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default){_ in
            print("눌림")
        })
        self.present(alert, animated: true)
    }
}
