//
//  EditCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit

class EditCoordinator: Coordinator {
    var childCoordinator: [Coordinator] = []
    var navigation: UINavigationController
    
    var delegate: EditCoordinatorDelegate?
    
    init(navigation: UINavigationController){
        self.navigation = navigation
    }
    
    func start() {
        let editViewModel = EditViewModel()
        let editVC = EditVC(viewModel: editViewModel)
        editVC.hidesBottomBarWhenPushed = true
        editViewModel.delegate = self
        
        self.navigation.pushViewController(editVC, animated: true)
    }
}

extension EditCoordinator : EditVCDelegate{
    func disappear() {
        self.delegate?.disappear(editCoordinatorDelegate: self)
    }
    
    func pop() {
        self.delegate?.pop()
    }
}
