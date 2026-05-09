//
//  ReportCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit
import SwiftUI
import ComposableArchitecture

class ReportCoordinator : Coordinator{
    var childCoordinator: [Coordinator] = []
    var navigation : UINavigationController
    
    var delegate : ReportCoordinatorDelegate?
    private var seletedLine: SubwayLineData? = nil
    private var stationName: String? = nil
    
    init(navigation : UINavigationController, initValue: (SubwayLineData?, String?)? = nil){
        self.navigation = navigation
        self.seletedLine = initValue?.0
        self.stationName = initValue?.1
    }

    deinit {
        AppLogger.coordinator.log(.debug, "ReportCoordinator deinit")
    }

    func start() {
        let reportView = ReportView(store: .init(initialState: .init(selectedLine: self.seletedLine, stationName: self.stationName), reducer: {
            var reducer = ReportFeature()
            reducer.delegate = self
            return reducer
        }))
        
        let reportVC = UIHostingController(rootView: reportView)
        reportVC.hidesBottomBarWhenPushed = true
        navigation.pushViewController(reportVC, animated: true)
    }
}

extension ReportCoordinator : ReportVCDelegate {
    func disappear() {
        self.delegate?.disappear(reportCoordinator: self)
    }
    
    func pop() {
        self.delegate?.pop()
    }
    
    func moveToReportCheck(data: ReportMSGData) {
        let check = ReportCheckModalVC(modalHeight: 520, viewModel: .init(data: data, dismissHandler: { [weak self] in
            self?.pop()
        }))
        check.modalPresentationStyle = .overFullScreen
        self.navigation.present(check, animated: false)
    }
}
