//
//  CongestionViewAction.swift
//  SubwayWhen
//
//  Created by 이윤수 on 1/7/26.
//

import Foundation

protocol CongestionViewAction: AnyObject {
    func didDisappear()
    func dismiss()
    func congestionStationChanged()
}
