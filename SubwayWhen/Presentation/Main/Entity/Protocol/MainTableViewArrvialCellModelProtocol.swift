//
//  MainTableViewArrvialCellModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift
import RxCocoa

protocol MainTableViewArrvialCellModelProtocol{
    var cellTimeChangeBtnClick : PublishRelay<IndexPath>{get}
}
