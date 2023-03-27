//
//  ReportTableViewDefaultLineViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/27.
//

import Foundation

import RxSwift
import RxCocoa

protocol ReportTableViewDefaultLineViewModelProtocol{
    var defaultCellData : BehaviorSubject<[String]> {get}
    var cellClick : PublishSubject<ReportBrandData>{get}
    
    // OUTPUT
    var cellData : Driver<[String]> {get}
}
