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
    var arrivalTotalLoadModel : TotalLoadModel!
    var arrivalErrorTotalLoadModel : TotalLoadModel!
    var seoulScheduleLoadModel : TotalLoadModel!
    var korailScheduleLoadModel : TotalLoadModel!
    var stationNameSearchModel : TotalLoadModel!
    var kakaoVicinityStationModel: TotalLoadModel!
    var coreDataManager: CoreDataScheduleManagerProtocol!
    
    override func setUp(){
        let session = MockURLSession((response: urlResponse!, data: arrivalData))
        let networkManager = NetworkManager(session: session)
        let loadModel = LoadModel(networkManager: networkManager)
        
        self.arrivalTotalLoadModel = TotalLoadModel(loadModel: loadModel)
        
        self.arrivalErrorTotalLoadModel = TotalLoadModel(loadModel: LoadModel(networkManager: NetworkManager(session: MockURLSession(((response: urlResponse!, data: arrivalErrorData))))))
        self.seoulScheduleLoadModel = TotalLoadModel(loadModel: LoadModel(networkManager: NetworkManager(session: MockURLSession(((response: urlResponse!, data: seoulStationSchduleData))))))
        self.korailScheduleLoadModel = TotalLoadModel(loadModel: LoadModel(networkManager: NetworkManager(session: MockURLSession(((response: urlResponse!, data: korailStationSchduleData))))))
        
        let stationNameMock = MockURLSession((response: urlResponse!, data: stationNameSearchData))
        self.stationNameSearchModel = TotalLoadModel(loadModel: LoadModel(networkManager: NetworkManager(session: stationNameMock)))
        
        let vicinityMock = MockURLSession((response: urlResponse!, data: vicinityData))
        self.kakaoVicinityStationModel = TotalLoadModel(loadModel: LoadModel(networkManager: NetworkManager(session: vicinityMock)))
        
        self.coreDataManager = CoreDataScheduleManager.shared
    }
    
    override func tearDown() {
        // coreData에 저장되어 있는 신분당선 시간표를 제거합니다.
        self.coreDataManager.shinbundangScheduleDataRemove(stationName: scheduleSinsaShinbundagLine.stationName)
    }
    
    func testTotalLiveDataLoad(){
        // GIVEN
        let data = self.arrivalTotalLoadModel.totalLiveDataLoad(stations: [arrivalGyodaeStation3Line])
        
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestStationName = arrayData.first?.0.stationName
        let dummyStationName = arrivalDummyData.realtimeArrivalList.first?.stationName
        
        let requestType = arrayData.first?.0.type
        let dummyType = MainTableViewCellType.real
        
        let requestLine = arrayData.first?.0.lineNumber
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
        let data = self.arrivalErrorTotalLoadModel.totalLiveDataLoad(stations: [arrivalGyodaeStation3Line])
        
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
        let data = self.arrivalTotalLoadModel.singleLiveDataLoad(requestModel: detailArrivalDataRequestDummyModel)
        let blocking = data.toBlocking()
        let requestData = try! blocking.toArray().first
        
        let dummyData = arrivalDummyData
        
        // WHEN
        let requestStationName = requestData?.first?.stationName
        let dummyStationName = arrivalDummyData.realtimeArrivalList.first?.stationName
        
        let requestNextName = requestData?.first?.nextStationName
        let dummyNextName = ""
        
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
        let data = self.arrivalErrorTotalLoadModel.singleLiveDataLoad(requestModel: detailArrivalDataRequestDummyModel)
        let blocking = data.toBlocking()
        let requestData = try! blocking.toArray().first
        
        let dummyData = arrivalDummyData
        
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
        let data = self.seoulScheduleLoadModel.seoulScheduleLoad(scheduleGyodaeStation3Line, isFirst: true, isNow: true, isWidget: false)
        
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
        let data = self.seoulScheduleLoadModel.seoulScheduleLoad(scheduleGyodaeStation3Line, isFirst: true, isNow: false, isWidget: false)
        
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
        let data = self.seoulScheduleLoadModel.seoulScheduleLoad(scheduleGyodaeStation3Line, isFirst: false, isNow: true, isWidget: false)
        
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
        let data = self.seoulScheduleLoadModel.seoulScheduleLoad(scheduleGyodaeStation3Line, isFirst: false, isNow: false, isWidget: false)
        
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
        let data = self.arrivalErrorTotalLoadModel.seoulScheduleLoad(scheduleK215K1Line, isFirst: false, isNow: false, isWidget: false)
        
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
        let data = self.arrivalErrorTotalLoadModel.seoulScheduleLoad(
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
    
    // KorailTest: 테스트 객체는 외부환경에 의존하면 안되지만, FireBase에서 불러오는 데이터가 1000건이 넘으며, TrainCode 특성상 변경될 일이 없기 때문에 Observable을 기다리는 형태로 테스트 진행
    func testKorailScheduleLoad_isFirst_isNow(){
        let bag = DisposeBag()
        let testException = XCTestExpectation(description: "옵저버블 대기")
        
        // GIVEN
        var arrayData : [ResultSchdule] = []
        let data = self.korailScheduleLoadModel.korailSchduleLoad(scheduleSearch: scheduleK215K1Line,isFirst: true, isNow: true, isWidget: false)
        data
            .subscribe(onNext: {
                arrayData = $0
                testException.fulfill()
            })
            .disposed(by: bag)
        
    
        wait(for: [testException], timeout: 3)
    
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
        let bag = DisposeBag()
        let testException = XCTestExpectation(description: "옵저버블 대기")
        
        // GIVEN
        var arrayData : [ResultSchdule] = []
        let data = self.korailScheduleLoadModel.korailSchduleLoad(scheduleSearch: scheduleK215K1Line,isFirst: true, isNow: false, isWidget: false)
        data
            .subscribe(onNext: {
                arrayData = $0
                print($0)
                testException.fulfill()
            })
            .disposed(by: bag)
        
    
        wait(for: [testException], timeout: 3)
    
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
        let bag = DisposeBag()
        let testException = XCTestExpectation(description: "옵저버블 대기")
        
        // GIVEN
        var arrayData : [ResultSchdule] = []
        let data = self.korailScheduleLoadModel.korailSchduleLoad(scheduleSearch: scheduleK215K1Line,isFirst: false, isNow: true, isWidget: false)
        data
            .subscribe(onNext: {
                arrayData = $0
                print($0)
                testException.fulfill()
            })
            .disposed(by: bag)
        
    
        wait(for: [testException], timeout: 3)
    
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
        let bag = DisposeBag()
        let testException = XCTestExpectation(description: "옵저버블 대기")
        
        // GIVEN
        var arrayData : [ResultSchdule] = []
        let data = self.korailScheduleLoadModel.korailSchduleLoad(scheduleSearch: scheduleK215K1Line,isFirst: false, isNow: false, isWidget: false)
        data
            .subscribe(onNext: {
                arrayData = $0
                print($0)
                testException.fulfill()
            })
            .disposed(by: bag)
        
    
        wait(for: [testException], timeout: 3)
    
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
        let bag = DisposeBag()
        let testException = XCTestExpectation(description: "옵저버블 대기")
        
        // GIVEN
        var arrayData : [ResultSchdule] = []
        let data = self.korailScheduleLoadModel.korailSchduleLoad(
            scheduleSearch: .init(
                stationCode: "0", upDown: "하행", exceptionLastStation: "", line: "", korailCode: "K1", stationName: ""),
            isFirst: false, isNow: false, isWidget: false)
        data
            .subscribe(onNext: {
                arrayData = $0
                print($0)
                testException.fulfill()
            })
            .disposed(by: bag)
        
        
        wait(for: [testException], timeout: 3)
        
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
    
//    func testStationNameSearchReponse(){
//        // GIVEN
//        let data = self.stationNameSearchModel.stationNameSearchReponse("교대")
//        let blocking = data.toBlocking()
//        let arrayData = try! blocking.toArray()
//        
//        // WHEN
//        let requestCount = arrayData.first?.SearchInfoBySubwayNameService.row.count
//        let dummyCount = stationNameSearcDummyhData.SearchInfoBySubwayNameService.row.count
//        
//        let requestStationName = arrayData.first?.SearchInfoBySubwayNameService.row.first?.stationName
//        let dummyStationName = "교대"
//        
//        let requestFirstLine = arrayData.first?.SearchInfoBySubwayNameService.row.first?.lineNumber
//        let dummyFirstLine = stationNameSearcDummyhData.SearchInfoBySubwayNameService.row.first?.lineNumber
//        
//        // THEN
//        expect(requestCount).to(
//            equal(dummyCount),
//            description: "같은 데이터이기 때문에 count도 같아야함"
//        )
//        
//        expect(requestStationName).to(
//            equal(dummyStationName),
//            description: "StationName은 검색한 역이 나와야함"
//        )
//        
//        expect(requestFirstLine).to(
//            equal(dummyFirstLine),
//            description: "같은 데이터이기 때문에 첫 번째의 라인도 같아야함"
//        )
//    }
//    
//    func testStationNameSearchReponseError(){
//        // GIVEN
//        let data = self.arrivalErrorTotalLoadModel.stationNameSearchReponse("교대")
//        let blocking = data.toBlocking()
//        let arrayData = try! blocking.toArray()
//        
//        // WHEN
//        let requestCount = arrayData.first?.SearchInfoBySubwayNameService.row.count
//        
//        let requestStationName = arrayData.first?.SearchInfoBySubwayNameService.row.first?.stationName
//        
//        let requestFirstLine = arrayData.first?.SearchInfoBySubwayNameService.row.first?.lineNumber
//        
//        // THEN
//        expect(requestCount).to(
//            beNil(),
//            description: "데이터가 없을 때는 Nil이 나와야함"
//        )
//        
//        expect(requestStationName).to(
//            beNil(),
//            description: "데이터가 없을 때는 Nil이 나와야함"
//        )
//        
//        expect(requestFirstLine).to(
//            beNil(),
//            description: "데이터가 없을 때는 Nil이 나와야함"
//        )
//    }
//    
//    func testVicinityStationsDataLoad() {
//        // GIVEN
//        let data = self.kakaoVicinityStationModel.vicinityStationsDataLoad(
//            x: 37.49388026940836, y: 127.01360357128935
//        )
//        let blocking = data.toBlocking()
//        let requestData = try! blocking.toArray()
//        
//        let dummyData = vicinityStationsDummyData.documents
//        
//        // WHEN
//        let requestFirstDataName = requestData.first?.first?.name
//        let dummyFirstDataName = dummyData.first?.name
//        
//        let requestCategoryCount = requestData.first?.filter {
//            $0.category != "SW8"
//        }
//            .count
//        
//        let dummyCategoryCount = 0
//        
//        let requestSortData = requestData.first
//        let dummySortData = dummyData.sorted {
//            let first = Int($0.distance) ?? 0
//            let second = Int($1.distance) ?? 1
//            return first < second
//        }
//        
//        // THEN
//        expect(requestFirstDataName).toNot(
//            equal(dummyFirstDataName),
//            description: "정렬이 적용되어 있지 않은 dummy하고는 첫번째 값은 달라야함"
//        )
//        
//        expect(requestCategoryCount).to(
//            equal(dummyCategoryCount),
//            description: "SW8(지하철역)이 아닌 카테고리는 없어야함"
//        )
//        
//        expect(requestSortData).to(
//            equal(dummySortData),
//            description: "정렬된 데이터는 값이 동일해야함"
//        )
//    }
//    
//    func testVicinityStationDataLoadError() {
//        // GIVEN
//        let data = self.arrivalErrorTotalLoadModel.vicinityStationsDataLoad(
//            x: 37.49388026940836, y: 127.01360357128935
//        )
//        let blocking = data.toBlocking()
//        let arrayData = try! blocking.toArray()
//        
//        // WHEN
//        let requestCount = arrayData.first?.count
//        let dummyCount = 1
//        
//        let requestFirstData = arrayData.first?.first
//        let dummyFirstData: VicinityDocumentData? = VicinityDocumentData(name: "정보없음", distance: "정보없음", category: "정보없음")
//        
//        // THEN
//        expect(requestCount).to(
//            equal(dummyCount),
//            description: "데이터 오류 발생 시 데이터는 하나만 존재해야함"
//        )
//        
//        expect(requestFirstData).to(
//            equal(dummyFirstData),
//            description: "데이터 오류 발생 시 모든 데이터는 정보없음으로 표기되어야 함"
//        )
//    }
//    
    func testWidgetSeoulScheduleLoad() {
        // GIVEN
        let data = self.seoulScheduleLoadModel.seoulScheduleLoad(scheduleGyodaeStation3Line, isFirst: false, isNow: true, isWidget: true)
        
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
        let data = self.arrivalErrorTotalLoadModel.seoulScheduleLoad(
            .init(stationCode: "0", upDown: "행", exceptionLastStation: "", line: "03호선", korailCode: "", stationName: "")
            , isFirst: false, isNow: true, isWidget: true)
        
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
        
        let data = self.seoulScheduleLoadModel.seoulScheduleLoad(scheduleGyodaeStation3Line, isFirst: false, isNow: true, isWidget: true, requestDate: requestDate)
        
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
        let bag = DisposeBag()
        let testException = XCTestExpectation(description: "옵저버블 대기")
        
        // GIVEN
        var arrayData : [ResultSchdule] = []
        let data = self.korailScheduleLoadModel.korailSchduleLoad(scheduleSearch: scheduleK215K1Line,isFirst: false, isNow: true, isWidget: true)
        data
            .subscribe(onNext: {
                arrayData = $0
                testException.fulfill()
            })
            .disposed(by: bag)
        
    
        wait(for: [testException], timeout: 3)
    
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
        let bag = DisposeBag()
        let testException = XCTestExpectation(description: "옵저버블 대기")
        
        // GIVEN
        var arrayData : [ResultSchdule] = []
        let data = self.korailScheduleLoadModel.korailSchduleLoad(
            scheduleSearch: .init(
                stationCode: "0", upDown: "하행", exceptionLastStation: "", line: "", korailCode: "K1", stationName: ""),
            isFirst: false, isNow: true, isWidget: true)
        data
            .subscribe(onNext: {
                arrayData = $0
                print($0)
                testException.fulfill()
            })
            .disposed(by: bag)
        
        
        wait(for: [testException], timeout: 3)
        
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
        let bag = DisposeBag()
        let testException = XCTestExpectation(description: "옵저버블 대기")
        
        // GIVEN
        var components = Calendar.current.dateComponents([.hour, .minute], from: .now)
        components.hour = 23
        components.minute = 59
        let requestDate = Calendar.current.date(from: components)!
        
        var arrayData : [ResultSchdule] = []
        let data = self.korailScheduleLoadModel.korailSchduleLoad(scheduleSearch: scheduleK215K1Line,isFirst: false, isNow: true, isWidget: true, requestDate: requestDate)
        data
            .subscribe(onNext: {
                arrayData = $0
                testException.fulfill()
            })
            .disposed(by: bag)
        
        wait(for: [testException], timeout: 3)
        
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
        let requestObserverableData = self.seoulScheduleLoadModel.shinbundangScheduleLoad(scheduleSearch: scheduleSinsaShinbundagLine, isFirst: false, isNow: false, isWidget: false, requestDate: .now)
        let bag = DisposeBag()
        let testException = XCTestExpectation(description: "옵저버블 대기")
        
        var requestData: [ResultSchdule] = []
        requestObserverableData
            .subscribe(onNext: {
                requestData = $0
                testException.fulfill()
            })
            .disposed(by: bag)
        
        wait(for: [testException], timeout: 3)
        
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
        let requestObserverableData = self.seoulScheduleLoadModel.shinbundangScheduleLoad(scheduleSearch: scheduleSinsaShinbundagLine, isFirst: true, isNow: true, isWidget: false, requestDate: .now)
        let bag = DisposeBag()
        let testException = XCTestExpectation(description: "옵저버블 대기")
        
        var requestData: [ResultSchdule] = []
        requestObserverableData
            .subscribe(onNext: {
                requestData = $0
                testException.fulfill()
            })
            .disposed(by: bag)
        
        wait(for: [testException], timeout: 3)
        
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
        let requestObserverableData = self.seoulScheduleLoadModel.shinbundangScheduleLoad(scheduleSearch: scheduleSinsaShinbundagLine, isFirst: true, isNow: false, isWidget: false, requestDate: .now)
        let bag = DisposeBag()
        let testException = XCTestExpectation(description: "옵저버블 대기")
        
        var requestData: [ResultSchdule] = []
        requestObserverableData
            .subscribe(onNext: {
                requestData = $0
                testException.fulfill()
            })
            .disposed(by: bag)
        
        wait(for: [testException], timeout: 3)
        
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
        let requestObserverableData = self.seoulScheduleLoadModel.shinbundangScheduleLoad(scheduleSearch: scheduleSinsaShinbundagLine, isFirst: false, isNow: true, isWidget: false, requestDate: .now)
        let bag = DisposeBag()
        let testException = XCTestExpectation(description: "옵저버블 대기")
        
        var requestData: [ResultSchdule] = []
        requestObserverableData
            .subscribe(onNext: {
                requestData = $0
                testException.fulfill()
            })
            .disposed(by: bag)
        
        wait(for: [testException], timeout: 3)
        
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
    
    func testShinbundangScheduleLoad_CoreData() { // 브레이크 포인트 추가 이용 테스트
        // GIVEN
        // 첫 요청이기 때문에 파이어베이스 데이터를 사용하는 데이터
        let requestObserverableDataOne = self.seoulScheduleLoadModel.shinbundangScheduleLoad(scheduleSearch: scheduleSinsaShinbundagLine, isFirst: false, isNow: false, isWidget: false, requestDate: .now)
        // 두 번째 요청이기 때문에 저장된 코어데이터를 사용하는 데이터
        let requestObserverableDataTwo = self.seoulScheduleLoadModel.shinbundangScheduleLoad(scheduleSearch: scheduleSinsaShinbundagLine, isFirst: false, isNow: false, isWidget: false, requestDate: .now)
        let bag = DisposeBag()
        let testException = XCTestExpectation(description: "옵저버블 대기")
        
        var requestDataOne: [ResultSchdule] = []
        requestObserverableDataOne
            .subscribe(onNext: {
                requestDataOne = $0
            })
            .disposed(by: bag)
        
        var requestDataTwo: [ResultSchdule] = []
        requestObserverableDataTwo
            .subscribe(onNext: {
                requestDataTwo = $0
                testException.fulfill()
            })
            .disposed(by: bag)
        
        wait(for: [testException], timeout: 3)
        
        // WHEN
        let requestOneCount = requestDataOne.count
        let requestTwoCount = requestDataTwo.count
        
        let requestOneFirstData = requestDataOne.first
        let requestTwoFirstData = requestDataTwo.first
        
        let requestOneTypeCount = requestDataOne.filter {$0.type == .Shinbundang}.count
        let requestTwoTypeCount = requestDataTwo.filter {$0.type == .Shinbundang}.count
        
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
    }
    
    func testShinbundangScheduleLoad_Disposable() { // 브레이크 포인트 추가 이용 테스트
        // GIVEN
        // 첫 요청이기 때문에 파이어베이스 데이터를 사용하는 데이터
        let requestObserverableDataOne = self.seoulScheduleLoadModel.shinbundangScheduleLoad(scheduleSearch: scheduleSinsaShinbundagLine, isFirst: false, isNow: false, isWidget: false, isDisposable: true)
        // 두 번째 요청이여도 isDisposable 상태가 true이기때문에 파어어베이스 데이터를 사용해야함
        let requestObserverableDataTwo = self.seoulScheduleLoadModel.shinbundangScheduleLoad(scheduleSearch: scheduleSinsaShinbundagLine, isFirst: false, isNow: false, isWidget: false, isDisposable: true)
        let bag = DisposeBag()
        let testException = XCTestExpectation(description: "옵저버블 대기")
        
        var requestDataOne: [ResultSchdule] = []
        requestObserverableDataOne
            .subscribe(onNext: {
                requestDataOne = $0
            })
            .disposed(by: bag)
        
        var requestDataTwo: [ResultSchdule] = []
        requestObserverableDataTwo
            .subscribe(onNext: {
                requestDataTwo = $0
                testException.fulfill()
            })
            .disposed(by: bag)
        
        wait(for: [testException], timeout: 3)
        
        // WHEN
        let requestOneCount = requestDataOne.count
        let requestTwoCount = requestDataTwo.count
        
        let requestOneFirstData = requestDataOne.first
        let requestTwoFirstData = requestDataTwo.first
        
        let requestOneTypeCount = requestDataOne.filter {$0.type == .Shinbundang}.count
        let requestTwoTypeCount = requestDataTwo.filter {$0.type == .Shinbundang}.count
        
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
    }
}
