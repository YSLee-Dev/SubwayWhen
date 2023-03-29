//
//  SearchCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit

class SearchCoordinator : Coordinator{
    var childCoordinator: [Coordinator] = []
    var navigation : UINavigationController
    
    init(){
        self.navigation = .init()
    }
    
    func start() {
        let search = SearchVC(viewModel: SearchViewModel())
        search.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "magnifyingglass"), tag: 1)
        self.navigation.pushViewController(search, animated: true)
    }
}
