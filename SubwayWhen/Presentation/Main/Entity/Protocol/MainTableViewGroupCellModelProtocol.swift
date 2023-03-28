//
//  MainTableViewGroupCellModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift
import RxCocoa

protocol MainTableViewGroupCellModelProtocol{
    var groupSeleted : BehaviorRelay<SaveStationGroup>{get}
    
    var groupDesign : Driver<SaveStationGroup>{get}
}
