//
//  MainCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit

class MainCoordinator : Coordinator{
    var childCoordinator: [Coordinator] = []{
        didSet{
            print(self.childCoordinator)
        }
    }
    var navigation : UINavigationController
    var delegate : MainCoordinatorDelegate?
    
    init(){
        self.navigation = UINavigationController()
    }
    
    func start() {
        let main = MainVC(viewModel: MainViewModel())
        main.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), tag: 0)
        main.delegate = self
        self.navigation.setViewControllers([main], animated: true)
    }
}

extension MainCoordinator : MainDelegate{
    func plusStationTap() {
        self.delegate?.stationPlusBtnTap(self)
    }
    
    func pushTap(action : MainCoordinatorAction) {
        switch action{
        case .Report:
            let report = ReportCoordinator(navigation: self.navigation)
            self.childCoordinator.append(report)
            report.delegate = self
          
            report.start()
        case .Edit:
            let edit = EditCoordinator(navigation: self.navigation)
            self.childCoordinator.append(edit)
            edit.delegate = self
          
            edit.start()
        }
    }
    
    func pushDetailTap(data: MainTableViewCellData) {
        let detail = DetailCoordinator(navigation: self.navigation, data: data)
        self.childCoordinator.append(detail)
        detail.delegate = self
        
        detail.start()
    }
}

extension MainCoordinator : ReportCoordinatorDelegate{
    func pop() {
        self.navigation.popViewController(animated: true)
    }
    
    func disappear(reportCoordinator: ReportCoordinator) {
        self.childCoordinator = self.childCoordinator.filter{$0 !== reportCoordinator}
    }
}

extension MainCoordinator : EditCoordinatorDelegate{
    func disappear(editCoordinatorDelegate: EditCoordinator) {
        self.childCoordinator = self.childCoordinator.filter{$0 !== editCoordinatorDelegate}
    }
}

extension MainCoordinator : DetailCoordinatorDelegate{
    func disappear(detailCoordinator: DetailCoordinator) {
        self.childCoordinator = self.childCoordinator.filter{$0 !== detailCoordinator}
    }
}
