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
    var arrivalTotalLoadModel : TotalLoadModel!
    var arrivalErrorTotalLoadModel : TotalLoadModel!
    
    
    override func setUp(){
        let session = MockURLSession((response: urlResponse!, data: arrivalData))
        let networkManager = NetworkManager(session: session)
        let loadModel = LoadModel(networkManager: networkManager)
        
        self.arrivalTotalLoadModel = TotalLoadModel(loadModel: loadModel)
        
        self.arrivalErrorTotalLoadModel = TotalLoadModel(loadModel: LoadModel(networkManager: NetworkManager(session: MockURLSession(((response: urlResponse!, data: arrivalErrorData))))))
    }
    
    func testTotalLiveDataLoad(){
        // GIVEN
        let data = self.arrivalTotalLoadModel.totalLiveDataLoad(stations: [SaveStation(id: "-", stationName: "교대", stationCode: "330", updnLine: "상행", line: "03호선", lineCode: "1003", group: .one, exceptionLastStation: "", korailCode: "")])
        
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
        
        let requestCode = arrayData.first?.code
        let dummyCode = dummyData.realtimeArrivalList.first?.code
        
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
        
        expect(requestCode).to(
            equal(dummyCode),
            description: "기본 데이터가 같으므로, code 또한 동일해야함"
        )
    }
    
    func testTotalLiveDataLoadError(){
        //GIVEN
        let data = self.arrivalErrorTotalLoadModel.totalLiveDataLoad(stations: [SaveStation(id: "-", stationName: "교대", stationCode: "330", updnLine: "상행", line: "03호선", lineCode: "1003", group: .one, exceptionLastStation: "", korailCode: "")])
        
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestCode = arrayData.first?.code
        let dummyStationCode = "현재 실시간 열차 데이터가 없어요."
        
        let requestStationName = arrayData.first?.stationName
        let dummyStationName = "교대"
        
        let requestBackId = arrayData.first?.backStationId
        let dummyBackId = ""
        
        // THEN
        expect(requestCode).to(
        equal(dummyStationCode),
        description: "열차 데이터를 받아오지 못할 때는 (현재 실시간 열차 데이터가 없어요.)가 나와야함"
        )
        
        expect(requestStationName).to(
        equal(dummyStationName),
        description: "열차 데이터를 받아오지 못해도 역 이름은 동일해야함"
        )
        
        expect(requestBackId).to(
        equal(dummyBackId),
        description: "열차 데이터를 받아오지 못하면 Back, NextId가 없어야 함"
        )
    }
    
}
