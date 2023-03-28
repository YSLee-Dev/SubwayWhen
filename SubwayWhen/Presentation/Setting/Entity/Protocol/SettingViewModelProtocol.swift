//
//  SettingViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift
import RxCocoa

protocol SettingViewModelProtocol{
    var cellData : Driver<[SettingTableViewCellSection]>{get}
    var keyboardClose : Driver<Void>{get}
    var modalPresent : Driver<SettingTableViewCellData>{get}
    
    var cellClick : PublishRelay<SettingTableViewCellData>{get}
    
    var model : SettingModelProtocol{get}
    var settingTableViewCellModel : SettingTableViewCellModelProtocol{get}
    
    var settingList : BehaviorRelay<[SettingTableViewCellSection]>{get}
}
