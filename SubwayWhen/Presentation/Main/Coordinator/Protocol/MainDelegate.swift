//
//  MainDelegate.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import Foundation

protocol MainDelegate : AnyObject {
    func pushTap(action : MainCoordinatorAction)
    func pushDetailTap(data : MainTableViewCellData)
    func plusStationTap()
}
