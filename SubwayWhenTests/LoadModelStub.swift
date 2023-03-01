//
//  LoadModelStub.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/01.
//

import Foundation

import RxSwift


@testable import SubwayWhen

class LoadModelStub : LoadModel{
    override func stationArrivalRequest(stationName: String) -> Single<Result<LiveStationModel, URLError>> {
        return .just(.success(stationArrivalRequestList))
    }
}
