//
//  DetailTableScheduleCellModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/17.
//

import Foundation

import RxSwift
import RxCocoa

struct DetailTableScheduleCellModel{
    // INPUT
    let schedultData = PublishRelay<[ResultSchdule]>()
    
    // MODEL
    let model = LoadModel()
    
    // OUTPUT
    let cellData : Driver<[ResultSchdule]>
    
    init(){
        self.cellData = self.schedultData
            .asDriver(onErrorDriveWith: .empty())
    }
}
