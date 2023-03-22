//
//  DetailTableHeaderViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/30.
//

import Foundation

import RxSwift
import RxCocoa

struct DetailTableHeaderViewModel : DetailTableHeaderViewModelProtocol{
    let exceptionLastStationBtnClick = PublishRelay<Void>()
}
