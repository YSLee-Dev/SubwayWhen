//
//  DetailCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit
import SwiftUI

import ComposableArchitecture

class DetailCoordinator: Coordinator {
    var childCoordinator: [Coordinator] = []
    var navigation : UINavigationController
    var data : DetailSendModel
    let isDisposable: Bool
    
    var delegate : DetailCoordinatorDelegate?
    var store: StoreOf<DetailFeature>?
    
    init(navigation: UINavigationController, data: DetailSendModel, isDisposable: Bool) {
        self.navigation = navigation
        self.data = data
        self.isDisposable = isDisposable
    }
    
    func start() {
        self.store = StoreOf<DetailFeature>(initialState: DetailFeature.State(isDisposable: isDisposable, sendedLoadModel: data), reducer: {
            var feature = DetailFeature()
            feature.coordinatorDelegate = self
            return feature
        })
        
        guard let store = self.store else {return}
        let detailView = DetailView(store: store)
        let vc = UIHostingController(rootView: detailView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {[weak self] in
            if self?.isDisposable ?? false { // 임시인 경우 sheet, 기존 방식은 push
                vc.modalPresentationStyle = .pageSheet
                if let sheet = vc.sheetPresentationController{
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true
                    sheet.preferredCornerRadius = 25
                }
                self?.navigation.present(vc, animated: true)
                
            } else {
                vc.hidesBottomBarWhenPushed = true
                self?.navigation.pushViewController(vc, animated: true)
            }
        }
    }
}

extension DetailCoordinator : DetailVCDelegate{
    func disappear() {
        if self.childCoordinator.isEmpty{
            self.delegate?.disappear(detailCoordinator: self)
        }
    }
    
    func scheduleTap(schduleResultData: ([ResultSchdule], DetailSendModel)) {
        if (schduleResultData.0.first?.type) ?? .Unowned == .Unowned || (schduleResultData.0.first?.startTime) ?? "정보없음"  == "정보없음"  || self.isDisposable {return}
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
        self.navigation.popViewController(animated: true)
        self.childCoordinator = self.childCoordinator.filter{$0 !== detailResultScheduleCoordinator}
        self.store?.send(.exceptionLastStationBtnTapped)
    }
}
