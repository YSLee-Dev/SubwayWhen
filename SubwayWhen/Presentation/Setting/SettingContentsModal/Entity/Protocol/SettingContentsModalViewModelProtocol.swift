//
//  SettingContentsModalViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift
import RxCocoa

protocol SettingContentsModalViewModelProtocol{
    var contents : Driver<String> {get}
    var model : SettingContentsModalModelProtocol {get}
}
