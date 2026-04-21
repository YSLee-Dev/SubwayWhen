//
//  TotalLoadModelTests.swift
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

final class TotalLoadModelTests: XCTestCase {
    
    // MARK: - Properties
    
    var mockLoadModel: MockLoadModel!
    var totalLoadModel: TotalLoadModel!
    var mockCoreDataScheduleManager: MockCoreDataScheduleManager!
    
    // MARK: - LifeCycle
    
    override func setUp(){
        self.mockLoadModel = .init()
        self.mockCoreDataScheduleManager = .init()
        self.totalLoadModel = .init(loadModel: self.mockLoadModel, coreDataManager: self.mockCoreDataScheduleManager)
    }
    
    override func tearDown() {
        // 신분당선 시간표를 제거합니다.
        self.mockCoreDataScheduleManager.clearAll()
    }
    
    // MARK: - Tests
    
    func testTotalLiveDataLoad(){
        // GIVEN
        self.mockLoadModel.setSuccess(arrivalDummyData)
        let data = self.totalLoadModel.totalLiveDataLoad(stations: [arrivalGyodaeStation3Line])
        
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestStationName = arrayData.first?.0.stationName
        let dummyStationName = arrivalDummyData.realtimeArrivalList.first?.stationName
        
        let requestType = arrayData.first?.0.type
        let dummyType = MainTableViewCellType.real
        
        let requestLine = arrayData.first?.0.subwayLineData.rawValue
        let dummyLine = "03호선"
        
        let requestCode = arrayData.first?.0.code
        let dummyCode = arrivalDummyData.realtimeArrivalList.first?.code
        
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
        self.mockLoadModel.setSuccess(arrivalErrorData)
        let data = self.totalLoadModel.totalLiveDataLoad(stations: [arrivalGyodaeStation3Line])
        
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestCode = arrayData.first?.0.code
        let dummyStationCode = "현재 실시간 열차 데이터가 없어요."
        
        let requestStationName = arrayData.first?.0.stationName
        let dummyStationName = "교대"
        
        let requestBackId = arrayData.first?.0.backStationId
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
    
    func testSingleLiveDataLoad() {
        // GIVEN
        self.mockLoadModel.setSuccess(arrivalDummyData)
        let data = self.totalLoadModel.singleLiveDataLoad(requestModel: detailArrivalDataRequestDummyModel)
        let blocking = data.toBlocking()
        let requestData = try! blocking.toArray().first
        
        // WHEN
        let requestStationName = requestData?.first?.stationName
        let dummyStationName = arrivalDummyData.realtimeArrivalList.first?.stationName
        
        let requestNextName = requestData?.first?.nextStationName
        let dummyNextName = "고속터미널" // dummy 데이터 기반 고정 값
        
        let requestCode = requestData?.first?.code
        let dummyCode = arrivalDummyData.realtimeArrivalList.first?.code
        
        // THEN
        expect(requestStationName).to(
            equal(dummyStationName),
            description: "지하철 역명은 동일해야함"
        )
        
        expect(requestNextName).to(
            equal(dummyNextName),
            description: "기본 데이터가 같으므로, 지하철 역 이름도 동일해야함"
        )
        
        expect(requestCode).to(
            equal(dummyCode),
            description: "기본 데이터가 같으므로, code 또한 동일해야함"
        )
    }
    
    func testSingleLiveDataLoadError() {
        // GIVEN
        self.mockLoadModel.setSuccess(arrivalErrorData)
        let data = self.totalLoadModel.singleLiveDataLoad(requestModel: detailArrivalDataRequestDummyModel)
        let blocking = data.toBlocking()
        let requestData = try! blocking.toArray().first
        
        // WHEN
        let requestStationName = requestData?.first?.stationName
        let dummyStationName = detailArrivalDataRequestDummyModel.stationName
        
        let requestNextName = requestData?.first?.nextStationName
        let dummyNextName = ""
        
        let requestCode = requestData?.first?.code
        let dummyCode = ""
        
        // THEN
        expect(requestStationName).to(
            equal(dummyStationName),
            description: "열차 데이터를 받아오지 못해도 역 이름은 동일해야함"
        )
        
        expect(requestNextName).to(
            equal(dummyNextName),
            description: "열차 데이터를 받아오지 못할 때는 다음 지하철역 이름이 없어야함"
        )
        
        expect(requestCode).to(
            equal(dummyCode),
            description: "열차 데이터를 받아오지 못할 때는 빈 code 값이 나와야함"
        )
    }
    
    func testSeoulScheduleLoad_isFirst_isNow(){
        // GIVEN
        self.mockLoadModel.setSuccess(seoulScheduleDummyData)
        let data = self.totalLoadModel.seoulScheduleLoad(scheduleGyodaeStation3Line, isFirst: true, isNow: true, isWidget: false)
        
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestCount = arrayData.first?.count
        let dummyCount = 1
        
        let requestStart = arrayData.first?.first?.startTime
        let dummyStart = seoulScheduleDummyData.SearchSTNTimeTableByFRCodeService.row.first?.startTime
        
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
        self.mockLoadModel.setSuccess(seoulScheduleDummyData)
        let data = self.totalLoadModel.seoulScheduleLoad(scheduleGyodaeStation3Line, isFirst: true, isNow: false, isWidget: false)
        
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestCount = arrayData.first?.count
        let dummyCount = 1
        
        let requestStart = arrayData.first?.first?.startTime
        let dummyStart = seoulScheduleDummyData.SearchSTNTimeTableByFRCodeService.row.first?.startTime
        
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
        self.mockLoadModel.setSuccess(seoulScheduleDummyData)
        let data = self.totalLoadModel.seoulScheduleLoad(scheduleGyodaeStation3Line, isFirst: false, isNow: true, isWidget: false)
        
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestCount = arrayData.first?.count
        let dummyCount = seoulScheduleDummyData.SearchSTNTimeTableByFRCodeService.row.count
        
        let requestStart = arrayData.first?.first?.startTime
        let dummyStart = seoulScheduleDummyData.SearchSTNTimeTableByFRCodeService.row.first?.startTime
        
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
        self.mockLoadModel.setSuccess(seoulScheduleDummyData)
        let data = self.totalLoadModel.seoulScheduleLoad(scheduleGyodaeStation3Line, isFirst: false, isNow: false, isWidget: false)
        
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestCount = arrayData.first?.count
        let dummyCount = seoulScheduleDummyData.SearchSTNTimeTableByFRCodeService.row.count
        
        let requestStart = arrayData.first?.first?.startTime
        let dummyStart = seoulScheduleDummyData.SearchSTNTimeTableByFRCodeService.row.first?.startTime
        
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
    
    func testSeoulScheduleLoadServerError(){
        // GIVEN
        self.mockLoadModel.setSuccess(arrivalErrorData)
        let data = self.totalLoadModel.seoulScheduleLoad(scheduleK215K1Line, isFirst: false, isNow: false, isWidget: false)
        
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
    
    func testSeoulScheduleLoadInputError(){
        // GIVEN
        self.mockLoadModel.setSuccess(arrivalErrorData)
        let data = self.totalLoadModel.seoulScheduleLoad(
            .init(stationCode: "0", upDown: "행", exceptionLastStation: "", line: "03호선", korailCode: "", stationName: "")
            , isFirst: false, isNow: false, isWidget: false)
        
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
        // GIVEN
        self.mockLoadModel.setKorailTrainNumber(korailTrainNumber)
        self.mockLoadModel.setSuccess(korailHeaderDummyData)
        
        let data = self.totalLoadModel.korailSchduleLoad(scheduleSearch: scheduleK215K1Line,isFirst: true, isNow: true, isWidget: false)
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray().first!
    
        // WHEN
        let requestCount = arrayData.count
        let dummyCount = 1
        
        let requestStart = arrayData.first?.startTime
        let dummyStart = korailScheduleDummyData.first?.time
        
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
    
    func testKorailScheduleLoad_isFirst(){
        // GIVEN
        self.mockLoadModel.setKorailTrainNumber(korailTrainNumber)
        self.mockLoadModel.setSuccess(korailHeaderDummyData)
        
        let data = self.totalLoadModel.korailSchduleLoad(scheduleSearch: scheduleK215K1Line,isFirst: true, isNow: false, isWidget: false)
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray().first!
    
        // WHEN
        let requestCount = arrayData.count
        let dummyCount = 1
        
        let requestStart = arrayData.first?.startTime
        let dummyStart = korailScheduleDummyData.first?.time
        
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "isFirst가 true이기 때문에 하나의 데이터만 가져와야 함"
        )
        
        expect(requestStart).to(
            equal(dummyStart),
            description: "기본 데이터 및 정렬이 같고, isNow가 false이기 때문에 데이터가 같아야함"
        )
    }
    
    func testKorailScheduleLoad_isNow(){
        // GIVEN
        self.mockLoadModel.setKorailTrainNumber(korailTrainNumber)
        self.mockLoadModel.setSuccess(korailHeaderDummyData)
        
        let data = self.totalLoadModel.korailSchduleLoad(scheduleSearch: scheduleK215K1Line,isFirst: false, isNow: true, isWidget: false)
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray().first!
    
        // WHEN
        let requestCount = arrayData.count
        let dummyCount = korailScheduleDummyData.count
        
        let requestStart = arrayData.first?.startTime
        let dummyStart = korailScheduleDummyData.first?.time
        
        // THEN
        expect(requestCount).toNot(
            equal(dummyCount),
            description: "isNow가 true이기 때문에 count는 달라야함"
        )
        
        expect(requestStart).toNot(
            equal(dummyStart),
            description: "isNow가 true이기 때문에 시작하는 시간이 달라야함"
        )
    }
    
    func testKorailScheduleLoad(){
       // GIVEN
        self.mockLoadModel.setKorailTrainNumber(korailTrainNumber)
        self.mockLoadModel.setSuccess(korailHeaderDummyData)
        
        let data = self.totalLoadModel.korailSchduleLoad(scheduleSearch: scheduleK215K1Line,isFirst: false, isNow: false, isWidget: false)
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray().first!
    
        // WHEN
        let requestCount = arrayData.count
        let dummyCount = korailScheduleDummyData.count
        
        let requestStart = arrayData.first?.startTime
        let dummyStart = korailScheduleDummyData.first?.time
        
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "데이터가 동일하기 때문에 count도 동일해야함"
        )
        
        expect(requestStart).to(
            equal(dummyStart),
            description: "데이터가 동일하기 때문에 첫 번째 값도 동일해야함"
        )
    }
    
    func testKorailScheduleLoadInputError(){
        // GIVEN
        self.mockLoadModel.setKorailTrainNumber(korailTrainNumber)
        self.mockLoadModel.setSuccess(korailHeaderDummyData)
        
        let data = self.totalLoadModel.korailSchduleLoad(
            scheduleSearch: .init(stationCode: "0", upDown: "하행", exceptionLastStation: "", line: "", korailCode: "K1", stationName: ""),
            isFirst: false,
            isNow: false,
            isWidget: false
        )
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray().first!
        
        // WHEN
        let requestCount = arrayData.count
        let dummyCount = 1
        
        let requestStart = arrayData.first?.startTime
        let dummyStart = "정보없음"
        
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "정보가 없으면 카운트는 1이 되어야 함"
        )
        
        expect(requestStart).to(
            equal(dummyStart),
            description: "정보가 없으면 (정보없음)으로 통일되어야 함"
        )
    }
    
    func testStationNameSearchResponse() async {
        // GIVEN
        self.mockLoadModel.setSuccess(stationNameSearcDummyhData)
        let data = await self.totalLoadModel.stationNameSearchReponse("교대")
        
        // WHEN
        let requestCount = data.count
        let dummyCount = stationNameSearcDummyhData.SearchInfoBySubwayNameService.row.count
        
        let requestStationName = data.first?.stationName
        let dummyStationName = "교대"
        
        let requestFirstLine = data.first?.line
        let dummyFirstLine = stationNameSearcDummyhData.SearchInfoBySubwayNameService.row.first?.line
        
        //THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "같은 데이터이기 때문에 count도 같아야함"
        )
        
        expect(requestStationName).to(
            equal(dummyStationName),
            description: "StationName은 검색한 역이 나와야함"
        )
        
        /// v1.7에 정렬이 추가됨에 따라 테스트 케이스 변경
        expect(requestFirstLine).toNot(
            equal(dummyFirstLine),
            description: "같은 데이터여도 내부 정렬이 되기 때문에 Line이 다름 (2, 3 호선 순서)"
        )
    }
    
