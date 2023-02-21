//
//  ReportTableViewLineCellModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/21.
//

import Foundation

import RxSwift
import RxCocoa

struct ReportTableViewLineCellModel {
    // OUTPUT
    let lineList : Driver<[String]>
    
    // INPUT
    let lineInfo = BehaviorRelay<[String]>(value: [])
    let lineSeleted = PublishRelay<ReportBrandData>()
    let doneBtnClick = PublishRelay<Void>()
    
    init(){
        self.lineList = self.lineInfo
        .asDriver(onErrorDriveWith: .empty())
        
    }
}
