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
    var naviagation: UINavigationController?
    
    weak var delegate: SettingNotiCoordinatorProtocol?
    
    init (
        rootVC: UINavigationController
    ) {
        self.rootVC = rootVC
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
        
        self.naviagation = UINavigationController(rootViewController: modal)
        
        guard let naviagation = self.naviagation else {return}
        naviagation.modalPresentationStyle = .overFullScreen
        
        self.rootVC.present(naviagation, animated: false)
    }
}

extension SettingNotiCoordinator: SettingNotiModalVCAction {
    func stationTap(type: Bool) {
        guard let naviagation = self.naviagation else {return}
        let selectModalCoordinator = SettingNotiSelectCoordinator(navigation: naviagation)
        selectModalCoordinator.delegate = self
        selectModalCoordinator.start()
      
        self.childCoordinator.append(selectModalCoordinator)
    }
    
    func didDisappear() {
        if self.childCoordinator.isEmpty {
            self.delegate?.didDisappear(settingNotiCoordinator: self)
        }
    }
    
    func dismiss() {
        self.delegate?.dismiss()
    }
}

extension SettingNotiCoordinator: SettingNotiSelectModalCoordinatorProtocol {
    func didDisappear(settingNotiSelectModalCoordinator: Coordinator) {
        self.childCoordinator = self.childCoordinator.filter{
            $0 !== settingNotiSelectModalCoordinator
        }
    }
    
    func pop() {
        self.naviagation?.popViewController(animated: true)
    }
}
