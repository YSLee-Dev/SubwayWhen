//
//  SearchCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit
import ComposableArchitecture
import SwiftUI

class SearchCoordinator : Coordinator{
    var childCoordinator: [Coordinator] = []
    var navigation : UINavigationController
    weak var delegate: SearchCoordinatorDelegate?
    
    fileprivate var store: StoreOf<SearchFeature>?
    
    init(){
        self.navigation = .init()
    }
    
    func start() {
        self.store = StoreOf<SearchFeature>(initialState: .init(), reducer: {
            let feature = SearchFeature()
            feature.delegate = self
            return feature
        })
        guard let store = self.store else { return }
        let searchView = SearchView(store: store)
        let vc = UIHostingController(rootView: searchView)
        vc.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "magnifyingglass"), tag: 1)
        
        self.navigation.setNavigationBarHidden(true, animated: false)
        self.navigation.pushViewController(vc, animated: true)
    }
}

extension SearchCoordinator: SearchVCActionProtocol {
    func locationPresent(data: [VicinityTransformData]) {
        let locationCoordinator = LocationModalCoordinator(navigation: self.navigation, vicinityList: data)
        locationCoordinator.delegate = self
        locationCoordinator.start()
        
        self.childCoordinator.append(locationCoordinator)
    }
    
    func modalPresent(data: searchStationInfo) {
        let modalCoordinator = ModalCoordinator(navigation: self.navigation, data: data)
        modalCoordinator.delegate = self
        modalCoordinator.start()
        
        self.childCoordinator.append(modalCoordinator)
    }
}

extension SearchCoordinator: ModalCoordinatorProtocol {
    func dismiss() {
        self.navigation.dismiss(animated: false)
    }
    
    func stationSave() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){[weak self] in
            let popup = PopupModal(modalHeight: 400, popupTitle: "저장 완료", subTitle: "지하철 역이 저장되었어요.", iconName: "CheckMark", congratulations: true)
            popup.modalPresentationStyle = .overFullScreen
            self?.navigation.present(popup, animated: false)
        }
    }
    
    func disposableDetailPush(data: DetailSendModel) {
        let detailCoordinator = DetailCoordinator(navigation: self.navigation, data: data, isDisposable: true)
        detailCoordinator.start()
        detailCoordinator.delegate = self
        self.childCoordinator.append(detailCoordinator)
    }
    
    func didDisappear(modalCoordinator: Coordinator) {
        self.childCoordinator = self.childCoordinator.filter {
            $0 !== modalCoordinator
        }
    }
}

extension SearchCoordinator: DetailCoordinatorDelegate {
    func reportBtnTap(reportLine: ReportBrandData) {
        self.pop()
        self.delegate?.tempDetailViewToReportBtnTap(reportLine: reportLine)
    }
    
    func pop() {
        self.navigation.dismiss(animated: true)
    }
    
    func disappear(detailCoordinator: DetailCoordinator) {
        self.childCoordinator = self.childCoordinator.filter {
            $0 !== detailCoordinator
        }
    }
}

extension SearchCoordinator: LocationModalCoordinatorProtocol {
    func stationTap(index: Int) {
        self.dismiss()
        
        guard let store = self.store else { return }
        store.send(.stationTapped(.init(index: index, type: .location)))
    }
    
    func didDisappear(locationModalCoordinator: Coordinator) {
        self.childCoordinator = self.childCoordinator.filter {
            $0 !== locationModalCoordinator
        }
    }
    
    func dismiss(auth: Bool) {
        self.navigation.dismiss(animated: true)
        if !auth {
            guard let store = self.store else { return }
            store.send(.onAppear)
        }
    }
}
