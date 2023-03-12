//
//  MainTableViewHeaderCellModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/13.
//

import Foundation

import RxSwift
import RxCocoa

struct MainTableViewHeaderCellModel{
    // OUTPUT
    let peopleCount : Driver<Int>
    
    // INPUT
    let congestionData = BehaviorRelay<Int>(value: 0)
    let reportBtnClick = PublishRelay<Void>()
    let editBtnClick = PublishRelay<Void>()
    
    init(){
        self.peopleCount = self.congestionData
            .asDriver(onErrorDriveWith: .empty())
    }
}
