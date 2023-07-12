//
//  LocationModalCoordinatorProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/05.
//

import Foundation

protocol LocationModalCoordinatorProtocol: AnyObject {
    func dismiss()
    func didDisappear(locationModalCoordinator: Coordinator)
    func stationTap(stationName: String)
}
