//
//  SettingCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit
import SwiftUI
import ComposableArchitecture

import AcknowList
 
class SettingCoordinator : Coordinator {
    var childCoordinator: [Coordinator] = [] {
        didSet {
            AppLogger.coordinator.log(.debug, "SettingCoordinator 자식: \(self.childCoordinator)")
        }
    }
    var navigation : UINavigationController
    
    fileprivate var store: StoreOf<SettingFeature>?
    
    init(){
        self.navigation = .init()
    }
    
    func start() {
        self.store = StoreOf<SettingFeature>(initialState: .init(), reducer: {
            var reducer = SettingFeature()
            reducer.delegate = self
                   return reducer
        })
        
        guard let store = self.store else { return }
        let view = SettingView(store: store)
        let vc = UIHostingController(rootView: view)
        vc.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "gearshape"), tag: 2)
        
        if #available(iOS 26.0, *) {
            vc.extendedLayoutIncludesOpaqueBars = true
            vc.edgesForExtendedLayout = .all
        }
        
        self.navigation.setNavigationBarHidden(true, animated: false)
        self.navigation.pushViewController(vc, animated: true)
    }
}

extension SettingCoordinator: SettingVCAction {
    func trainIconModal() {
        let trainIconCoordinator = SettingTrainIconModalCoordinator(navigation: self.navigation)
        trainIconCoordinator.start()
        trainIconCoordinator.delegate = self
        
        self.childCoordinator.append(trainIconCoordinator)
    }
    
    func notiModal() {
        let notiCoordinator = SettingNotiCoordinator(rootVC: self.navigation)
        notiCoordinator.start()
        notiCoordinator.delegate = self
        
        self.childCoordinator.append(notiCoordinator)
    }
    
    func contentsModal() {
        let viewModel = SettingContentsModalViewModel()
        let modal = SettingContentsModalVC(
            modalHeight: 400,
            btnTitle: "닫기",
            mainTitle: "기타",
            subTitle: "저작권 및 데이터 출처를 표시하는 공간이에요.",
            viewModel: viewModel
        )
        modal.modalPresentationStyle = .overFullScreen
        
        self.navigation.present(modal, animated: false)
    }
    
    func licenseModal() {
        let vc = AcknowListViewController(fileNamed: "Pods-SubwayWhen-acknowledgements")
        vc.title = "SubwayWhen Licenses"
        vc.headerText = "지하철 민실씨 오픈 라이선스"
        vc.footerText = "YoonSu Lee"
        
        // v1.5추가 (SPM으로 추가한 TCA)
        vc.acknowledgements.append(.init(title: "swift-composable-architecture", repository: URL(string: "https://github.com/pointfreeco/swift-composable-architecture")))
       
        self.navigation.present(UINavigationController(rootViewController: vc), animated: true)
    }
}

extension SettingCoordinator: SettingNotiCoordinatorProtocol, SettingTrainIconCoordinatorProtocol {
    func didDisappear(coordinator: Coordinator) {
        self.childCoordinator = self.childCoordinator.filter{
            $0 !== coordinator
        }
    }
    
    func dismiss() {
        self.navigation.dismiss(animated: true)
        
        guard let store = self.store else { return }
        store.send(.updateSavedSettings)
    }
}
