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
    let loadModel = LoadModel()
    
    let mainVC = MainVC().then{
        $0.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 0)
    }
    
    let searchVC = SearchVC(nibName: nil, bundle: nil).then{
        $0.tabBarItem = UITabBarItem(title: "검색", image: UIImage(systemName: "magnifyingglass"), tag: 1)
    }
    
    let settingVC = SettingVC(title: "설정", titleViewHeight: 30).then{
        $0.tabBarItem = UITabBarItem(title: "설정", image: UIImage(systemName: "gearshape"), tag: 2)
    }
    /*
    let mainBG = UIStackView().then{
        $0.backgroundColor = .systemBackground
        $0.layer.borderWidth = 1.0
        $0.layer.borderColor = UIColor.gray.cgColor
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        
        $0.axis = .horizontal
        $0.distribution = .equalCentering
        $0.alignment = .center
        $0.spacing = 20
    }
    
    let homeBtn = TabBarCustomButton().then{
        $0.setImage(UIImage(systemName: "house"), for: .normal)
        $0.seleted(title: "홈")
    }
    
    let searchBtn = TabBarCustomButton().then{
        $0.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
    }
     */
    override func viewDidLoad() {
        self.attribute()
        // self.layout()
        self.tabBar.backgroundColor = .systemBackground
       
        self.viewControllers = [UINavigationController(rootViewController: self.mainVC),
                                UINavigationController(rootViewController: self.searchVC),
                                UINavigationController(rootViewController: self.settingVC)
        ]
    }
}


extension TabbarVC{
    private func attribute(){
        let result = self.loadModel.saveSettingLoad()
        
        switch result{
        case .success():
            print("setting load success")
        case .failure(let error):
            FixInfo.saveSetting = SaveSetting(mainCongestionLabel: "😵", mainGroupTime: 0, detailAutoReload: true)
            print("setting not load", error)
        }
        
        // self.tabBar.isHidden = true
    }
    /*
    private func layout(){
        self.view.addSubview(self.mainBG)
        self.mainBG.addArrangedSubview(self.homeBtn)
        self.mainBG.addArrangedSubview(self.searchBtn)
        
        self.mainBG.snp.makeConstraints{
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(50)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
     */
}

