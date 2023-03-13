//
//  DetailCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit

class DetailCoordinator : Coordinator{
    var childCoordinator: [Coordinator] = []
    var navigation : UINavigationController
    var data : MainTableViewCellData
    
    var delegate : DetailCoordinatorDelegate?
    weak var vc : DetailVC?
    
    init(navigation : UINavigationController, data : MainTableViewCellData){
        self.navigation = navigation
        self.data = data
    }
    
    func start() {
        var excption = self.data
        
        // 공항철도는 반대 (ID)
        if excption.useLine == "공항철도"{
            let next = excption.nextStationId
            excption.nextStationId = excption.backStationId
            excption.backStationId = next
        }
        
        let viewModel = DetailViewModel()
        viewModel.detailViewData.accept(excption)
        
        let vc = DetailVC(title: "\(excption.useLine) \(excption.stationName)", viewModel: viewModel)
        vc.delegate = self
        vc.hidesBottomBarWhenPushed = true
        
        self.vc = vc
        
        self.navigation.pushViewController(vc, animated: true)
    }
}

extension DetailCoordinator : DetailVCDelegate{
    func disappear() {
        if self.childCoordinator.isEmpty{
            self.delegate?.disappear(detailCoordinator: self)
        }
    }
    
    func scheduleTap(schduleResultData: schduleResultData) {
        let resultScheduleCoordinator = DetailResultScheduleCoordinator(navigation: self.navigation, data: schduleResultData)
        resultScheduleCoordinator.start()
        resultScheduleCoordinator.delegate = self
        
        self.childCoordinator.append(resultScheduleCoordinator)
    }
    
    func pop() {
        self.delegate?.pop()
    }
}

extension DetailCoordinator : DetailResultScheduleCoorinatorDelegate{
    func disappear(detailResultScheduleCoordinator: DetailResultScheduleCoordinator) {
        self.childCoordinator = self.childCoordinator.filter{$0 !== detailResultScheduleCoordinator}
    }
    
    func pop(detailResultScheduleCoordinator: DetailResultScheduleCoordinator) {
        self.navigation.popViewController(animated: true)
    }
    
    func exceptionBtnTap(detailResultScheduleCoordinator: DetailResultScheduleCoordinator) {
        self.navigation.popViewController(animated: true)
        self.vc!.detailViewModel.headerViewModel.exceptionLastStationBtnClick.accept(Void())
        self.childCoordinator = self.childCoordinator.filter{$0 !== detailResultScheduleCoordinator}
    }
}
