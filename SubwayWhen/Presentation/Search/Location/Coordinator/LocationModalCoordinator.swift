//
//  LocationModalCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/05.
//

import UIKit

class LocationModalCoordinator: Coordinator {
    var childCoordinator: [Coordinator] = []
    var navigation: UINavigationController
    
    weak var delegate: LocationModalCoordinatorProtocol?
    
    init(
        navigation: UINavigationController
    ) {
        self.navigation = navigation
    }
    
    func start() {
        let viewModel = LocationModalViewModel()
        viewModel.delegate = self
        let locationModal = LocationModalVC(modalHeight: 500, btnTitle: "닫기", mainTitle: "가까운 지하철역 찾기", subTitle: "현재 위치에 기반하여 3km 이내 지하철역을 찾을 수 있어요.", viewModel: viewModel)
        
        locationModal.modalPresentationStyle = .overFullScreen
        self.navigation.present(locationModal, animated: false)
    }
}

extension LocationModalCoordinator: LocationModalVCActionProtocol {
    func stationTap(stationName: String) {
        self.delegate?.stationTap(stationName: stationName)
    }
    
    func dismiss() {
        self.delegate?.dismiss()
    }
    
    func didDisappear() {
        self.delegate?.didDisappear(locationModalCoordinator: self)
    }
}
