//
//  MainTableViewFooterViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/05.
//

import Foundation

import RxSwift
import RxCocoa
 
struct MainTableViewFooterViewModel{
    // INPUT
    let plusBtnClick = PublishRelay<Void>()
    let editBtnClick = PublishRelay<Void>()
}
