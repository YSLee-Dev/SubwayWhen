//
//  ReportTableViewLineCellModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/21.
//

import Foundation

import RxSwift
import RxCocoa

class ReportTableViewLineCellModel : ReportTableViewLineCellModelProtocol{
    // OUTPUT
    let lineList : Driver<[String]>
    let lineSet : Driver<String>
    let lineUnSeleted : Driver<Void>
    
    // INPUT
    let lineInfo = BehaviorRelay<[String]>(value: [])
    let lineSeleted = PublishRelay<ReportBrandData>()
    let lineFix = PublishRelay<Void>()
    
    // MODEL
    let defaultLineViewModel : ReportTableViewDefaultLineViewModelProtocol
    
    init(
        lineViewModel : ReportTableViewDefaultLineViewModel = .init()
    ){
        self.defaultLineViewModel = lineViewModel
        
        self.lineList = self.lineInfo
        .asDriver(onErrorDriveWith: .empty())
        
        let line = Observable<ReportBrandData>.merge(
            self.lineSeleted.asObservable(),
            self.defaultLineViewModel.cellClick
        )
        
        self.lineSet = line
            .map{
                $0.rawValue
            }
            .asDriver(onErrorDriveWith: .empty())
        
        let fix = Observable<Void>.merge(
            self.lineFix.asObservable(),
            self.defaultLineViewModel.cellClick.map{_ in Void()}
        )
        
        self.lineUnSeleted = fix
            .asDriver(onErrorDriveWith: .empty())
    }
}
