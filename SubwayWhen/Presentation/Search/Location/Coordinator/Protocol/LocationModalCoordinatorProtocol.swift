//
//  LocationModalCoordinatorProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/05.
//

import Foundation

protocol LocationModalCoordinatorProtocol: AnyObject {
    func dismiss(auth: Bool)
    func didDisappear(locationModalCoordinator: Coordinator)
    func stationTap(index: Int)
}
