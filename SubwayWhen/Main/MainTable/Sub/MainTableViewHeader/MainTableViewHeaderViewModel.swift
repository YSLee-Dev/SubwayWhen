//
//  MainTableViewHeaderViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/13.
//

import Foundation

import RxSwift
import RxCocoa

struct MainTableViewHeaderViewModel{
    let peopleCount : Driver<Int>
    let congestionData = BehaviorRelay<Int>(value: 0)
    
    init(){
        self.peopleCount = self.congestionData
            .asDriver(onErrorDriveWith: .empty())
    }
}
