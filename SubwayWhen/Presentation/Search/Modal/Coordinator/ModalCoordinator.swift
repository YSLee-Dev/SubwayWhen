//
//  ModalCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/04.
//

import UIKit

class ModalCoordinator: Coordinator {
    var childCoordinator: [Coordinator] = []
    var navigation: UINavigationController
    var data: ResultVCCellData
    var viewModel: ModalViewModel
    var modalVC: ModalVC?
    
    weak var delegate: ModalCoordinatorProtocol?
    
    init(
        navigation: UINavigationController,
        data: ResultVCCellData,
        viewModel: ModalViewModel = ModalViewModel()
    ){
        self.navigation = navigation
        self.data = data
        self.viewModel = viewModel
    }
    
    func start() {
        self.viewModel.delegate = self
        let modal = ModalVC(self.viewModel, modalHeight: 381)
        self.modalVC = modal
        
        self.viewModel.clickCellData.accept(self.data)
        modal.modalPresentationStyle = .overFullScreen
        self.navigation.present(modal, animated: false)
    }
}

extension ModalCoordinator: ModalVCActionProtocol {
    func dismiss() {
        self.delegate?.dismiss()
    }
    
    func overlap() {
        guard let modalVC = self.modalVC else {return}
        let alert = UIAlertController(title: "이미 저장된 지하철역이에요.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel){[weak self] _ in
            self?.viewModel.overlapOkBtnTap.onNext(Void())
        })
        
        modalVC.present(alert, animated: true)
    }
    
    func didDisappear() {
        self.delegate?.didDisappear(modalCoordinator: self)
    }
    
    func stationSave() {
        self.delegate?.stationSave()
    }
    
    func disposableDetailPush(data: DetailSendModel) {
        self.delegate?.disposableDetailPush(data: data)
    }
}
