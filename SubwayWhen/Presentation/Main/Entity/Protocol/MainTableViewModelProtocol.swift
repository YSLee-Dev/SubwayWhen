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
    var importantLayout: Driver<ImportantData> {get}
    
    // MODEL
    var mainTableViewHeaderViewModel : MainTableViewHeaderViewModelProtocol {get}
    var mainTableViewCellModel : MainTableViewArrvialCellModelProtocol {get}
    var mainTableViewGroupModel : MainTableViewGroupCellModelProtocol {get}
    
    // INPUT
    var cellClick : PublishRelay<MainTableViewCellData> {get}
    var resultData : BehaviorRelay<[MainTableViewSection]>{get}
    var refreshOn : PublishRelay<Void> {get}
    var plusBtnClick : PublishRelay<Void> {get}
    var importantData: BehaviorSubject<ImportantData?>{get}
}
