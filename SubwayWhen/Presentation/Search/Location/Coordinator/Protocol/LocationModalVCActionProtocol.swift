//
//  LocationModalVCActionProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/05.
//

import Foundation

protocol LocationModalVCActionProtocol: AnyObject {
    func dismiss(auth: Bool)
    func didDisappear()
    func stationTap(index: Int)
}
