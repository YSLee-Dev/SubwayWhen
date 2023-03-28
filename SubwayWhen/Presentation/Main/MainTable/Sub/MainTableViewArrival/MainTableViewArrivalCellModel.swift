//
//  MainTableViewArrivalCellModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/08.
//

import Foundation

import RxSwift
import RxCocoa

class MainTableViewCellModel : MainTableViewArrvialCellModelProtocol{
    // INPUT
    let cellTimeChangeBtnClick = PublishRelay<IndexPath>()
}
