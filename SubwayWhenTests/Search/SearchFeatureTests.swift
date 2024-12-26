//
//  SearchViewModalTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/28.
//

import XCTest

import ComposableArchitecture

@testable import SubwayWhen

class SearchFeatureTests : XCTestCase {
    var testTotalDependency = TestTotalLoadTCADependency()
    var testLocationDependency = TestLocationManager()
    
    override func setUp() {
        self.testTotalDependency.defaultViewListdata = searchDeafultList
        self.testTotalDependency.vicinityStationsData = vicinityTransformData
        self.testTotalDependency.realtimeStationArrival = totalArrivalDummyData
        self.testTotalDependency.searchStationName = stationNameSearcDummyhData.SearchInfoBySubwayNameService.row
        
        self.testLocationDependency.locationData = locationData
        self.testLocationDependency.authRequest = true
        self.testLocationDependency.authCheck = true
    }
    
    func testSearchViewInit() async throws  {
        // GIVEN
        let testStore = await self.createStore()
        
        // WHEN -> View가 처음 로딩 되었을 때
        await testStore.send(.onAppear) {
            // THEN
            $0.isFirst = false
            $0.locationAuth = false // 권한을 아직 가져오지 못한 상태
            $0.nowRecommendStationList =  [
                // 추천 역 통신 전 임시 값
                "강남", "교대", "선릉", "삼성", "을지로3가", "종각", "홍대입구", "잠실", "명동", "여의도", "가산디지털단지", "판교"
            ]
        }
        
        // THEN
        await testStore.receive(.locationAuthResult([true, true])) // [자동 권한 확인 true, 권한 승인 true]
        await testStore.receive(.locationDataRequest) { // 권한 획득 후 Location 데이터 요청
            $0.nowVicintyStationLoading = true
            $0.lastVicintySearchTime = nil
        }
        await testStore.receive(.recommendStationResult(searchDeafultList)) // 추천 역 통신 후 값
        await testStore.receive(.locationDataResult(locationData)) // Location 값 획득
        await testStore.receive(.locationToVicinityStationRequest(locationData)) // Location 값을 기반으로 가까운 지하철역 요청
        await testStore.receive(.locationToVicinityStationResult(vicinityTransformData)) { // 가까운 지하철역 정보 획득
            $0.nowVicintyStationLoading = false
            XCTAssertNotNil($0.lastVicintySearchTime)
        }
    }
    
    func testNoLocationAuthSearchViewInit() async {
        // GIVEN
        let testStore = await self.createStore()
        self.testLocationDependency.authCheck = false
        
        // WHEN
        await testStore.send(.onAppear) {
            // THEN
            $0.isFirst = false
            $0.locationAuth = false // 권한을 아직 가져오지 못한 상태
            $0.nowRecommendStationList =  [
                // 추천 역 통신 전 임시 값
                "강남", "교대", "선릉", "삼성", "을지로3가", "종각", "홍대입구", "잠실", "명동", "여의도", "가산디지털단지", "판교"
            ]
        }
        
        // THEN
        await testStore.receive(.locationAuthResult([true, false])){  // [자동 권한 확인 true, 권한 승인 false]
            $0.locationAuth = false
        }
        await testStore.receive(.recommendStationResult(searchDeafultList)) // 추천 역 통신 후 값
    }
    
    func testLocationAuthRequest() async {
        // GIVEN
        let testStore = await self.createStore()
        self.testLocationDependency.authCheck = false
        
        // WHEN
        await testStore.send(.onAppear) {
            // THEN
            $0.locationAuth = false // 권한을 아직 가져오지 못한 상태
        }
        
        // THEN
        await testStore.receive(.locationAuthResult([true, false])) // [자동 권한 확인 true, 권한 승인 false]
        await testStore.send(.locationAuthRequest) // 사용자가 직접 권한을 요청해서 받아올 때
        await testStore.receive(.locationAuthResult([false, true])) // [자동 권한 확인 false, 권한 승인 true]
        await testStore.receive(.locationDataRequest) // 권한 획득 후 Location 데이터 요청
    }
    
    
    func testLocationRefreshBtnTapped() async {
        // GIVEN
        let testStore = await self.createStore()
        
        // WHEN
        await testStore.send(.locationAuthResult([true, true])) // [자동 권한 확인 true, 권한 승인 true]
        await testStore.receive(.locationToVicinityStationResult(vicinityTransformData)) { // 가까운 지하철역 정보 획득
            // THEN
            XCTAssertNotNil($0.lastVicintySearchTime) // 마지막 시간 기록
        }
        
        // WHEN
        await testStore.send(.locationToVicinityRefreshBtnTapped) {  // 300초가 지나지 않은 경우 팝업 표출
            // THEN
            XCTAssertNotNil($0.dialogState) // 팝업 표출
        }
    }
    
