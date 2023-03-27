//
//  ReportTableViewTwoBtnCellModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/21.
//

import Foundation

import RxSwift
import RxCocoa

class ReportTableViewTwoBtnCellModel : ReportTableViewTwoBtnCellModelProtocol{
    let updownClick = BehaviorRelay<String>(value: "")
    let identityIndex = BehaviorRelay<IndexPath>(value: IndexPath(row: 9, section: 9))
}
