//
//  DetailTableArrivalLiveViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/04/17.
//

import Foundation

import RxSwift
import RxCocoa

protocol DetailTableArrivalLiveViewModelProtocol{
    var superTimer : PublishSubject<Int> {get}
    var arrivalData : PublishSubject<[RealtimeStationArrival]> {get}
    
    var timer : Driver<Int> {get}
    var viewData : Driver<RealtimeStationArrival> {get}
}
