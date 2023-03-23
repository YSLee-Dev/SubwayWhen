//
//  DetailResultScheduleTopViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/14.
//

import Foundation

import RxSwift
import RxCocoa

class DetailResultScheduleTopViewModel : DetailResultScheduleTopViewProtocol {
    let exceptionLastStationBtnClick = PublishRelay<Void>()
}
