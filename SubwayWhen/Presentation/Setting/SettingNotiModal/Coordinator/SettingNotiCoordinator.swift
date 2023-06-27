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
    var viewModel: SettingNotiModalViewModel?
    
    weak var delegate: SettingNotiCoordinatorProtocol?
    
    init (
        rootVC: UINavigationController
    ) {
        self.rootVC = rootVC
    }
    
    func start() {
        let model = SettingNotiModalModel()
        let viewModel = SettingNotiModalViewModel(model: model)
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
        
        self.viewModel = viewModel
        
        self.rootVC.present(naviagation, animated: false)
    }
}

extension SettingNotiCoordinator: SettingNotiModalVCAction {
    func stationTap(type: SaveStationGroup, id: String) {
        guard let naviagation = self.naviagation else {return}
        
        let selectModalCoordinator = SettingNotiSelectCoordinator(navigation: naviagation, group: type, id: id)
        
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
    func stationTap(item: SettingNotiSelectModalCellData, group: SaveStationGroup) {
        guard let viewModel = self.viewModel else {return}
        
        let item = SettingNotiModalData(id: item.id, stationName: item.stationName, useLine: item.useLine, line: item.line, group: group)
        if group == .one {
            viewModel.oneStationTap.onNext(item)
        } else {
            viewModel.twoStationTap.onNext(item)
        }
        
        self.naviagation?.popViewController(animated: true)
    }
    
    func didDisappear(settingNotiSelectModalCoordinator: Coordinator) {
        self.childCoordinator = self.childCoordinator.filter{
            $0 !== settingNotiSelectModalCoordinator
        }
    }
    
    func pop() {
        self.naviagation?.popViewController(animated: true)
    }
}
