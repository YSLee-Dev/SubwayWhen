//
//  TotalLoadModelTest.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/14.
//

import XCTest

import Nimble
import RxSwift
import RxOptional
import RxBlocking

@testable import SubwayWhen

final class TotalLoadModelTest: XCTestCase {
    var totalLoadModel : TotalLoadModel!
    
    override func setUp(){
        let session = MockURLSession((response: urlResponse!, data: arrivalData))
        let networkManager = NetworkManager(session: session)
        let loadModel = LoadModel(networkManager: networkManager)
        
        self.totalLoadModel = TotalLoadModel(loadModel: loadModel)
    }
    
    func testTotalLiveDataLoad(){
        // GIVEN
        let data = self.totalLoadModel.totalLiveDataLoad(stations: [SaveStation(id: "-", stationName: "교대", stationCode: "330", updnLine: "상행", line: "03호선", lineCode: "1003", group: .one, exceptionLastStation: "", korailCode: "")])
        
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let dummyData = try! JSONDecoder().decode(LiveStationModel.self, from: arrivalData)
        
        let requestStationName = arrayData.first?.stationName
        let dummyStationName = dummyData.realtimeArrivalList.first?.stationName
        
        let requestType = arrayData.first?.type
        let dummyType = MainTableViewCellType.real
        
        let requestLine = arrayData.first?.lineNumber
        let dummyLine = "03호선"
        
        // THEN
        expect(requestStationName).to(
            equal(dummyStationName),
            description: "지하철 역명은 동일해야함"
        )
        
        expect(requestType).to(
            equal(dummyType),
            description: "TotalLive함수는 타입이 무조건 Real이여야 함"
        )
        
        expect(requestLine).to(
            equal(dummyLine),
            description: "라인 호선은 동일해야함"
        )
    }
}
