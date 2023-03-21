//
//  MainTableViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/21.
//

import Foundation

import RxSwift
import RxCocoa

protocol MainTableViewModelProtocol{
    // OUTPUT
    var cellData : Driver<[MainTableViewSection]> {get}
    
    // MODEL
    var mainTableViewHeaderViewModel : MainTableViewHeaderCellModel {get}
    var mainTableViewCellModel : MainTableViewCellModel {get}
    var mainTableViewGroupModel : MainTableViewGroupCellModel {get}
    
    // INPUT
    var cellClick : PublishRelay<MainTableViewCellData> {get}
    var resultData : BehaviorRelay<[MainTableViewSection]>{get}
    var refreshOn : PublishRelay<Void> {get}
    var plusBtnClick : PublishRelay<Void> {get}
}
