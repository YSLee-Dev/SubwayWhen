//
//  SettingCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit

import AcknowList
 
class SettingCoordinator : Coordinator{
    var childCoordinator: [Coordinator] = []
    var naviagation : UINavigationController
    
    init(){
        self.naviagation = .init()
    }
    
    func start() {
        let viewModel = SettingViewModel()
        viewModel.delegate = self
        let settingVC = SettingVC(viewModel: viewModel)
        settingVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "gearshape"), tag: 2)
        
        self.naviagation.pushViewController(settingVC, animated: true)
    }
    
}

extension SettingCoordinator: SettingVCAction {
    func groupModal() {
        let viewModel = SettingGroupModalViewModel()
        let modal = SettingGroupModalVC(modalHeight: 405, btnTitle: "저장", mainTitle: "특정 그룹 시간", subTitle: "정해진 시간에 맞게 출,퇴근 그룹을 자동으로 변경해주는 기능이에요.", viewModel: viewModel)
        modal.modalPresentationStyle = .overFullScreen
        
        self.naviagation.present(modal, animated: false)
    }
    
    func notiModal() {
        print("NOTI")
    }
    
    func contentsModal() {
        let viewModel = SettingContentsModalViewModel()
        let modal = SettingContentsModalVC(modalHeight: 400, btnTitle: "닫기", mainTitle: "기타", subTitle: "저작권 및 데이터 출처를 표시하는 공간이에요.", viewModel: viewModel)
        modal.modalPresentationStyle = .overFullScreen
        
        self.naviagation.present(modal, animated: false)
    }
    
    func licenseModal() {
        let vc = AcknowListViewController(fileNamed: "Pods-SubwayWhen-acknowledgements")
        vc.title = "SubwayWhen Licenses"
        vc.headerText = "지하철 민실씨 오픈 라이선스"
        vc.footerText = "YoonSu Lee"
        
        self.naviagation.present(UINavigationController(rootViewController: vc), animated: true)
    }
}