    func testLocationDataTapped() async {
        // GIVEN
        self.testTotalDependency.realtimeStationArrival = totalArrivalDummyData.filter {$0.subWayId == "1003"}
        let testStore = await self.createStore()
        
        // WHEN
        await testStore.send(.locationToVicinityStationResult(vicinityTransformData)) // 가장 가까운 지하철 정보 주입
        await testStore.send(.locationStationTapped(0)){ // 0번째 (교대) 선택
            // THEN
            $0.nowTappedStationIndex = 0
        }
        
        // THEN
        await testStore.receive(.liveDataRequest) { // 실시간 데이터 요청
            $0.nowLiveDataLoading = [true, true] // 상하행 로드 중
        }
        await testStore.receive(.liveDataResult(totalArrivalDummyData.filter{$0.upDown == "상행" && $0.subWayId == "1003"} )) {
            $0.nowLiveDataLoading = [false, true] // 상행 로드 완료, 하행 로드 중
        }
        await testStore.receive(.liveDataResult(totalArrivalDummyData.filter{$0.upDown == "하행" && $0.subWayId == "1003"} )) {
            $0.nowLiveDataLoading = [false, false] // 상행 로드 완료, 하행 로드 완료
        }
    }
    
    func testNoServiceLocationDataTapped() async {
        // GIVEN
        let testStore = await self.createStore()
        
        // WHEN
        await testStore.send(.locationToVicinityStationResult([.init(id: "테스트", name: "테스트", line: "에버라인", distance: "테스트")])) // 임시 데이터 주입
        await testStore.send(.locationStationTapped(0)){ // 0번째 선택
            // THEN
            $0.nowTappedStationIndex = nil // 지원되지 않는 노선은 저장하지 않음
            XCTAssertNotNil($0.dialogState) // 팝업 표출
        }
    }
    
    func testSearchQuery() async {
        // GIVEN
        let testStore = await self.createStore()
        
        // WHEN
        await testStore.send(.isSearchMode(true)) { // 검색 모드 시작
            // THEN
            $0.isSearchMode = true
            $0.searchQuery = "" // mode 시작 시 query 값은 없어야함 (mode 종료 시 query 구문 제거로 인해)
        }
    
        // WHEN
        await testStore.send(.binding(.set(\.searchQuery, "교대"))) {
            // THEN
            $0.nowSearchLoading = true // 검색이 시작될 때는 true
        }
        await testStore.send(.binding(.set(\.searchQuery, "교")))
        
        // THEN
        await testStore.receive(.stationSearchRequest) {
            $0.nowStationSearchList = [] // stationSearchRequest Action이 호출되면, SearchList는 빈 배열이여야 함
        }
        
        // WHEN
        await testStore.receive(.stationSearchResult(stationNameSearcDummyhData.SearchInfoBySubwayNameService.row.filter {$0.stationName == "교"})){  // searchQuery인 "교" 값만 필터링
            // THEN
            $0.searchQuery = "교"
            $0.nowStationSearchList = [] // binding이 "교대", "교"로 2번 호출되더라도 마지막 값만 request 하여 빈 값 주입
            $0.nowSearchLoading = false // 검색이 끝났을 때는 false
        }
        
        // WHEN
        await testStore.send(.binding(.set(\.searchQuery, "교대"))) {
            // THEN
            $0.nowSearchLoading = true
        }
        
        // THEN
        await testStore.receive(.stationSearchResult(stationNameSearcDummyhData.SearchInfoBySubwayNameService.row)) {
            $0.searchQuery = "교대"
            $0.nowStationSearchList = stationNameSearcDummyhData.SearchInfoBySubwayNameService.row // 검색결과 대입
            $0.nowSearchLoading = false // 검색이 끝났을 때는 false
        }
    }
    
    func testRecommendStationTapped() async {
        // GIVEN
        let testStore = await self.createStore()
        
        // WHEN
        await testStore.send(.recommendStationResult(searchDeafultList)) // 추천 지하철역 정보 주입 (교대, 강남, 서초)
        await testStore.send(.stationTapped(.init(index: 0, type: .recommend))) { // 추천 지하철역 선택
            // THEN
            $0.nowSearchLoading = true // 검색을 위해 nowSearch, Mode 변경
            $0.isSearchMode = true
            $0.searchQuery = $0.nowRecommendStationList[0] // query를 선택한 추천 지하철역으로 변경
        }
        
        // THEN
        await testStore.receive(.stationSearchRequest) // 검색 요청
        await testStore.receive(.stationSearchResult(stationNameSearcDummyhData.SearchInfoBySubwayNameService.row)) // 검색 결과
    }
    
