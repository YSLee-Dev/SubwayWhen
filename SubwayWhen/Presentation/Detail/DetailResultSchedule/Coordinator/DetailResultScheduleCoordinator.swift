//
//  DetailResultScheduleCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit

class DetailResultScheduleCoordinator : Coordinator{
    var childCoordinator: [Coordinator] = []
    var navigation : UINavigationController
    var data : ([ResultSchdule], DetailSendModel)
    
    var delegate : DetailResultScheduleCoorinatorDelegate?
    
    init(navigation : UINavigationController, data : ([ResultSchdule], DetailSendModel)){
        self.navigation = navigation
        self.data = data
    }
    
    func start() {
        let viewModel = DetailResultScheduleViewModel()
        viewModel.scheduleData.accept(self.data.0)
        viewModel.cellData.accept(self.data.1)
        
        let vc = DetailResultScheduleVC(title: "역 시간표", titleViewHeight: 30, viewModel: viewModel)
        vc.delegate = self
        self.navigation.pushViewController(vc, animated: true)
    }
}

extension DetailResultScheduleCoordinator : DetailResultScheduleDelegate{
    func disappear() {
        self.delegate?.disappear(detailResultScheduleCoordinator: self)
    }
    
    func pop() {
        self.delegate?.pop()
    }
    
    func exceptionBtnTap() {
        self.delegate?.exceptionBtnTap(detailResultScheduleCoordinator: self)
    }
}
