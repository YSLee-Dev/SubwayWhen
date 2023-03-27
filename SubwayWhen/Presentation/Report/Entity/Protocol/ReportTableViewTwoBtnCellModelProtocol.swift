//
//  ReportTableViewTwoBtnCellModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/27.
//

import Foundation

import RxSwift
import RxCocoa

protocol ReportTableViewTwoBtnCellModelProtocol{
    var updownClick : BehaviorRelay<String> {get}
    var identityIndex : BehaviorRelay<IndexPath>{get}
}
