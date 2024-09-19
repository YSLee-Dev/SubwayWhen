//
//  LoadModelTests.swift
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

class LoadModelTests : XCTestCase{
    var arrivalLoadModel : LoadModelProtocol!
    var seoulScheduleLoadModel : LoadModelProtocol!
    var korailScheduleLoadModel : LoadModelProtocol!
    var stationNameSearchModel : LoadModelProtocol!
    var kakaoVicinityStationModel: LoadModelProtocol!
    
    override func setUp() {
        let mockURL = MockURLSession((response: urlResponse!, data: arrivalData))
        let networkManager = NetworkManager(session: mockURL)
        self.arrivalLoadModel = LoadModel(networkManager: networkManager)
        
        let schduleMockURL = MockURLSession((response: urlResponse!, data: seoulStationSchduleData))
        self.seoulScheduleLoadModel = LoadModel(networkManager: NetworkManager(session: schduleMockURL))
        
        let mockURLSession = MockURLSession((response: urlResponse!, data: korailStationSchduleData))
        self.korailScheduleLoadModel = LoadModel(networkManager: NetworkManager(session: mockURLSession))
        
        let stationNameMock = MockURLSession((response: urlResponse!, data: stationNameSearchData))
        self.stationNameSearchModel = LoadModel(networkManager: NetworkManager(session: stationNameMock))
        
        let vicinityMock = MockURLSession((response: urlResponse!, data: vicinityData))
        self.kakaoVicinityStationModel = LoadModel(networkManager: NetworkManager(session: vicinityMock))
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
        let dummyData = arrivalDummyData
        
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
        let data = self.seoulScheduleLoadModel.seoulStationScheduleLoad(scheduleSearch: .init(stationCode: "", upDown: "", exceptionLastStation: "", line: "", korailCode: "", stationName: ""))
        
        let filterData = data
            .asObservable()
            .map{ data ->  ScheduleStationModel? in
            guard case .success(let value) = data else {return nil}
            return value
        }
        .filterNil()
        
        // WHEN
        let dummyData = seoulScheduleDummyData
        
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
    
    func testKorailScheduleLoad(){
        // GIVEN
        let data = self.korailScheduleLoadModel.korailSchduleLoad(scheduleSearch: .init(stationCode: "", upDown: "", exceptionLastStation: "", line: "",  korailCode: "", stationName: ""))
        
        let filterData = data
            .asObservable()
            .map{data -> KorailHeader? in
                guard case .success(let value) = data else {return nil}
                return value
            }
            .filterNil()
        
        // WHEN
        let dummy = korailScheduleDummyData
        
        let bloacking = filterData.toBlocking()
        let arrayData = try! bloacking.toArray()
        
        let requestWeekData = arrayData.first?.body.first?.weekDay
        let dummyWeekData = dummy.first?.weekDay
        
        let requestLineCode = arrayData.first?.body.first?.lineCode
        let dummyLineCode = dummy.first?.lineCode
        
        // THEN
        expect(requestWeekData).to(
            equal(dummyWeekData),
            description: "평일은 8, 토요일, 휴일은 9가 나와야함"
        )
        
        expect(requestLineCode).to(
            equal(dummyLineCode),
            description: "LineCode는 동일해야함"
        )
    }
    
    func testStationSearch(){
        // GIVEN
        let data = self.stationNameSearchModel.stationSearch(station: "교대")
        let successData = data
            .map{ data -> SearchStaion? in
                guard case .success(let value) = data else {return nil}
                return value
            }
            .asObservable()
            .filterNil()
        let blocking = successData.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestFirstStation = arrayData.first?.SearchInfoBySubwayNameService.row.first?.stationName
        let dummyFirstStation = stationNameSearcDummyhData.SearchInfoBySubwayNameService.row.first?.stationName
        
        // THEN
        expect(requestFirstStation).to(
            equal(dummyFirstStation),
            description: "StationName은 검색한 역이 나와야함"
        )
    }
    
    func testVicinityStationLoad() {
        //GIVEN
        let data = self.kakaoVicinityStationModel.vicinityStationsLoad(
            x: 37.49388026940836, y: 127.01360357128935
        )
        let filterData = data.map { data -> [VicinityDocumentData] in
            guard case .success(let success) = data else {return []}
            return success.documents
        }
            .asObservable()
            .filterEmpty()
        let blocking = filterData.toBlocking()
        let requestData = try! blocking.toArray()
        
        let dummyData = vicinityStationsDummyData.documents
        
        // WHEN
        let reuqestFirstName = requestData.first?.first?.name
        let dummyFirstName = dummyData.first?.name
        
        let requestLastName = requestData.first?.last?.name
        let dummyLastName = dummyData.last?.name
        
        let requestRadiusCount = requestData.first?.filter {
            Int($0.distance) ?? 0 >= 3000
        }
            .count
        
        let dummyRadiusCount = 0
        
        let requestCategoryCount = requestData.first?.filter {
            $0.category != "SW8"
        }
            .count
        
        let dummyCategoryCount = 0
        
        // THEN
        expect(reuqestFirstName).to(
            equal(dummyFirstName),
            description: "모든 값은 순서를 포함해서 동일해야함"
        )
        
        expect(requestLastName).to(
            equal(dummyLastName),
            description: "모든 값은 순서를 포함해서 동일해야함"
        )
        
        expect(requestRadiusCount).to(
            equal(dummyRadiusCount),
            description: "3000m가 넘어가는 지하철역은 없어야함"
        )
        
        expect(requestCategoryCount).to(
            equal(dummyCategoryCount),
            description: "SW8(지하철역)이 아닌 카테고리는 없어야함"
        )
    }
}
