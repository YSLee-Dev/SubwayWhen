//
//  ReportTableViewDefaultLineViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/06.
//

import Foundation

import RxSwift
import RxCocoa

struct ReportTableViewDefaultLineViewModel {
    // INPUT
    let defaultCellData = BehaviorSubject<[String]>(value: [])
    let cellClick = PublishSubject<ReportBrandData>()
    
    // OUTPUT
    let cellData : Driver<[String]>
    
    init(){
        self.cellData = self.defaultCellData
            .asDriver(onErrorDriveWith: .empty())
    }
}