    func testStationNameSearchReponseError() async {
        // GIVEN
        self.mockLoadModel.setSuccess(arrivalErrorData)
        let data = await self.totalLoadModel.stationNameSearchReponse("교대")
        
        // WHEN
        let requestCount = data.count
        let requestStationName = data.first?.stationName
        let requestFirstLine = data.first?.line
        
        // THEN
        expect(requestCount).to(
            equal(0),
            description: "데이터가 없을 때는 빈 배열 (개수가 0)이 나와야함"
        )
        
        expect(requestStationName).to(
            beNil(),
            description: "데이터가 없을 때는 Nil이 나와야함"
        )
        
        expect(requestFirstLine).to(
            beNil(),
            description: "데이터가 없을 때는 Nil이 나와야함"
        )
    }
    
    func testVicinityStationsDataLoad() async {
        // GIVEN
        self.mockLoadModel.setSuccess(vicinityStationsDummyData)
        let data = await self.totalLoadModel.vicinityStationsDataLoad(
            x: 37.49388026940836, y: 127.01360357128935
        )
        let dummyData = vicinityStationsDummyData.documents
        
        // WHEN
        let requestFirstDataName = data.first?.name
        let dummyFirstDataName = dummyData.first?.name
        
        let requestCategoryCount = data.count
        let dummyCategoryCount = dummyData.filter {$0.category == "SW8"}.count
        
        let requestSortData = data.map {$0.distance}
        let dummySortData = dummyData.filter {$0.category == "SW8"} .sorted {
            let first = Int($0.distance) ?? 0
            let second = Int($1.distance) ?? 1
            return first < second
        }.map {data in
            guard let doubleValue = Int(data.distance) else {return "정보없음"}
            let numberFomatter = NumberFormatter()
            numberFomatter.numberStyle = .decimal
            
            guard let newValue = numberFomatter.string(for: doubleValue) else {return "정보없음"}
            return "\(newValue)m"
        }
        
        // THEN
        expect(requestFirstDataName).toNot(
            equal(dummyFirstDataName),
            description: "정렬이 적용되어 있지 않은 dummy하고는 첫번째 값은 달라야함"
        )
        
        expect(requestCategoryCount).to(
            equal(dummyCategoryCount),
            description: "SW8(지하철역)이 아닌 카테고리는 없어야함"
        )
        
        expect(requestSortData).to(
            equal(dummySortData),
            description: "정렬된 데이터의 거리는 동일해야함"
        )
    }
    
