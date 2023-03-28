//
//  ResultViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import Foundation

import RxSwift
import RxCocoa

class ResultViewModel : ResultViewModelProtocol{
    // OUTPUT
    let cellData : Driver<[ResultVCSection]>
    
    // INPUT
    let cellClick = PublishRelay<IndexPath>()
    let resultData = PublishRelay<[ResultVCSection]>()
    
    init(){
        // CellData로 가공
        self.cellData = self.resultData
            .asDriver(onErrorDriveWith: .empty())
    }
}
