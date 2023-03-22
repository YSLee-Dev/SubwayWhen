//
//  DetailTableHeaderViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/22.
//

import Foundation

import RxSwift
import RxCocoa

protocol DetailTableHeaderViewModelProtocol{
    var exceptionLastStationBtnClick : PublishRelay<Void> {get}
}
