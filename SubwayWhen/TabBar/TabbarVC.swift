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
    let mainVC = MainVC().then{
            $0.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 0)
        }
        
        let searchVC = SearchVC().then{
            $0.tabBarItem = UITabBarItem(title: "검색", image: UIImage(systemName: "magnifyingglass"), tag: 0)
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
        // self.attribute()
        // self.layout()
        self.searchVC.bind(SearchViewModel())
       
        self.viewControllers = [UINavigationController(rootViewController: self.mainVC), UINavigationController(rootViewController: self.searchVC)]
    }
}

/*
extension TabbarVC{
    private func attribute(){
        self.tabBar.isHidden = true
    }
    
    private func layout(){
        self.view.addSubview(self.mainBG)
        self.mainBG.addArrangedSubview(self.homeBtn)
        self.mainBG.addArrangedSubview(self.searchBtn)
        
        self.mainBG.snp.makeConstraints{
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(50)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
*/
