//
//  RealtimeCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 4/10/26
//

import UIKit
import SwiftUI

import ComposableArchitecture

class RealtimeCoordinator: Coordinator {
    var childCoordinator: [Coordinator] = []
    var navigation: UINavigationController

    private let subwayLine: SubwayLineData
    private let stationName: String

    init(navigation: UINavigationController, subwayLine: SubwayLineData, stationName: String) {
        self.navigation = navigation
        self.subwayLine = subwayLine
        self.stationName = stationName
    }

    func start() {
        let store = StoreOf<RealtimeFeature>(
            initialState: RealtimeFeature.State(subwayLine: self.subwayLine, stationName: self.stationName),
            reducer: {
                var feature = RealtimeFeature()
                feature.coordinatorDelegate = self
                return feature
            }
        )
        let view = RealtimeView(store: store)
        let vc = UIHostingController(rootView: view)
        vc.hidesBottomBarWhenPushed = true
        self.navigation.pushViewController(vc, animated: true)
    }
}

// MARK: - RealtimeCoordinatorProtocol

extension RealtimeCoordinator: RealtimeCoordinatorProtocol {
    func showBundleErrorPopupAndDismiss() {
        let alert = UIAlertController(
            title: Strings.Realtime.bundleErrorTitle,
            message: Strings.Realtime.bundleErrorMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Strings.Common.check, style: .default) { [weak self] _ in
            self?.navigation.popViewController(animated: true)
        })
        self.navigation.present(alert, animated: true)
    }
}

