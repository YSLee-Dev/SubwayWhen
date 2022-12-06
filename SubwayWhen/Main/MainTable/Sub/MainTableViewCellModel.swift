//
//  MainTableViewCellModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/06.
//

import Foundation

import RxSwift
import RxCocoa

struct MainTableViewCellModel{
    let cellTimeChangeBtnClick = PublishRelay<String>()
}
