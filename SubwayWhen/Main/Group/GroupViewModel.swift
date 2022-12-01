//
//  GroupViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/01.
//

import Foundation

import RxSwift
import RxCocoa

struct GroupViewModel {
    // INPUT
    let groupSeleted = BehaviorRelay<SaveStationGroup>(value: .one)
}
