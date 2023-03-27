//
//  ReportTableViewTextFieldCellModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/27.
//

import Foundation

import RxSwift
import RxCocoa

protocol ReportTableViewTextFieldCellModelProtocol{
    var doenBtnClick : PublishRelay<String> {get}
    var identityIndex : PublishRelay<IndexPath> {get}
}
