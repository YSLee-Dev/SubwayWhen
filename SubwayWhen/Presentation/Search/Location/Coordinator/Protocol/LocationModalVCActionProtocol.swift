//
//  LocationModalVCActionProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/05.
//

import Foundation

protocol LocationModalVCActionProtocol: AnyObject {
    func dismiss()
    func didDisappear()
    func stationTap(index: Int)
}
