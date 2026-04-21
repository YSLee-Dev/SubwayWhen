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
    var subwayNoticeLoadModel: LoadModelProtocol!
    
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
        
        let noticeMock = MockURLSession((response: urlResponse!, data: subwayNoticeData))
        self.subwayNoticeLoadModel = LoadModel(networkManager: NetworkManager(session: noticeMock))
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
        let data = self.seoulScheduleLoadModel.seoulStationScheduleLoad(scheduleSearch: .init(stationCode: "", upDown: "", exceptionLastStation: "", line: "", korailCode: "", stationName: ""), dayType: .weekday)
        
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
        let data = self.korailScheduleLoadModel.korailSchduleLoad(scheduleSearch: .init(stationCode: "", upDown: "", exceptionLastStation: "", line: "",  korailCode: "", stationName: ""), dayType: .weekday)
        
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
    
    // 신분당선: 테스트 객체는 외부환경에 의존하면 안되지만, FireBase에서 불러오는 데이터가 1000건이 넘으며, 시간표 데이터는 dummy 데이터와 함께 변경 예정이기 때문에 옵저버블을 대기하는 식으로 테스트 진행
    func testShinbundangScheduleLoad() {
        // GIVEN
        let requestObserverableData = self.stationNameSearchModel.shinbundangScheduleReqeust(scheduleSearch: scheduleSinsaShinbundagLine)
       
        let bag = DisposeBag()
        let testException = XCTestExpectation(description: "옵저버블 대기")
        
        var requestData : [ShinbundangScheduleModel] = []
        requestObserverableData
            .subscribe(onNext: {
                requestData = $0
                    .filter {
                        $0.week == "평일" && $0.updown == "하행" // Dummy 데이터 기준
                    }
                testException.fulfill()
            })
            .disposed(by: bag)
        
        let dummyData = shinbundagSinsaStationScheduleDummyData
        
        wait(for: [testException], timeout: 3)
        
        // WHEN
        let requestFirstData = requestData.first?.startTime
        let dummyFirstData = dummyData.first?.startTime
        
        let requestLastData = requestData.last
        let dummyLastData = dummyData.last
        
        let requestStationName = requestData.first?.stationName
        let dummyStationName = scheduleSinsaShinbundagLine.stationName
        
        // THEN
        expect(requestFirstData).to(
            equal(dummyFirstData),
            description: "모든 데이터는 동일해야함"
        )
        
        expect(requestLastData).to(
            equal(dummyLastData),
            description: "모든 데이터는 동일해야함"
        )
        
        expect(requestStationName).to(
            equal(dummyStationName),
            description: "시간표 데이터를 요청한 지하철역명은 동일해야함"
        )
    }
    
    func testSubwayNoticeLoad() {
        // GIVEN
        let data = self.subwayNoticeLoadModel.subwayNoticeRequest()
        let successData = data
            .map{ data -> SubwayNotice? in
                guard case .success(let value) = data else {return nil}
                return value.response.body.items.item.first
            }
            .asObservable()
            .filterNil()
        
        let blocking = successData.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestTitle = arrayData.first!.title
        let dummyTitle = subwayNotice.title
        
        let requestContents = arrayData.first!.content
        let dummyContents = subwayNotice.content
        
        let requestEndDate = arrayData.first!.endDate
        let dummyEndDate = subwayNotice.endDate
        
        // THEN
        expect(requestTitle).to(
            equal(dummyTitle),
            description: "타이틀은 동일해야함"
        )
        
        expect(requestContents).to(
            equal(dummyContents),
            description: "컨텐츠 내용은 동일해야함"
        )
        
        expect(requestEndDate).to(
            equal(dummyEndDate),
            description: "종료 날짜는 동일해야함"
        )
    }
    
    func testSubwayNoticeLoadFailed() {
        // GIVEN
        let data = self.arrivalLoadModel.subwayNoticeRequest() // 오류 발생을 위해 다른 model 사용
        let successData = data
            .map{ data -> SubwayNotice? in
                guard case .success(let value) = data else {return nil}
                return value.response.body.items.item.first
            }
            .asObservable()
            .filterNil()
        
        let blocking = successData.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestTitle = arrayData.first?.title
        let requestEndDate = arrayData.first?.endDate
        
        // THEN
        expect(requestTitle).to(
            beNil(),
            description: "타이틀은 nil이여야 함"
        )
        
        expect(requestEndDate).to(
            beNil(),
            description: "종료날짜는 nil이여야 함"
        )
    }

    func testRealtimePositionRequest() {
        // GIVEN
        let realtimePositionModel: LoadModelProtocol = LoadModel(
            networkManager: NetworkManager(session: MockURLSession((response: urlResponse!, data: realtimeTrainPositionData)))
        )
        let data = realtimePositionModel.realtimePositionRequest(subwayLine: .three)

        let filterData = data
            .asObservable()
            .map { data -> RealtimeTrainPositionResponse? in
                guard case .success(let value) = data else { return nil }
                return value
            }
            .filterNil()

        // WHEN
        let blocking = filterData.toBlocking()
        let arrayData = try! blocking.toArray()

        let requestCount = arrayData.first?.realtimePositionList.count
        let dummyCount = realtimeTrainPositionResponseDummy.realtimePositionList.count

        let requestFirstTrainNo = arrayData.first?.realtimePositionList.first?.trainNo
        let dummyFirstTrainNo = realtimeTrainPositionResponseDummy.realtimePositionList.first?.trainNo

        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "파싱된 열차 개수는 더미 데이터와 동일해야 함"
        )
        expect(requestFirstTrainNo).to(
            equal(dummyFirstTrainNo),
            description: "첫 번째 열차 번호는 더미 데이터와 동일해야 함"
        )
    }

    func testRealtimePositionRequestError() {
        // GIVEN: 열차 위치 키가 없는 JSON (arrivalErrorData) → 빈 배열 반환
        let errorModel: LoadModelProtocol = LoadModel(
            networkManager: NetworkManager(session: MockURLSession((response: urlResponse!, data: arrivalErrorData)))
        )
        let data = errorModel.realtimePositionRequest(subwayLine: .three)

        let filterData = data
            .asObservable()
            .map { data -> RealtimeTrainPositionResponse? in
                guard case .success(let value) = data else { return nil }
                return value
            }
            .filterNil()

        // WHEN
        let blocking = filterData.toBlocking()
        let arrayData = try! blocking.toArray()

        let requestCount = arrayData.first?.realtimePositionList.count

        // THEN
        expect(requestCount).to(
            equal(0),
            description: "열차 위치 키가 없는 응답은 빈 배열을 반환해야 함"
        )
    }
}
