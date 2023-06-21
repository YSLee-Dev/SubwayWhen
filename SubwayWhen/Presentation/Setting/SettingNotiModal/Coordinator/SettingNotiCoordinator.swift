//
//  SettingNotiCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/21.
//

import UIKit

class SettingNotiCoordinator: Coordinator {
    var childCoordinator: [Coordinator] = []
    let rootVC: UINavigationController
    let naviagation: UINavigationController
    
    weak var delegate: SettingNotiCoordinatorProtocol?
    
    init (
        rootVC: UINavigationController
    ) {
        self.rootVC = rootVC
        self.naviagation = UINavigationController()
    }
    
    func start() {
        let viewModel = SettingNotiModalViewModel()
        viewModel.delegate = self
        let modal = SettingNotiModalVC(
            modalHeight: 400,
            btnTitle: "저장",
            mainTitle: "출퇴근 알림",
            subTitle: "출퇴근 시간에 맞게 정해놓은 지하철역으로 알림을 주는 기능에요.",
            viewModel: viewModel
        )
        modal.modalPresentationStyle = .overFullScreen
        
        self.rootVC.present(modal, animated: false)
    }
}

extension SettingNotiCoordinator: SettingNotiModalVCAction {
    func didDisappear() {
        self.delegate?.didDisappear(settingNotiCoordinator: self)
    }
    
    func dismiss() {
        self.delegate?.dismiss()
    }
}
