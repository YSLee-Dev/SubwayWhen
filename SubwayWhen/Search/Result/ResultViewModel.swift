//
//  ResultViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import Foundation

import RxSwift
import RxCocoa

struct ResultViewModel {
    // OUTPUT
    let cellData : Driver<[searchStationInfo]>
    
    // INPUT
    let cellClick = PublishRelay<searchStationInfo>()
    let resultData = PublishRelay<[searchStationInfo]>()
    
    init(){
        // CellData로 가공
        self.cellData = self.resultData
            .asDriver(onErrorDriveWith: .empty())
    }
}
