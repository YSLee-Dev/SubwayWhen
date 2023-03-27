//
//  ReportTableViewTextFieldCellModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/21.
//

import Foundation

import RxSwift
import RxCocoa

class ReportTableViewTextFieldCellModel : ReportTableViewTextFieldCellModelProtocol{
    let doenBtnClick = PublishRelay<String>()
    let identityIndex = PublishRelay<IndexPath>()
}
