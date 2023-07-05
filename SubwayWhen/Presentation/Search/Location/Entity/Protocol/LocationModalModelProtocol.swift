//
//  LocationModalModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/05.
//

import Foundation

import RxSwift

protocol LocationModalModelProtocol {
    func locationAuthCheck() -> Observable<Bool>
    func locationRequest() -> Observable<LocationData>
    func locationToVicinityStationRequest(locationData: LocationData) -> Observable<[LocationModalSectionData]>
}
