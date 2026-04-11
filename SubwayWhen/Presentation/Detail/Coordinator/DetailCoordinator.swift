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
        guard let vc = self.createDetailVC() else {return}
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {[weak self] in
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
    
    func createDetailVC() -> UIViewController? {
        self.store = StoreOf<DetailFeature>(initialState: DetailFeature.State(isDisposable: isDisposable, sendedLoadModel: data), reducer: {
            var feature = DetailFeature()
            feature.coordinatorDelegate = self
            return feature
        })
        
        guard let store = self.store else {return nil}
        let detailView = DetailView(store: store)
        return UIHostingController(rootView: detailView)
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
    
    func reportBtnTap(reportLine: SubwayLineData, stationName: String) {
        self.pop()
        self.delegate?.reportBtnTap(reportLine: reportLine, stationName: stationName)
    }

    func pushRealtime(subwayLine: SubwayLineData, stationName: String, isUp: Bool) {
        let realtimeCoordinator = RealtimeCoordinator(navigation: self.navigation, subwayLine: subwayLine, stationName: stationName, isUp: isUp)
        realtimeCoordinator.start()
        self.childCoordinator.append(realtimeCoordinator)
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
