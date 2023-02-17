//
//  MainTableViewGroupCellModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/01.
//

import Foundation

import RxSwift
import RxCocoa

struct MainTableViewGroupCellModel {
    // INPUT
    let groupSeleted = BehaviorRelay<SaveStationGroup>(value: .one)
    
    // OUTPUT
    let groupDesign : Driver<SaveStationGroup>
    
    init(){
        self.groupDesign = self.groupSeleted
            .asDriver(onErrorDriveWith: .empty())
    }
}