    func testVicinityStationDataLoadError() async {
        // GIVEN
        self.mockLoadModel.setSuccess(arrivalErrorData)
        let data = await self.totalLoadModel.vicinityStationsDataLoad(
            x: 37.49388026940836, y: 127.01360357128935
        )
        
        // WHEN
        let requestCount = data.count
        let dummyCount = 0
        
        let requestFirstData = data.first
        
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "데이터 오류 발생 시 빈 배열을 return 해야함"
        )
        
        expect(requestFirstData).to(
            beNil(),
            description: "데이터 오류 발생 시 빈 배열을 return 하기 때문에 값은 nil 이여야 함"
        )
    }
    
    func testWidgetSeoulScheduleLoad() {
        // GIVEN
        self.mockLoadModel.setSuccess(seoulScheduleDummyData)
        let data = self.totalLoadModel.seoulScheduleLoad(scheduleGyodaeStation3Line, isFirst: false, isNow: true, isWidget: true)
        
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestCount = arrayData.first?.count
        let dummyCount = seoulScheduleDummyData.SearchSTNTimeTableByFRCodeService.row.count
        
        let requestStart = arrayData.first?.first?.startTime
        let dummyStart = seoulScheduleDummyData.SearchSTNTimeTableByFRCodeService.row.first?.startTime
        
        let requestType = arrayData.first?.first?.type
        let dummyType = ScheduleType.Seoul
        
        // THEN
        expect(requestCount).toNot(
            equal(dummyCount),
            description: "위젯 데이터는 isNow가 True이기 때문에 개수가 달라야함"
        )
        
        expect(requestStart).toNot(
            equal(dummyStart),
            description: "위젯 데이터는 isNow가 True이기 때문에 시작 값이 달라야함"
        )
        
        expect(requestType).to(
            equal(dummyType),
            description: "서울 지하철이기 때문에 Seoul 타입이 반환되어야 함"
        )
    }
    
    func testWidgetSeoulScheduleLoad_ErrorOne() {
        // GIVEN
        self.mockLoadModel.setSuccess(arrivalErrorData)
        let data = self.totalLoadModel.seoulScheduleLoad(
            .init(stationCode: "0", upDown: "행", exceptionLastStation: "", line: "03호선", korailCode: "", stationName: ""),
            isFirst: false,
            isNow: true,
            isWidget: true
        )
        
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestCount = arrayData.first?.count
        let dummyCount = 1
        
        let requestStartTime = arrayData.first?.first?.startTime
        let dummyStartTime = "정보없음"
        
        let requestStartStation = arrayData.first?.first?.startStation
        let dummyStartStation = "정보없음"
        
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "위젯 데이터도 오류 발생 시 데이터는 1개로 동일함"
        )
        
        expect(requestStartTime).to(
            equal(dummyStartTime),
            description: "일반적인 오류 발생 시 정보없음으로 오류 동일함"
        )
        
        expect(requestStartStation).to(
            equal(dummyStartStation),
            description: "일반적인 오류 발생 시 정보없음으로 오류  동일함"
        )
    }
    
    func testWidgetSeoulScheduleLoad_ErrorTwo() {
        // GIVEN
        var components = Calendar.current.dateComponents([.hour, .minute], from: .now)
        components.hour = 23
        components.minute = 59
        let requestDate = Calendar.current.date(from: components)!
        
        self.mockLoadModel.setSuccess(seoulScheduleDummyData)
        let data = self.totalLoadModel.seoulScheduleLoad(scheduleGyodaeStation3Line, isFirst: false, isNow: true, isWidget: true, requestDate: requestDate)
        
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestCount = arrayData.first?.count
        let dummyCount = 1
        
        let requestStartTime = arrayData.first?.first?.startTime
        let dummyStartTime = "-"
        
        let requestStartStation = arrayData.first?.first?.startStation
        let dummyStartStation = ""
        
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "위젯 데이터도 오류 발생 시 데이터는 1개로 동일함"
        )
        
        expect(requestStartTime).to(
            equal(dummyStartTime),
            description: "위젯 데이터는 isNow로 인해 데이터가 없는 경우 -로 표시"
        )
        
        expect(requestStartStation).to(
            equal(dummyStartStation),
            description: "위젯 데이터는 isNow로 인해 데이터가 없는 경우 공백으로 표시"
        )
    }
    
    func testWidgetKorailScheduleLoad(){
        // GIVEN
        self.mockLoadModel.setKorailTrainNumber(korailTrainNumber)
        self.mockLoadModel.setSuccess(korailHeaderDummyData)
        let data = self.totalLoadModel.korailSchduleLoad(scheduleSearch: scheduleK215K1Line,isFirst: false, isNow: true, isWidget: true)
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray().first!
    
        // WHEN
        let requestCount = arrayData.count
        let dummyCount = korailScheduleDummyData.count
        
        let requestStart = arrayData.first?.startTime
        let dummyStart = korailScheduleDummyData.first?.time
        
        let requestType = arrayData.first?.type
        let dummyType = ScheduleType.Korail
        
        // THEN
        expect(requestCount).toNot(
            equal(dummyCount),
            description: "위젯 데이터는 isNow가 True이기 때문에 개수가 달라야함"
        )
        
        expect(requestStart).toNot(
            equal(dummyStart),
            description: "위젯 데이터는 isNow가 True이기 때문에 시작 값이 달라야함"
        )
        
        expect(requestType).to(
            equal(dummyType),
            description: "타입은 동일해야함"
        )
    }
    
    func testWidgetKorailScheduleLoad_ErrorOne(){
        // GIVEN
        self.mockLoadModel.setKorailTrainNumber(korailTrainNumber)
        self.mockLoadModel.setSuccess(korailHeaderDummyData)
        let data = self.totalLoadModel.korailSchduleLoad(
            scheduleSearch: .init(stationCode: "0", upDown: "하행", exceptionLastStation: "", line: "", korailCode: "K1", stationName: ""),
            isFirst: false,
            isNow: true,
            isWidget: true
        )
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray().first!
        
        // WHEN
        let requestCount = arrayData.count
        let dummyCount = 1
        
        let requestStartTime = arrayData.first?.startTime
        let dummyStartTime = "정보없음"
        
        let requestStartStation = arrayData.first?.startStation
        let dummyStartStation = "정보없음"
        
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "위젯 데이터도 오류 발생 시 데이터는 1개로 동일함"
        )
        
        expect(requestStartTime).to(
            equal(dummyStartTime),
            description: "일반적인 오류 발생 시 정보없음으로 오류 동일함"
        )
        
        expect(requestStartStation).to(
            equal(dummyStartStation),
            description: "일반적인 오류 발생 시 정보없음으로 오류 동일함"
        )
    }
    
    func testWidgetKorailScheduleLoad_ErrorTwo(){
        // GIVEN
        var components = Calendar.current.dateComponents([.hour, .minute], from: .now)
        components.hour = 23
        components.minute = 59
        let requestDate = Calendar.current.date(from: components)!
        
        self.mockLoadModel.setKorailTrainNumber(korailTrainNumber)
        self.mockLoadModel.setSuccess(korailHeaderDummyData)
        let data = self.totalLoadModel.korailSchduleLoad(
           scheduleSearch: scheduleK215K1Line,
            isFirst: false,
            isNow: true,
            isWidget: true,
           requestDate: requestDate
        )
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray().first!
        
        // WHEN
        let requestCount = arrayData.count
        let dummyCount = 1
        
        let requestStartTime = arrayData.first?.startTime
        let dummyStartTime = "-"
        
        let requestStartStation = arrayData.first?.startStation
        let dummyStartStation = ""
        
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "위젯 데이터도 오류 발생 시 데이터는 1개로 동일함"
        )
        
        expect(requestStartTime).to(
            equal(dummyStartTime),
            description: "위젯 데이터는 isNow로 인해 데이터가 없는 경우 -로 표시"
        )
        
        expect(requestStartStation).to(
            equal(dummyStartStation),
            description: "위젯 데이터는 isNow로 인해 데이터가 없는 경우 공백으로 표시"
        )
    }
    
    func testShinbundangScheduleLoad() {
        // GIVEN
        self.mockLoadModel.setSuccess(shinbundagSinsaStationScheduleDummyData)
        self.mockLoadModel.setShinbundangScheduleVersion(1.0)
        let data = self.totalLoadModel.shinbundangScheduleLoad(scheduleSearch: scheduleSinsaShinbundagLine, isFirst: false, isNow: false, isWidget: false)
        let blocking = data.toBlocking()
        let requestData = try! blocking.toArray().first!
        
        let dummyData = shinbundagSinsaStationScheduleDummyData
        
        // WHEN
        let requestCount = requestData.count
        let dummyCount = dummyData.count
        
        let requestFirstStartTime = requestData.first?.startTime
        let dummyFirstStartTime = dummyData.first?.startTime
        
        let requestTypeCount = requestData.filter {$0.type == .Shinbundang}.count
        let dummyTypeCount = dummyData.count
        
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "데이터가 동일하기 때문에 총 개수도 동일해야함"
        )
        
        expect(requestFirstStartTime).to(
            equal(dummyFirstStartTime),
            description: "기본 데이터가 동일하고, isNow가 false이기 때문에 데이터가 동일해야함"
        )
        
        expect(requestTypeCount).to(
            equal(dummyTypeCount),
            description: "신분당선 시간표의 모든 데이터의 타입은 신분당선으로 동일해야함"
        )
    }
    
    func testShinbundangScheduleLoad_isFirst_isNow() {
        // GIVEN
        self.mockLoadModel.setSuccess(shinbundagSinsaStationScheduleDummyData)
        self.mockLoadModel.setShinbundangScheduleVersion(1.0)
        let data = self.totalLoadModel.shinbundangScheduleLoad(scheduleSearch: scheduleSinsaShinbundagLine, isFirst: true, isNow: true, isWidget: false, requestDate: .now)
        let blocking = data.toBlocking()
        let requestData = try! blocking.toArray().first!
        
        let dummyData = shinbundagSinsaStationScheduleDummyData
        
        // WHEN
        let requestCount = requestData.count
        let dummyCount = 1
        
        let requestFirstStartTime = requestData.first?.startTime
        let dummyFirstStartTime = dummyData.first?.startTime
        
        let requestType = requestData.first?.type
        let dummyType = ScheduleType.Shinbundang
        
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "isFirst가 true이기 때문에 하나의 데이터만 가져와야 함"
        )
        
        expect(requestFirstStartTime).toNot(
            equal(dummyFirstStartTime),
            description: "기본 데이터가 같지만, isNow가 true이기 때문에 데이터가 달라야함"
        )
        
        expect(requestType).to(
            equal(dummyType),
            description: "신분당선 시간표의 모든 데이터의 타입은 신분당선으로 동일해야함"
        )
    }
    
    func testShinbundangScheduleLoad_isFirst() {
        // GIVEN
        self.mockLoadModel.setSuccess(shinbundagSinsaStationScheduleDummyData)
        self.mockLoadModel.setShinbundangScheduleVersion(1.0)
        let data = self.totalLoadModel.shinbundangScheduleLoad(scheduleSearch: scheduleSinsaShinbundagLine, isFirst: true, isNow: false, isWidget: false, requestDate: .now)
        let blocking = data.toBlocking()
        let requestData = try! blocking.toArray().first!
        
        let dummyData = shinbundagSinsaStationScheduleDummyData
        
        // WHEN
        let requestCount = requestData.count
        let dummyCount = 1
        
        let requestFirstStartTime = requestData.first?.startTime
        let dummyFirstStartTime = dummyData.first?.startTime
        
        let requestType = requestData.first?.type
        let dummyType = ScheduleType.Shinbundang
        
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "isFirst가 true이기 때문에 하나의 데이터만 가져와야 함"
        )
        
        expect(requestFirstStartTime).to(
            equal(dummyFirstStartTime),
            description: "기본 데이터 및 정렬이 같고, isNow가 false이기 때문에 데이터가 같아야함"
        )
        
        expect(requestType).to(
            equal(dummyType),
            description: "신분당선 시간표의 모든 데이터의 타입은 신분당선으로 동일해야함"
        )
    }
    
    func testShinbundangScheduleLoad_isNow() {
        // GIVEN
        self.mockLoadModel.setSuccess(shinbundagSinsaStationScheduleDummyData)
        self.mockLoadModel.setShinbundangScheduleVersion(1.0)
        let data = self.totalLoadModel.shinbundangScheduleLoad(scheduleSearch: scheduleSinsaShinbundagLine, isFirst: false, isNow: true, isWidget: false, requestDate: .now)
        let blocking = data.toBlocking()
        let requestData = try! blocking.toArray().first!
        
        let dummyData = shinbundagSinsaStationScheduleDummyData
        
        // WHEN
        let requestCount = requestData.count
        let dummyCount = dummyData.count
        
        let requestFirstStartTime = requestData.first?.startTime
        let dummyFirstStartTime = dummyData.first?.startTime
        
        let requestType = requestData.first?.type
        let dummyType = ScheduleType.Shinbundang
        
        // THEN
        expect(requestCount).toNot(
            equal(dummyCount),
            description: "isNow가 true이기 때문에 count는 달라야함"
        )
        
        expect(requestFirstStartTime).toNot(
            equal(dummyFirstStartTime),
            description: "isNow가 true이기 때문에 시작하는 시간이 달라야함"
        )
        
        expect(requestType).to(
            equal(dummyType),
            description: "신분당선 시간표의 모든 데이터의 타입은 신분당선으로 동일해야함"
        )
    }
    
    func testShinbundangScheduleLoad_CoreData() {
        // GIVEN
        self.mockLoadModel.setSuccess(shinbundagSinsaStationScheduleDummyData)
        self.mockLoadModel.setShinbundangScheduleVersion(1.0)
        
        // 첫 요청이기 때문에 파이어베이스 데이터를 사용하는 데이터
        let firstData = self.totalLoadModel.shinbundangScheduleLoad(scheduleSearch: scheduleSinsaShinbundagLine, isFirst: false, isNow: false, isWidget: false)
        let firstBlocking = firstData.toBlocking()
        let firstRequestData = try! firstBlocking.toArray().first!
        
        // 두 번째 요청이기 때문에 저장된 코어데이터를 사용하는 데이터
        let secondData = self.totalLoadModel.shinbundangScheduleLoad(scheduleSearch: scheduleSinsaShinbundagLine, isFirst: false, isNow: false, isWidget: false)
        let secondBlocking = secondData.toBlocking()
        let secondRequestData = try! secondBlocking.toArray().first!
        
        // WHEN
        let requestOneCount = firstRequestData.count
        let requestTwoCount = secondRequestData.count
        
        let requestOneFirstData = firstRequestData.first
        let requestTwoFirstData = secondRequestData.first
        
        let requestOneTypeCount = firstRequestData.filter {$0.type == .Shinbundang}.count
        let requestTwoTypeCount = secondRequestData.filter {$0.type == .Shinbundang}.count
        
        let liveDataRequestCount = 1
        let coreDataRequestCount = 2
        
        // THEN
        expect(requestOneCount).to(
            equal(requestTwoCount),
            description: "FireBase 데이터와 로컬 데이터는 동일해야함"
        )
        
        expect(requestOneFirstData).to(
            equal(requestTwoFirstData),
            description: "기본 데이터가 동일하고, isNow가 false이기 때문에 데이터가 동일해야함"
        )
        
        expect(requestOneTypeCount).to(
            equal(requestTwoTypeCount),
            description: "신분당선 시간표의 모든 데이터의 타입은 신분당선으로 동일해야함"
        )
        
        expect(self.mockLoadModel.shinbundangScheduleRequestCount).to(
            equal(liveDataRequestCount),
            description: "실제 데이터 요청(firebase)은 1회만 되어야 함"
        )
        
        expect(self.mockCoreDataScheduleManager.scheduleLoadCount).to(
            equal(coreDataRequestCount),
            description: "CoreData에 데이터를 요청한 횟수는 2이어야 함"
        )
    }
    
    func testShinbundangScheduleLoad_CoreData_버전변경() {
        // GIVEN
        self.mockLoadModel.setSuccess(shinbundagSinsaStationScheduleDummyData)
        self.mockLoadModel.setShinbundangScheduleVersion(1.0)
        
        // 첫 요청이기 때문에 파이어베이스 데이터를 사용하는 데이터
        let firstData = self.totalLoadModel.shinbundangScheduleLoad(scheduleSearch: scheduleSinsaShinbundagLine, isFirst: false, isNow: false, isWidget: false)
        let firstBlocking = firstData.toBlocking()
        let firstRequestData = try! firstBlocking.toArray().first!
        
        self.mockLoadModel.setShinbundangScheduleVersion(1.1)
        
        // 두 번째 요청이지만 버전이 변경되었기 때문에 파이어베이스 데이터를 사용하는 데이터
        let secondData = self.totalLoadModel.shinbundangScheduleLoad(scheduleSearch: scheduleSinsaShinbundagLine, isFirst: false, isNow: false, isWidget: false)
        let secondBlocking = secondData.toBlocking()
        let secondRequestData = try! secondBlocking.toArray().first!
        
        // WHEN
        let requestOneCount = firstRequestData.count
        let requestTwoCount = secondRequestData.count
        
        let requestOneFirstData = firstRequestData.first
        let requestTwoFirstData = secondRequestData.first
        
        let requestOneTypeCount = firstRequestData.filter {$0.type == .Shinbundang}.count
        let requestTwoTypeCount = secondRequestData.filter {$0.type == .Shinbundang}.count
        
        let liveDataRequestCount = 2
        let coreDataRequestCount = 2
        
        // THEN
        expect(requestOneCount).to(
            equal(requestTwoCount),
            description: "FireBase 데이터와 로컬 데이터는 동일해야함"
        )
        
        expect(requestOneFirstData).to(
            equal(requestTwoFirstData),
            description: "기본 데이터가 동일하고, isNow가 false이기 때문에 데이터가 동일해야함"
        )
        
        expect(requestOneTypeCount).to(
            equal(requestTwoTypeCount),
            description: "신분당선 시간표의 모든 데이터의 타입은 신분당선으로 동일해야함"
        )
        
        expect(self.mockLoadModel.shinbundangScheduleRequestCount).to(
            equal(liveDataRequestCount),
            description: "실제 데이터 요청(firebase)은 2회가 되어야 함"
        )
        
        expect(self.mockCoreDataScheduleManager.scheduleLoadCount).to(
            equal(coreDataRequestCount),
            description: "CoreData에 데이터를 요청한 횟수는 2이어야 함"
        )
    }
    
    func testShinbundangScheduleLoad_Disposable() {
        // GIVEN
        self.mockLoadModel.setSuccess(shinbundagSinsaStationScheduleDummyData)
        self.mockLoadModel.setShinbundangScheduleVersion(1.0)
        
        // 첫 요청이기 때문에 파이어베이스 데이터를 사용하는 데이터
        let firstData = self.totalLoadModel.shinbundangScheduleLoad(scheduleSearch: scheduleSinsaShinbundagLine, isFirst: false, isNow: false, isWidget: false, isDisposable: true)
        let firstBlocking = firstData.toBlocking()
        let firstRequestData = try! firstBlocking.toArray().first!
        
        // 두 번째 요청이여도 isDisposable 상태가 true이기때문에 파어어베이스 데이터를 사용해야함
        let secondData = self.totalLoadModel.shinbundangScheduleLoad(scheduleSearch: scheduleSinsaShinbundagLine, isFirst: false, isNow: false, isWidget: false, isDisposable: true)
        let secondBlocking = secondData.toBlocking()
        let secondRequestData = try! secondBlocking.toArray().first!
        
        // WHEN
        let requestOneCount = firstRequestData.count
        let requestTwoCount = secondRequestData.count
        
        let requestOneFirstData = firstRequestData.first
        let requestTwoFirstData = secondRequestData.first
        
        let requestOneTypeCount = firstRequestData.filter {$0.type == .Shinbundang}.count
        let requestTwoTypeCount = secondRequestData.filter {$0.type == .Shinbundang}.count
        
        let liveDataRequestCount = 2
        let coreDataRequestCount = 2
        
        // THEN
        expect(requestOneCount).to(
            equal(requestTwoCount),
            description: "둘 다 파이어베이스를 기반으로 한 데이터이기 때문에 동일해야함"
        )
        
        expect(requestOneFirstData).to(
            equal(requestTwoFirstData),
            description: "기본 데이터가 동일하고, isNow가 false이기 때문에 데이터가 동일해야함"
        )
        
        expect(requestOneTypeCount).to(
            equal(requestTwoTypeCount),
            description: "신분당선 시간표의 모든 데이터의 타입은 신분당선으로 동일해야함"
        )
        
        expect(self.mockLoadModel.shinbundangScheduleRequestCount).to(
            equal(liveDataRequestCount),
            description: "실제 데이터 요청(firebase)은 2회가 되어야 함"
        )
        
        expect(self.mockCoreDataScheduleManager.scheduleLoadCount).to(
            equal(coreDataRequestCount),
            description: "CoreData에 데이터를 요청한 횟수는 2이어야 함"
        )
    }
    
    func testRealtimePositionLoad_상행() async {
        // GIVEN
        self.mockLoadModel.setSuccess(realtimeTrainPositionResponseDummy)

        // WHEN
        let result = await self.totalLoadModel.realtimePositionLoad(
            subwayLine: .three,
            isUp: true,
            exceptionLastStation: ""
        )

        // THEN
        expect(result.count).to(
            equal(1),
            description: "상행(updnLine=0) 열차만 필터링되어야 함"
        )
        expect(result.first?.updnLine).to(
            equal("0"),
            description: "상행 열차의 updnLine은 0이어야 함"
        )
        expect(result.first?.trainNo).to(
            equal("3000"),
            description: "상행 열차 번호는 더미 데이터와 동일해야 함"
        )
    }

    func testRealtimePositionLoad_하행() async {
        // GIVEN
        self.mockLoadModel.setSuccess(realtimeTrainPositionResponseDummy)

        // WHEN
        let result = await self.totalLoadModel.realtimePositionLoad(
            subwayLine: .three,
            isUp: false,
            exceptionLastStation: ""
        )

        // THEN
        expect(result.count).to(
            equal(1),
            description: "하행(updnLine=1) 열차만 필터링되어야 함"
        )
        expect(result.first?.updnLine).to(
            equal("1"),
            description: "하행 열차의 updnLine은 1이어야 함"
        )
    }

    func testRealtimePositionLoad_제외역() async {
        // GIVEN
        self.mockLoadModel.setSuccess(realtimeTrainPositionResponseDummy)

        // WHEN
        let result = await self.totalLoadModel.realtimePositionLoad(
            subwayLine: .three,
            isUp: true,
            exceptionLastStation: "대화"
        )

        // THEN
        expect(result.count).to(
            equal(0),
            description: "종착역이 제외 역과 일치하는 열차는 필터링되어야 함"
        )
    }

    func testRealtimePositionLoadError() async {
        // GIVEN
        self.mockLoadModel.setFailure(URLError(.notConnectedToInternet))

        // WHEN
        let result = await self.totalLoadModel.realtimePositionLoad(
            subwayLine: .three,
            isUp: true,
            exceptionLastStation: ""
        )

        // THEN
        expect(result.count).to(
            equal(0),
            description: "네트워크 에러 시 빈 배열을 반환해야 함"
        )
    }

    func testStationIdList_기본호선() {
        // GIVEN: 3호선 (default case)
        // WHEN
        let result = self.totalLoadModel.stationIdList(subwayLine: .three)

        // THEN
        expect(result.count).to(
            equal(1),
            description: "3호선은 구간 분리 없이 세션 1개여야 함"
        )
        expect(result.first?.name).to(
            beNil(),
            description: "기본 구간의 이름은 nil이어야 함"
        )
    }

    func testStationIdList_2호선_구간분리() {
        // GIVEN: 2호선 (성수지선, 신정지선 분리)
        // WHEN
        let result = self.totalLoadModel.stationIdList(subwayLine: .two)

        // THEN
        expect(result.count).to(
            equal(3),
            description: "2호선은 본선/성수지선/신정지선 3개 세션이어야 함"
        )

        let sessionNames = result.compactMap { $0.name }
        expect(sessionNames).to(
            contain("성수지선"),
            description: "2호선 세션에 성수지선이 포함되어야 함"
        )
        expect(sessionNames).to(
            contain("신정지선"),
            description: "2호선 세션에 신정지선이 포함되어야 함"
        )
    }

    func testImportantDataLoad_서울시데이터() {
        // GIVEN
        self.mockLoadModel.setImportantData(ImportantData(title: "", contents: ""))
        self.mockLoadModel.setSuccess(subwayNoticeInfiniteDummyData)
        let data = self.totalLoadModel.importantDataLoad()
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestTitle = arrayData.first?.title
        let dummyTitle = subwayNotice.title
        
        // TotalModel은 하단에 추가 데이터가 있음 (96자 기준으로 dummy 데이터와 완전동일)
        let requestContents = String(arrayData.first?.contents.prefix(96) ?? "")
        let dummyContents = subwayNotice.content
        
        // THEN
        expect(requestTitle).to(
            equal(dummyTitle),
            description: "타이틀은 동일해야함"
        )
        
        expect(requestContents).to(
            equal(dummyContents),
            description: "컨텐츠 내용은 동일해야함"
        )
    }
    
    func testImportantDataLoad_서울시데이터_날짜지남() {
        // GIVEN
        self.mockLoadModel.setImportantData(ImportantData(title: "", contents: ""))
        self.mockLoadModel.setSuccess(subwayNoticeDummyData)
        let data = self.totalLoadModel.importantDataLoad()
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestTitle = arrayData.first?.title
        let dummyTitle = ""
        
        let requestContents = arrayData.first?.contents
        let dummyContents = ""
        
        // THEN
        expect(requestTitle).to(
            equal(dummyTitle),
            description: "타이틀이 없어야함"
        )
        
        expect(requestContents).to(
            equal(dummyContents),
            description: "컨텐츠 내용이 없어야함"
        )
    }
    
    func testImportantDataLoad_firebase데이터() {
        // GIVEN
        self.mockLoadModel.setImportantData(importantData)
        let data = self.totalLoadModel.importantDataLoad()
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestTitle = arrayData.first?.title
        let dummyTitle = importantData.title
        
        let requestContents = arrayData.first?.contents
        let dummyContents = importantData.contents
        
        // THEN
        expect(requestTitle).to(
            equal(dummyTitle),
            description: "타이틀은 동일해야함"
        )
        
        expect(requestContents).to(
            equal(dummyContents),
            description: "컨텐츠 내용은 동일해야함"
        )
    }
}