    func testDisposableDetailBtnTapped() async {
        // GIVEN
        let testStore = await self.createStore()
        
        // WHEN
        await testStore.send(.locationToVicinityStationResult(vicinityTransformData)) // 가장 가까운 지하철 정보 주입
        await testStore.send(.locationStationTapped(0))// 0번째 (교대) 선택
        await testStore.send(.liveDataResult(totalArrivalDummyData.filter{$0.upDown == "상행" && $0.subWayId == "1003"} )) // 실시간 정보 주입
        await testStore.send(.disposableDetailBtnTapped) { // 일회성 보기 클릭
            // THEN
            XCTAssertNotNil($0.dialogState) // 팝업 표출 (상행/하행)
        }
        
        await testStore.send(.dialogAction(.presented(.upDownBtnTapped(true)))) {
            // THEN
            $0.isAutoDelegateAction = .disposableDetail(true) // disposableDetail 타입에 상행은 true
            $0.isSearchMode = true // 검색을 요청하기 때문에 mode, loading도 true
            $0.nowSearchLoading = true
            $0.searchQuery = $0.nowVicinityStationList[$0.nowTappedStationIndex!].name // 선택된 지하철역 이름 (0번 교대)
        }
        
        // THEN
        await testStore.receive(.stationSearchRequest) // 지하철역 통신 요청
        await testStore.receive(.stationSearchResult(stationNameSearcDummyhData.SearchInfoBySubwayNameService.row)) // 지하철역 검색 결과
        await testStore.receive(.disposableDetailPushRequest) { // 일회성 보기 요청
            $0.isAutoDelegateAction = nil // 일회성 보기 present 후 action 값을 nil로 변경
        }
    }
    
    func testPlusModalBtnTapped() async {
        // GIVEN
        let testStore = await self.createStore()
        
        // WHEN
        await testStore.send(.locationToVicinityStationResult(vicinityTransformData)) // 가장 가까운 지하철 정보 주입
        await testStore.send(.locationStationTapped(0))// 0번째 (교대) 선택
        await testStore.send(.liveDataResult(totalArrivalDummyData.filter{$0.upDown == "상행" && $0.subWayId == "1003"} )) // 실시간 정보 주입
        await testStore.send(.stationAddBtnTapped) { // 지하철역 추가 모달 버튼 클릭
            // THEN
            $0.isAutoDelegateAction = .plusModal // 검색을 요청하기 때문에 mode, loading도 true
            $0.isSearchMode = true
            $0.nowSearchLoading = true
            $0.searchQuery = $0.nowVicinityStationList[$0.nowTappedStationIndex!].name // 선택된 지하철역 이름 (0번 교대)
        }
        
        // THEN
        await testStore.receive(.stationSearchRequest) // 지하철역 통신 요청
        await testStore.receive(.stationSearchResult(stationNameSearcDummyhData.SearchInfoBySubwayNameService.row)) // 지하철역 검색 결과
        await testStore.receive(.searchResultTapped(0)) { // 선택된 지하철역 index 전달 (0)
            $0.isAutoDelegateAction = nil // modal present 후 action 값을 nil로 변경
        }
    }
    
    func testPlusModalBtnTappedWithError() async {
        // GIVEN
        self.testTotalDependency.searchStationName = []
        let testStore = await self.createStore()
        
        // WHEN
        await testStore.send(.locationToVicinityStationResult(vicinityTransformData)) // 가장 가까운 지하철 정보 주입
        await testStore.send(.locationStationTapped(0))// 0번째 (교대) 선택
        await testStore.send(.liveDataResult(totalArrivalDummyData.filter{$0.upDown == "상행" && $0.subWayId == "1003"} )) // 실시간 정보 주입
        await testStore.send(.stationAddBtnTapped) { // 지하철역 추가 모달 버튼 클릭
            // THEN
            $0.isAutoDelegateAction = .plusModal // 검색을 요청하기 때문에 mode, loading도 true
            $0.isSearchMode = true
            $0.nowSearchLoading = true
            $0.searchQuery = $0.nowVicinityStationList[$0.nowTappedStationIndex!].name // 선택된 지하철역 이름 (0번 교대)
        }
        
        // THEN
        await testStore.receive(.stationSearchRequest) // 지하철역 통신 요청
        await testStore.receive(.stationSearchResult([])) { // 지하철역 검색 결과 (빈 배열)
            $0.isAutoDelegateAction = nil // 검색결과에 따라 modal을 열 수 없을 때는 nil
            XCTAssertNotNil($0.dialogState) // 오류 안내 팝업 표출
        }
    }
}

private extension SearchFeatureTests {
    func createStore() async -> TestStore<SearchFeature.State,  SearchFeature.Action> {
        let store = await TestStore(initialState: SearchFeature.State()) {
            SearchFeature()
        } withDependencies: { dependency in
            dependency.totalLoad = self.testTotalDependency
            dependency.locationManager = self.testLocationDependency
        }
        store.exhaustivity = .off(showSkippedAssertions: false)
        return store
    }
}
