//
//  ReportCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit

class ReportCoordinator : Coordinator{
    var childCoordinator: [Coordinator] = []
    var navigation : UINavigationController
    
    var delegate : ReportCoordinatorDelegate?
    
    init(navigation : UINavigationController){
        self.navigation = navigation
    }
    
    func start() {
        let reportVC = ReportVC(viewModel: ReportViewModel())
        reportVC.hidesBottomBarWhenPushed = true
        reportVC.delegate = self
        navigation.pushViewController(reportVC, animated: true)
    }
}

extension ReportCoordinator : ReportVCDelegate{
    func disappear() {
        self.delegate?.disappear(reportCoordinator: self)
    }
    
    func pop() {
        self.delegate?.pop()
    }
}
