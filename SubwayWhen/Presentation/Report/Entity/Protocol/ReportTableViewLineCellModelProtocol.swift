//
//  ReportTableViewLineCellModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/27.
//

import Foundation

import RxSwift
import RxCocoa

protocol ReportTableViewLineCellModelProtocol{
    var lineList : Driver<[String]> {get}
    var lineSet : Driver<String> {get}
    var lineUnSeleted : Driver<Void> {get}
    
    var lineInfo : BehaviorRelay<[String]> {get}
    var lineSeleted : PublishRelay<ReportBrandData> {get}
    var lineFix : PublishRelay<Void> {get}
    
    var defaultLineViewModel : ReportTableViewDefaultLineViewModelProtocol {get}
}

