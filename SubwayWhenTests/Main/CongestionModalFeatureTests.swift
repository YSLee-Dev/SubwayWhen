//
//  CongestionModalFeatureTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 1/15/26.
//

import Foundation
import XCTest
import ComposableArchitecture

@testable import SubwayWhen

class CongestionModalFeatureTests: XCTestCase {
    
    // MARK: - Properties
    
    var congestionManager: TestCongestionManager!
    
    // MARK: - LifeCycle
    
    override func setUp()  {
        self.congestionManager = TestCongestionManager()
        self.congestionManager.congestionDataSet = congestionData
        FixInfo.saveSetting.mainCongestionBaseStaton = congestionStations.first!
    }
    
    // MARK: - Tests
    
    func testModalInit() async throws  {
        // GIVEN
        let testStore = await self.createStore()
        
        // WHEN
        await testStore.send(.onAppear) { state in
            // THEN (View가 처음 로딩되었을 때)
            state.availableStationList = congestionStations
            state.selectedStation = congestionStations.first!
        }
        
        // THEN (혼잡도 요청)
        await testStore.receive(.congestionDataReuqest) { state in
            state.nowHour = Calendar.current.component(.hour, from: .now)
            state.congestionData = congestionData.stations[congestionStations.first!]!.hourlyCongestion.weekday.map {
                HourlyCongestionData(hour: Int($0.key) ?? 0, congestion: $0.value)}.sorted {$0.hour < $1.hour}
        }
    }
    
    func testStationBtnTapped() async throws {
        // GIVEN
        let testStore = await self.createStore()
        await testStore.send(.onAppear)
        
        // WHEN
        await testStore.send(.stationBtnTapped(station: congestionStations.last!)) { state in
            // THEN (다른 지하철역을 눌렀을 때)
            FixInfo.saveSetting.mainCongestionBaseStaton = congestionStations.last!
            state.selectedStation = congestionStations.last!
        }
        
        // THEN (다른 지하철역 혼잡도 요청)
        await testStore.receive(.congestionDataReuqest) { state in
            state.nowHour = Calendar.current.component(.hour, from: .now)
            state.congestionData = [] // 더미 데이터가 비어있음
        }
    }
}

// MARK: - Methods

private extension CongestionModalFeatureTests {
    func createStore() async -> TestStoreOf<CongestionModalFeature> {
        let store = await TestStore(initialState: CongestionModalFeature.State(), reducer: {
            CongestionModalFeature()
        }, withDependencies: { dependency in
            dependency.congestionManager = self.congestionManager
        })
        store.exhaustivity = .off(showSkippedAssertions: false)
        return store
    }
}
