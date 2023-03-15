//
//  LoadModelTest.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/13.
//

import XCTest

import RxSwift
import RxOptional
import RxBlocking
import Nimble

@testable import SubwayWhen

class LoadModelTest : XCTestCase{
    var arrivalLoadModel : LoadModelProtocol!
    var scheduleLoadModel : LoadModelProtocol!
    
    
    override func setUp() {
        let mockURL = MockURLSession((response: urlResponse!, data: arrivalData))
        let networkManager = NetworkManager(session: mockURL)
        self.arrivalLoadModel = LoadModel(networkManager: networkManager)
        
        let schduleMockURL = MockURLSession((response: urlResponse!, data: seoulStationSchdulData))
        self.scheduleLoadModel = LoadModel(networkManager: NetworkManager(session: schduleMockURL))
    }
    
    func testStationArrivalRequest(){
        //GIVEN
        let data = self.arrivalLoadModel.stationArrivalRequest(stationName: "교대")
        let filterData = data
            .asObservable()
            .map{ data ->  LiveStationModel? in
            guard case .success(let value) = data else {return nil}
            return value
        }
        .filterNil()
        
        // WHEN
        let dummyData = try! JSONDecoder().decode(LiveStationModel.self, from: arrivalData)
        
        let bloacking = filterData.toBlocking()
        let requestData = try! bloacking.toArray()
        
        let requestStationName = requestData.first?.realtimeArrivalList.first?.stationName // MODEL VALUE
        let dummyStationName = dummyData.realtimeArrivalList.first?.stationName // DUMMY VALUE
        
        
        // THEN
        // 지하철 역 동일 테스트
        expect(requestStationName).to(
            equal(dummyStationName),
            description: "불러온 지하철 역이 동일해야함"
        )
    }
    
    func testSeoulStationScheduleLoad(){
        // GIVEN
        let data = self.scheduleLoadModel.seoulStationScheduleLoad(scheduleSearch: .init(stationCode: "", upDown: "", exceptionLastStation: "", line: "", type: .Seoul))
        
        let filterData = data
            .asObservable()
            .map{ data ->  ScheduleStationModel? in
            guard case .success(let value) = data else {return nil}
            return value
        }
        .filterNil()
        
        // WHEN
        let dummyData = try! JSONDecoder().decode(ScheduleStationModel.self, from: seoulStationSchdulData)
        
        let bloacking = filterData.toBlocking()
        let arrayData = try! bloacking.toArray()
        
        let requestWeekData = arrayData.first?.SearchSTNTimeTableByFRCodeService.row.first?.weekDay
        let dummyWeekData = dummyData.SearchSTNTimeTableByFRCodeService.row.first?.weekDay
        
        let requestUpdown = arrayData.first?.SearchSTNTimeTableByFRCodeService.row.first?.upDown
        let dummyUpdown = dummyData.SearchSTNTimeTableByFRCodeService.row.first?.upDown
        
        // THEN
        // 불러온 요일 테스트(더미는 평일)
        expect(requestWeekData).to(
            equal(dummyWeekData),
            description: "평일은 1, 토요일은 2, 일요일은 3이 나와야 함"
        )
        
        // 상하행 테스트(더미는 상행)
        expect(requestUpdown).to(
            equal(dummyUpdown),
            description: "상하행이 같아야 함"
        )
        
    }
}
