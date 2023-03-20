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
    var seoulScheduleLoadModel : TotalLoadModel!
    var korailScheduleLoadModel : TotalLoadModel!
    
    override func setUp(){
        let session = MockURLSession((response: urlResponse!, data: arrivalData))
        let networkManager = NetworkManager(session: session)
        let loadModel = LoadModel(networkManager: networkManager)
        
        self.arrivalTotalLoadModel = TotalLoadModel(loadModel: loadModel)
        
        self.arrivalErrorTotalLoadModel = TotalLoadModel(loadModel: LoadModel(networkManager: NetworkManager(session: MockURLSession(((response: urlResponse!, data: arrivalErrorData))))))
        self.seoulScheduleLoadModel = TotalLoadModel(loadModel: LoadModel(networkManager: NetworkManager(session: MockURLSession(((response: urlResponse!, data: seoulStationSchduleData))))))
        self.korailScheduleLoadModel = TotalLoadModel(loadModel: LoadModel(networkManager: NetworkManager(session: MockURLSession(((response: urlResponse!, data: korailStationSchduleData))))))
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
        let data = self.arrivalErrorTotalLoadModel.totalLiveDataLoad(stations: [SaveStation(id: "-", stationName: "교대", stationCode: "340", updnLine: "상행", line: "03호선", lineCode: "1003", group: .one, exceptionLastStation: "", korailCode: "")])
        
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
    
    func testSingleLiveDataLoad(){
        // GIVEN
        let data = self.arrivalTotalLoadModel.singleLiveDataLoad(station: "교대")
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let dummyData = try! JSONDecoder().decode(LiveStationModel.self, from: arrivalData)
        
        let requestStationName = arrayData.first?.realtimeArrivalList.first?.stationName
        let dummyStationName = dummyData.realtimeArrivalList.first?.stationName
        
        let requestNextId = arrayData.first?.realtimeArrivalList.first?.nextStationId
        let dummyNextId = dummyData.realtimeArrivalList.first?.nextStationId
        
        let requestCode = arrayData.first?.realtimeArrivalList.first?.code
        let dummyCode = dummyData.realtimeArrivalList.first?.code
        
        // THEN
        expect(requestStationName).to(
            equal(dummyStationName),
            description: "지하철 역명은 동일해야함"
        )
        
        expect(requestNextId).to(
            equal(dummyNextId),
            description: "기본 데이터가 같으므로, NextID도 동일해야함"
        )
        
        expect(requestCode).to(
            equal(dummyCode),
            description: "기본 데이터가 같으므로, code 또한 동일해야함"
        )
    }
    
    func testSingleLiveDataLoadError(){
        // GIVEN
        let data = self.arrivalErrorTotalLoadModel.singleLiveDataLoad(station: "교대")
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestStationName = arrayData.first?.realtimeArrivalList.first?.stationName
        let dummyStationName = "교대"
        
        let requestCode = arrayData.first?.realtimeArrivalList.first?.code
        let dummyStationCode = "현재 실시간 열차 데이터가 없어요."
        
        // THEN
        expect(requestStationName).to(
            equal(dummyStationName),
            description: "열차 데이터를 받아오지 못해도 역 이름은 동일해야함"
        )
        
        expect(requestCode).to(
            equal(dummyStationCode),
            description: "열차 데이터를 받아오지 못할 때는 (현재 실시간 열차 데이터가 없어요.)가 나와야함"
        )
    }
    
    func testSeoulScheduleLoad_isFirst_isNow(){
        // GIVEN
        let data = self.seoulScheduleLoadModel.seoulScheduleLoad(
            .init(stationCode: "340", upDown: "상행", exceptionLastStation: "", line: "03호선", type: .Seoul, korailCode: "")
            , isFirst: true, isNow: true)
        
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let dummyData = try! JSONDecoder().decode(ScheduleStationModel.self, from: seoulStationSchduleData)
        
        let requestCount = arrayData.first?.count
        let dummyCount = 1
        
        let requestStart = arrayData.first?.first?.startTime
        let dummyStart = dummyData.SearchSTNTimeTableByFRCodeService.row.first?.startTime
        
        let requestType = arrayData.first?.first?.type
        let dummyType = ScheduleType.Seoul
        
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "isFirst가 true이기 때문에 하나의 데이터만 가져와야 함"
        )
        
        expect(requestStart).toNot(
            equal(dummyStart),
            description: "기본 데이터가 같지만, isNow가 true이기 때문에 데이터가 달라야함"
        )
        
        expect(requestType).to(
            equal(dummyType),
            description: "타입은 동일해야함"
        )
    }
    
    func testSeoulScheduleLoad_isFirst(){
        // GIVEN
        let data = self.seoulScheduleLoadModel.seoulScheduleLoad(
            .init(stationCode: "340", upDown: "상행", exceptionLastStation: "", line: "03호선", type: .Seoul, korailCode: "")
            , isFirst: true, isNow: false)
        
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let dummyData = try! JSONDecoder().decode(ScheduleStationModel.self, from: seoulStationSchduleData)
        
        let requestCount = arrayData.first?.count
        let dummyCount = 1
        
        let requestStart = arrayData.first?.first?.startTime
        let dummyStart = dummyData.SearchSTNTimeTableByFRCodeService.row.first?.startTime
        
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "isFirst가 true이기 때문에 하나의 데이터만 가져와야 함"
        )
        
        expect(requestStart).to(
            equal(dummyStart),
            description: "기본 데이터가 같고, isNow가 false이기 때문에 데이터가 같아야함"
        )
    }
    
    func testSeoulScheduleLoad_isNow(){
        // GIVEN
        let data = self.seoulScheduleLoadModel.seoulScheduleLoad(
            .init(stationCode: "340", upDown: "상행", exceptionLastStation: "", line: "03호선", type: .Seoul, korailCode: "")
            , isFirst: false, isNow: true)
        
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let dummyData = try! JSONDecoder().decode(ScheduleStationModel.self, from: seoulStationSchduleData)
        
        let requestCount = arrayData.first?.count
        let dummyCount = dummyData.SearchSTNTimeTableByFRCodeService.row.count
        
        let requestStart = arrayData.first?.first?.startTime
        let dummyStart = dummyData.SearchSTNTimeTableByFRCodeService.row.first?.startTime
        
        // THEN
        expect(requestCount).toNot(
            equal(dummyCount),
            description: "isFirst가 false여도 isNow가 true이기 때문에 count가 달라야함"
        )
        
        expect(requestStart).toNot(
            equal(dummyStart),
            description: "isNow가 false이기 때문에 데이터가 달라야함"
        )
    }
    
    func testSeoulScheduleLoad(){
        // GIVEN
        let data = self.seoulScheduleLoadModel.seoulScheduleLoad(
            .init(stationCode: "340", upDown: "상행", exceptionLastStation: "", line: "03호선", type: .Seoul, korailCode: "")
            , isFirst: false, isNow: false)
        
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let dummyData = try! JSONDecoder().decode(ScheduleStationModel.self, from: seoulStationSchduleData)
        
        let requestCount = arrayData.first?.count
        let dummyCount = dummyData.SearchSTNTimeTableByFRCodeService.row.count
        
        let requestStart = arrayData.first?.first?.startTime
        let dummyStart = dummyData.SearchSTNTimeTableByFRCodeService.row.first?.startTime
        
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "데이터가 같기 때문에 count가 동일해야함"
        )
        
        expect(requestStart).to(
            equal(dummyStart),
            description: "기본 데이터가 같고, isNow가 false이기 때문에 데이터가 같아야함"
        )
    }
    
    func testSeoulScheduleLoadError(){
        // GIVEN
        let data = self.arrivalErrorTotalLoadModel.seoulScheduleLoad(
            .init(stationCode: "340", upDown: "상행", exceptionLastStation: "", line: "03호선", type: .Seoul, korailCode: "")
            , isFirst: false, isNow: false)
        
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestCount = arrayData.first?.count
        let dummyCount = 1
        
        let requestStart = arrayData.first?.first?.startTime
        let dummyStart = "정보없음"
        
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "정보가 없으면 카운트는 1이 되어야 함"
        )
        
        expect(requestStart).to(
            equal(dummyStart),
            description: "정보가 없으면 (정보없음)으로 통일 되어야함"
        )
    }
    
    func testKorailScheduleLoad_isFirst_isNow(){
        let bag = DisposeBag()
        let testException = XCTestExpectation(description: "옵저버블 대기")
        
        // GIVEN
        var arrayData : [ResultSchdule] = []
        let data = self.korailScheduleLoadModel.korailSchduleLoad(
            scheduleSearch: .init(
                stationCode: "K240", upDown: "하행", exceptionLastStation: "", line: "", type: .Korail, korailCode: "K1"),
            isFirst: true, isNow: true)
        data
            .subscribe(onNext: {
                arrayData = $0
                testException.fulfill()
            })
            .disposed(by: bag)
        
    
        wait(for: [testException], timeout: 3)
    
        // WHEN
        let dummy = try! JSONDecoder().decode(KorailHeader.self, from: korailStationSchduleData)
        
        let requestCount = arrayData.count
        let dummyCount = 1
        
        let requestStart = arrayData.first?.startTime
        let dummyStart = dummy.body.first?.time
        
        let requestType = arrayData.first?.type
        let dummyType = ScheduleType.Korail
        
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "isFirst가 true이기 때문에 하나의 데이터만 가져와야 함"
        )
        
        expect(requestStart).toNot(
            equal(dummyStart),
            description: "기본 데이터가 같지만, isNow가 true이기 때문에 데이터가 달라야함"
        )
        
        expect(requestType).to(
            equal(dummyType),
            description: "타입은 동일해야함"
        )
    }
}
