//
//  SettingGroupModalViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift
import RxCocoa

protocol SettingGroupModalViewModelProtocol{
    // INPUT
    var groupOneHourValue : BehaviorRelay<Int>{get}
    var groupTwoHourValue : BehaviorRelay<Int>{get}
    var saveBtnClick : PublishRelay<Void>{get}
    
    // OUTPUT
    var groupOneDefaultValue : Driver<Int>{get}
    var groupTwoDefaultValue : Driver<Int>{get}
    var modalClose : Driver<Void>{get}
}
