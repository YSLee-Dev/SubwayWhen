//
//  DetailResultScheduleTopViewProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/23.
//

import Foundation

import RxSwift
import RxCocoa

protocol DetailResultScheduleTopViewProtocol{
    var exceptionLastStationBtnClick : PublishRelay<Void>{get}
}
