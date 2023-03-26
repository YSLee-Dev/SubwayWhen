//
//  DetailModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/23.
//

import XCTest

import Nimble
import RxSwift
import RxBlocking

@testable import SubwayWhen

final class DetailModelTests: XCTestCase {

    var arrivalModel : DetailModel!
    var seoulScheduleModel : DetailModel!
    
    override func setUp() {
        let loadModel = LoadModel(networkManager: NetworkManager(session: MockURLSession((response: urlResponse!, data: arrivalData))))
        self.arrivalModel = DetailModel(totalLoadModel: TotalLoadModel(loadModel: loadModel))
        
        let seoulSchedule = LoadModel(networkManager: NetworkManager(session: MockURLSession((response: urlResponse!, data: seoulStationSchduleData))))
        
        self.seoulScheduleModel = DetailModel(totalLoadModel: TotalLoadModel(loadModel: seoulSchedule))
        
    }
    
    func testNextBackStationSearch(){
        // GIVEN
        let backId = "1003000339"
        let nextId = ""
        let value = self.arrivalModel.nextAndBackStationSearch(backId: backId, nextId: nextId)
        
        // WHEN
        let requestBackStation = value[0]
        let dummyBackStation = "고속터미널"
        
        let requestNextStation = value[1]
        let dummyNextStation = ""
        
        // THEN
        expect(requestBackStation).to(
            equal(dummyBackStation),
            description: "동일한 지하철 이름이 나와야 함"
        )
        
        expect(requestNextStation).to(
            equal(dummyNextStation),
            description: "해당 ID가 없으면 빈 문자열이 나와야 함"
        )
    }
    
    func testMainCellToDetailSection(){
        // GIVEN
        let data = self.arrivalModel.mainCellDataToDetailSection(mainCellDummyData)
        let dummyData = mainCellDummyData
        
        // WHEN
        let requestSectionName = data.first?.sectionName
        let dummySectionName = ""
        
        let requestArrivalStation = data[1].items.first?.stationName
        let dummyStation = dummyData.stationName
        
        let requestCount = data.count
        let dummyCount = 3
        
        let requestLiveItem = data[1].items.first?.id
        let reuqestScheduleItem = data[2].items.first?.id
        
        expect(requestSectionName).to(
            equal(dummySectionName),
            description: "헤더부분의 타이틀은 없어야 함"
        )
        
        expect(requestArrivalStation).to(
            equal(dummyStation),
            description: "지하철 역 이름이 6글자가 안넘기 때문에 그대로 표출되어야 함"
        )
        
        expect(requestCount).to(
            equal(dummyCount),
            description: "section의 count는 3이여야 함"
        )
        
        expect(requestLiveItem).toNot(
                equal(reuqestScheduleItem),
                description: "ID는 section마다 달라야함"
        )
    }
    
    func testMainCellToScheduleSearch(){
        // GIVEN
        let data = self.arrivalModel.mainCellDataToScheduleSearch(mainCellDummyData)
        let dummyData = mainCellDummyData
        
        // WHEN
        let requestType = data.type
        let dummyType = ScheduleType.Seoul
        
        let requestStationCode = data.stationCode
        let dummyStationCode = dummyData.stationCode
        
        expect(requestType).to(
            equal(dummyType),
            description: "dummy데이터가 서울 데이터이기 때문에 Seoul이 나와야 함"
        )
        
        expect(requestStationCode).to(
                equal(dummyStationCode),
                description: "형식을 변경해도 StationCode는 동일해야함"
        )
    }
    
    func testMainCellToScheduleSearchError(){
        // GIVEN
        let data = self.arrivalModel.mainCellDataToScheduleSearch(MainTableViewCellData(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "", subWayId: "", stationName: "", lastStation: "", lineNumber: "", isFast: "", useLine: "", group: "", id: "", stationCode: "", exceptionLastStation: "", type: .real, backStationId: "", nextStationId: "", korailCode: ""))

        // WHEN
        let requestType = data.type
        let dummyType = ScheduleType.Unowned
        
        let requestStationCode = data.stationCode
        let dummyStationCode = ""
        
        expect(requestType).to(
            equal(dummyType),
            description: "데이터가 없기 때문에 unowned이 나와야함"
        )
        
        expect(requestStationCode).to(
                equal(dummyStationCode),
                description: "형식을 변경해도 StationCode는 동일해야함"
        )
    }
    
