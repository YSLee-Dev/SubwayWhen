//
//  CongestionModalCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 1/7/26.
//

import UIKit

import ComposableArchitecture

class CongestionModalCoordinator: Coordinator {
    
    // MARK: - Properties
    
    private let navigation: UINavigationController
    private var store: StoreOf<CongestionModalFeature>?
    var childCoordinator: [Coordinator] = []
    
    weak var delegate: CongestionCoordinatorProtocol?
    
    // MARK: - LifeCycle
    
    init(
        navigation: UINavigationController
    ) {
        self.navigation = navigation
    }
    
    // MARK: - Methods
    
    func start() {
        self.store = StoreOf<CongestionModalFeature>(initialState: .init(), reducer: {
            var reducer = CongestionModalFeature()
            reducer.delegate = self
            return reducer
        })
        
        guard let store = self.store else {return}
        
        let vc = CongestionModalVC(store: store)
        vc.modalPresentationStyle = .overFullScreen
        self.navigation.present(vc, animated: false)
    }
}

// MARK: - Extension CongestionViewAction

extension CongestionModalCoordinator: CongestionViewAction {
    func didDisappear() {
        self.delegate?.didDisappear(coordinator: self)
    }
    
    func dismiss() {
        self.delegate?.dismiss()
    }
}
