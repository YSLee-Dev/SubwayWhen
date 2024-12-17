//
//  DetailFeatureTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/23.
//

import XCTest

import ComposableArchitecture

@testable import SubwayWhen

final class DetailFeatureTests: XCTestCase {
    let testDependency = TestTotalLoadTCADependency()

    override func setUp()  {
        self.testDependency.resultSchdule = seoulScheduleToResultScheduleTransformDummyData
        self.testDependency.realtimeStationArrival = totalArrivalDummyData
        
        FixInfo.saveSetting.detailAutoReload = true
        FixInfo.saveSetting.detailScheduleAutoTime = false
        FixInfo.saveSetting.liveActivity = false
    }
    
    func testDetailViewInit() async throws {
        // GIVEN
        let testStore = await self.createStore()
        
        // WHEN -> View가 처음 로딩 되었을 때 상태
        await testStore.send(.viewInitialized) // arrival, schedule 데이터 요청
        
        await testStore.receive(.arrivalDataRequest) {
            // THEN
            $0.nowArrivalLoading = true
        }
     
        await testStore.receive(.scheduleDataRequest) {
            // THEN
            $0.nowScheduleLoading = true
        }
        
        await testStore.receive(.arrivalDataRequestSuccess(self.testDependency.realtimeStationArrival)) {
            // THEN
            $0.nowArrivalLoading = false
            $0.nowArrivalData = self.testDependency.realtimeStationArrival
        }
        
        await testStore.receive(.timerSettingRequest) {
            // THEN
            $0.nowTimer = 15
        }
        
        await testStore.receive(.scheduleDataRequestSuccess(self.testDependency.resultSchdule)) {
            // THEN
            $0.nowScheduleLoading = false
            $0.nowScheduleData = self.testDependency.resultSchdule
        }
        
        await testStore.receive(.scheduleDataSort) {
            // THEN
            $0.nowSculeduleSortedData = self.testDependency.resultSchdule // 시간표 sort 기능이 꺼진 상태
        }
    }
    
    func testExceptionLastStationBtnTapped() async throws {
        // GIVEN
        var model = detailSendModelDummyData
        model.exceptionLastStation = "구파발"
        let testStore = await self.createStore(sendedLoadModel: model)
        
        // WHEN
        await testStore.send(.viewInitialized)
        try await Task.sleep(for: .milliseconds(350)) // 값 세팅 대기
        
        await testStore.send(.exceptionLastStationBtnTapped) {
            // THEN
            XCTAssertNotNil($0.dialogState)
        }
        
        // WHEN -> OK 버튼 클릭
        await testStore.send(.dialogAction(.presented(.okBtnTapped))) {
            // THEN
            $0.dialogState = nil
            $0.sendedLoadModel.exceptionLastStation = ""
        }
        
        // THEN -> Arrival, schedule 순서
        await testStore.receive(.arrivalDataRequest)
        await testStore.receive(.scheduleDataRequest)
    }
    
    func testRefreshBtnTapped() async throws {
        // GIVEN
        let testStore = await self.createStore()
        
        // WHEN
        await testStore.send(.viewInitialized)
        try await Task.sleep(for: .milliseconds(350)) // 값 세팅 대기
        
        await testStore.send(.refreshBtnTapped) {
            // THEN
            $0.nowTimer = nil
        }
        
        // THEN -> Arrival, schedule 순서
        await testStore.receive(.arrivalDataRequest)
        await testStore.receive(.scheduleDataSort)
    }
}

private extension DetailFeatureTests {
    func createStore(isDisposable: Bool = false, sendedLoadModel: DetailSendModel = detailSendModelDummyData, exhaustivity: Bool = false) async -> TestStore<DetailFeature.State,  DetailFeature.Action> {
        let store = await TestStore(initialState: DetailFeature.State(isDisposable: isDisposable, sendedLoadModel: sendedLoadModel)) {
            DetailFeature()
        } withDependencies: { dependency in
            dependency.totalLoad = self.testDependency
        }
        store.exhaustivity = exhaustivity ? .on : .off(showSkippedAssertions: false)
        return store
    }
}