    func testSechduleLoad(){
        // GIVEN
        let data = self.seoulScheduleModel.scheduleLoad(scheduleGyodaeStation3Line)
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        let dummyData = seoulScheduleDummyData
        
        // WHEN
        let requestType = arrayData.first?.first?.type
        let duumyType = ScheduleType.Seoul
        
        let reqeustCount = arrayData.first?.count
        let dummyCount = dummyData.SearchSTNTimeTableByFRCodeService.row.count
        
        let requestFirstTime = arrayData.first?.first?.startTime
        let dummyFirstTime = dummyData.SearchSTNTimeTableByFRCodeService.row.first?.startTime
        
        // THEN
        expect(requestType).to(
            equal(duumyType),
            description: "서울 데이터이기 때문에 Seoul 타입이 나와야함"
        )
        
        expect(reqeustCount).to(
            equal(dummyCount),
            description: "isNow가 false이기 때문에 count가 같아야함"
        )
        
        expect(requestFirstTime).to(
            equal(dummyFirstTime),
            description: "isFirst가 false 이기 때문에 시작 시간이 같아야함"
        )
        
    }
    
    func testSechduleLoadError(){
        // GIVEN
        let data = self.seoulScheduleModel.scheduleLoad(.init(stationCode: "", upDown: "", exceptionLastStation: "", line: "", type: .Unowned, korailCode: ""))
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        let dummyData = seoulScheduleDummyData
        
        // WHEN
        let requestType = arrayData.first?.first?.type
        let duumyType = ScheduleType.Unowned
        
        let reqeustCount = arrayData.first?.count
        let dummyCount = 1
        
        let requestFirstTime = arrayData.first?.first?.startTime
        let dummyFirstTime = "정보없음"
        
        // THEN
        expect(requestType).to(
            equal(duumyType),
            description: "unowned타입이기 때문에 unowned이 나와야함"
        )
        
        expect(reqeustCount).to(
            equal(dummyCount),
            description: "unowned타입이기 때문에 값은 하나가 나와야함"
        )
        
        expect(requestFirstTime).to(
            equal(dummyFirstTime),
            description: "unowned타입이기 때문에 (정보없음)이 나와야함"
        )
        
    }
    
    func testArrivalDataMatching(){
        // GIVEN
        let dummyData = arrivalDummyData.realtimeArrivalList
        let data = self.arrivalModel.arrivalDataMatching(station: mainCellDummyData, arrivalData: dummyData)
        
        // WHEN
        let requestStationName = data.first?.stationName
        let dummyStationName = dummyData.first?.stationName
        
        let requestCount = data.count
        let dummyCount = 2
        
        let requestFirstTime = data.first?.arrivalTime
        let dummyFirstTime = dummyData.first?.arrivalTime
        
        // THEN
        expect(requestStationName).to(
            equal(dummyStationName),
            description: "지하철 역명은 동일해야함"
        )
        
        expect(requestCount).to(
            equal(dummyCount),
            description: "데이터는 2개여야함"
        )
        
        expect(requestFirstTime).to(
            equal(dummyFirstTime),
            description: "같은 데이터임으로 가장 빠른 도착 시간은 동일해야함"
        )
    }
    
    func testArrivalDataMatchingError(){
        // GIVEN
        let dummyData = arrivalDummyData.realtimeArrivalList
        let data = self.arrivalModel.arrivalDataMatching(station: .init(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "", subWayId: "", stationName: "교대", lastStation: "", lineNumber: "", isFast: "", useLine: "", group: "", id: "", stationCode: "", exceptionLastStation: "", type: .real, backStationId: "", nextStationId: "", korailCode: ""), arrivalData: dummyData)
        
        // WHEN
        let requestStationName = data.first?.stationName
        let dummyStationName = "교대"
        
        let requestCount = data.count
        let dummyCount = 1
        
        let requestPreviousStation = data.first?.previousStation
        let dummyPreviousStation = "현재 실시간 열차 데이터가 없어요."
        
        // THEN
        expect(requestStationName).to(
            equal(dummyStationName),
            description: "지하철 역명은 동일해야함"
        )
        
        expect(requestCount).to(
            equal(dummyCount),
            description: "현재 데이터가 없을 때는 카운트가 하나여야함"
        )
        
        expect(requestPreviousStation).to(
            equal(dummyPreviousStation),
            description: "데이터가 없을 때는 (현재 실시간 열차 데이터가 없어요.)가 나와야함"
        )
    }
}
