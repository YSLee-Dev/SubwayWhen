//
//  DetailCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit

import RxSwift

class DetailCoordinator : Coordinator{
    var childCoordinator: [Coordinator] = []
    var navigation : UINavigationController
    var data : MainTableViewCellData
    
    var delegate : DetailCoordinatorDelegate?
    weak var vc : DetailVC?
    let bag = DisposeBag()
    
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
        let detailLoadData = DetailLoadData(upDown: excption.upDown, stationName: excption.stationName, lineNumber: excption.lineNumber, lineCode: excption.subWayId, useLine: excption.useLine, stationCode: excption.stationCode, exceptionLastStation: excption.exceptionLastStation, backStationId: excption.backStationId, nextStationId: excption.nextStationId, korailCode: excption.korailCode)
        
        let viewModel = DetailViewModel(isDisposable: self.isDisposable)
        viewModel.detailViewData.accept(detailLoadData)
        self.exceptionLastStationRemoveBtnClick
            .bind(to: viewModel.exceptionLastStationRemoveReload)
            .disposed(by: self.bag)
        viewModel.delegate = self
        
        let vc = DetailVC(title: "\(excption.useLine) \(excption.stationName)", viewModel: viewModel)
        vc.hidesBottomBarWhenPushed = true
        
        self.vc = vc
        
        self.navigation.pushViewController(vc, animated: true)
    }
}

private extension DetailCoordinator {
    func exceptionLastStationRemoveAlert(station: String) {
        let alert = UIAlertController(
            title: "\(station)행을 포함해서 재로딩 하시겠어요?\n재로딩은 일회성으로, 저장하지 않아요.",
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "재로딩", style: .default) { [weak self] _ in
            self?.exceptionLastStationRemoveBtnClick.onNext(Void())
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        self.navigation.present(alert, animated: true)
    }
}

extension DetailCoordinator : DetailVCDelegate{
    func exceptionLastStationPopup(station: String) {
        self.exceptionLastStationRemoveAlert(station: station)
    }
    
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
