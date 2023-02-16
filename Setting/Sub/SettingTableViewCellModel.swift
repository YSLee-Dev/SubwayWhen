//
//  SettingTableViewCellModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/16.
//

import Foundation

import RxSwift
import RxCocoa

class SettingTableViewCellModel {
    // INPUT
    let tfValue = PublishRelay<String?>()
    let switchValue = PublishRelay<Bool>()
}
