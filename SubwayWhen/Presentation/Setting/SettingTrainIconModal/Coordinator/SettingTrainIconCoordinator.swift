//
//  SettingTrainIconModalCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2/9/24.
//

import UIKit

class SettingTrainIconModalCoordinator: Coordinator {
    private let navigation: UINavigationController
    var childCoordinator: [Coordinator] = []
    
    weak var delegate: SettingTrainIconCoordinatorProtocol?
    
    init(
        navigation: UINavigationController
    ) {
        self.navigation = navigation
    }
    
    func start() {
        let subViewModel = SettingTrainIconModalSubViewModel()
        let viewModel = SettingTrainIconModalViewModel(subViewModel: subViewModel)
        viewModel.delegate = self
        
        let vc = SettingTrainIconModalVC(
            modalHeight: 440,
            btnTitle: Strings.Common.save,
            mainTitle: Strings.Setting.trainIcon,
            subTitle: Strings.Setting.trainIconDescription,
            viewModel: viewModel,
            modalView: SettingTrainIconModalView(viewModel: subViewModel)
        )
        vc.modalPresentationStyle = .overFullScreen
        self.navigation.present(vc, animated: false)
    }
}

extension SettingTrainIconModalCoordinator: SettingTrainIconModalVCAction {
    func didDisappear() {
        self.delegate?.didDisappear(coordinator: self)
    }
    
    func dismiss() {
        self.delegate?.dismiss()
    }
}
