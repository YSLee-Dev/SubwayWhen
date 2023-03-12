//
//  MainTableViewArrivalCellModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/08.
//

import Foundation

import RxSwift
import RxCocoa

struct MainTableViewCellModel{
    // INPUT
    let cellTimeChangeBtnClick = PublishRelay<IndexPath>()
}
