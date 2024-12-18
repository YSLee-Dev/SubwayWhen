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
        }
        await testStore.receive(.recommendStationResult(searchDeafultList)) // 추천 역 통신 후 값
        await testStore.receive(.locationDataResult(locationData)) // Location 값 획득
        await testStore.receive(.locationToVicinityStationRequest(locationData)) // Location 값을 기반으로 가까운 지하철역 요청
        await testStore.receive(.locationToVicinityStationResult(vicinityTransformData)) { // 가까운 지하철역 정보 획득
            $0.nowVicintyStationLoading = false
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
