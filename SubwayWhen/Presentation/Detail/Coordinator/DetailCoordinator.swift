//
//  DetailCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit
import SwiftUI

import ComposableArchitecture
import RxSwift

class DetailCoordinator: Coordinator {
    var childCoordinator: [Coordinator] = []
    var navigation : UINavigationController
    var data : MainTableViewCellData
    
    var delegate : DetailCoordinatorDelegate?
    
    let exceptionLastStationRemoveBtnClick = PublishSubject<Void>()
    let isDisposable: Bool
    
    init(navigation : UINavigationController, data : MainTableViewCellData, isDisposable: Bool){
        self.navigation = navigation
        self.data = data
        self.isDisposable = isDisposable
    }
    
    func start() {
        var excption = self.data
        
        // 공항철도는 반대 (ID)
        if excption.useLine == "공항철도"{
            let next = excption.nextStationId
            excption.nextStationId = excption.backStationId
            excption.backStationId = next
        }
        let detailSendModel = DetailSendModel(upDown: excption.upDown, stationName: excption.stationName, lineNumber: excption.lineNumber, stationCode: excption.stationCode, lineCode: excption.subWayId, exceptionLastStation: excption.exceptionLastStation, korailCode: excption.korailCode)
        let detailView = DetailView(store: .init(initialState: DetailFeature.State(sendedLoadModel: detailSendModel), reducer: {
            var feature = DetailFeature()
            feature.coordinatorDelegate = self
            return feature
        }))
        
        let vc = UIHostingController(rootView: detailView)
        vc.hidesBottomBarWhenPushed = true
        self.navigation.pushViewController(vc, animated: true)
    }
}

extension DetailCoordinator : DetailVCDelegate{
    func disappear() {
        if self.childCoordinator.isEmpty{
            self.delegate?.disappear(detailCoordinator: self)
        }
    }
    
    func scheduleTap(schduleResultData: ([ResultSchdule], DetailSendModel)) {
        if (schduleResultData.0.first?.type) ?? .Unowned == .Unowned || (schduleResultData.0.first?.startTime) ?? "정보없음"  == "정보없음"  {return}
        let resultScheduleCoordinator = DetailResultScheduleCoordinator(navigation: self.navigation, data: schduleResultData)
        resultScheduleCoordinator.start()
        resultScheduleCoordinator.delegate = self
        
        self.childCoordinator.append(resultScheduleCoordinator)
    }
    
    func pop() {
        self.delegate?.pop()
    }
}

extension DetailCoordinator: DetailResultScheduleCoorinatorDelegate {
    func disappear(detailResultScheduleCoordinator: DetailResultScheduleCoordinator) {
        self.childCoordinator = self.childCoordinator.filter{$0 !== detailResultScheduleCoordinator}
    }
    
    func pop(detailResultScheduleCoordinator: DetailResultScheduleCoordinator) {
        self.navigation.popViewController(animated: true)
    }
    
    func exceptionBtnTap(detailResultScheduleCoordinator: DetailResultScheduleCoordinator) {
//        self.navigation.popViewController(animated: true)
//        self.vc!.detailViewModel.headerViewModel.exceptionLastStationBtnClick.accept(Void())
//        self.childCoordinator = self.childCoordinator.filter{$0 !== detailResultScheduleCoordinator}
    }
}
