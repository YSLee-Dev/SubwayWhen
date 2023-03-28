//
//  MainTableViewHeaderViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift
import RxCocoa
 
protocol MainTableViewHeaderViewModelProtocol{
    var peopleCount : Driver<Int>{get}
    
    var congestionData : BehaviorRelay<Int>{get}
    var reportBtnClick : PublishRelay<Void>{get}
    var editBtnClick : PublishRelay<Void>{get}
}
 
