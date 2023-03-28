//
//  SettingTableViewCellModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift
import RxCocoa

protocol SettingTableViewCellModelProtocol{
    var tfValue : PublishRelay<String?>{get}
    var switchValue : PublishRelay<Bool>{get}
    var keyboardClose : PublishRelay<Void>{get}
    var cellIndex : PublishRelay<IndexPath>{get}
}
