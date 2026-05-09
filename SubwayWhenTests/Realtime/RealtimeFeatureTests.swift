//
//  RealtimeFeatureTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 4/20/26.
//

import XCTest

import ComposableArchitecture
import Nimble

@testable import SubwayWhen

final class RealtimeFeatureTests: XCTestCase {

    // MARK: - Properties

    var mockTotalLoad: TestTotalLoadTCADependency!
    var mockDelegate: MockRealtimeVCDelegate!

    // MARK: - LifeCycle

    override func setUp() {
        self.mockTotalLoad = TestTotalLoadTCADependency()
        self.mockTotalLoad.stationIdListData = [stationSessionDummy]
        self.mockTotalLoad.realtimePositionList = [realtimeTrainPositionUpDummy, realtimeTrainPositionDownDummy]
        self.mockDelegate = MockRealtimeVCDelegate()
    }

    // MARK: - Tests

    func testOnAppear() async throws {
        // GIVEN
        let testStore = await self.createStore()

        // WHEN
        await testStore.send(.onAppear) {
            // THEN
            $0.isLoading = true
        }

        await testStore.receive(.stationListLoaded([stationSessionDummy])) {
            $0.stationSessions = [stationSessionDummy]
        }

        await testStore.receive(.trainPositionLoaded([realtimeTrainPositionUpDummy, realtimeTrainPositionDownDummy])) {
            $0.trainPositions = [realtimeTrainPositionUpDummy, realtimeTrainPositionDownDummy]
            $0.isLoading = false
        }
    }

    func testStationListLoaded() async throws {
        // GIVEN
        let testStore = await self.createStore()

        // WHEN
        await testStore.send(.stationListLoaded([stationSessionDummy])) {
            // THEN
            $0.stationSessions = [stationSessionDummy]
        }

        // THEN (400ms 후 스크롤 요청)
        await testStore.receive(.scrollToStationRequest) {
            $0.shouldScrollToStation = true
        }
    }

    func testStationListLoadedEmpty() async throws {
        // GIVEN
        let emptySession = StationSession(name: nil, stations: [])
        let testStore = await self.createStore()

        // WHEN
        await testStore.send(.stationListLoaded([emptySession]))

        // THEN
        await testStore.receive(.bundleLoadFailed)

        expect(self.mockDelegate.calledShowBundleError).to(
            beTrue(),
            description: "빈 데이터 시 showBundleErrorPopupAndDismiss 호출되어야 함"
        )
    }

    func testRefreshBtnTappedWithinCooltime() async throws {
        // GIVEN
        let testStore = await self.createStore()
        await testStore.send(.refreshBtnTapped) {
            $0.isLoading = true
            $0.lastRefreshedDate = $0.lastRefreshedDate
        }
        await testStore.receive(.trainPositionLoaded([realtimeTrainPositionUpDummy, realtimeTrainPositionDownDummy])) {
            $0.trainPositions = [realtimeTrainPositionUpDummy, realtimeTrainPositionDownDummy]
            $0.isLoading = false
        }

        // WHEN (15초 이내 재요청)
        await testStore.send(.refreshBtnTapped) {
            // THEN: trainPositionLoaded 재요청 없음
            $0.isLoading = false
        }
    }

    func testRefreshBtnTappedAfterCooltime() async throws {
        // GIVEN: lastRefreshedDate = nil (최초 상태)
        let testStore = await self.createStore()

        // WHEN
        await testStore.send(.refreshBtnTapped) {
            // THEN
            $0.isLoading = true
        }

        await testStore.receive(.trainPositionLoaded([realtimeTrainPositionUpDummy, realtimeTrainPositionDownDummy])) {
            $0.trainPositions = [realtimeTrainPositionUpDummy, realtimeTrainPositionDownDummy]
            $0.isLoading = false
        }
    }

    func testExceptionBtnTapped() async throws {
        // GIVEN
        let testStore = await self.createStore(exceptionLastStation: "오금")

        // WHEN
        await testStore.send(.exceptionBtnTapped) {
            // THEN
            $0.dialogState = .init(title: { TextState("") }, actions: {
                ButtonState(action: .okBtnTapped) { TextState(Strings.Realtime.exceptionDialogOk) }
                ButtonState(role: .cancel, action: .cancelBtnTapped) { TextState(Strings.Common.cancel) }
            }, message: { TextState("오금\(Strings.Realtime.exceptionDialogMessageSuffix)") })
        }
    }

    func testDialogOkBtnTapped() async throws {
        // GIVEN
        let testStore = await self.createStore(exceptionLastStation: "오금")
        await testStore.send(.exceptionBtnTapped)

        // WHEN
        await testStore.send(.dialogAction(.presented(.okBtnTapped))) {
            // THEN
            $0.dialogState = nil
            $0.exceptionLastStation = ""
            $0.isLoading = true
        }

        await testStore.receive(.trainPositionLoaded([realtimeTrainPositionUpDummy, realtimeTrainPositionDownDummy])) {
            $0.trainPositions = [realtimeTrainPositionUpDummy, realtimeTrainPositionDownDummy]
            $0.isLoading = false
        }

        expect(self.mockDelegate.calledExceptionRemove).to(
            beTrue(),
            description: "다이얼로그 확인 시 exceptionRemove 호출되어야 함"
        )
    }

    func testScrollToStationCompleted() async throws {
        // GIVEN
        let testStore = await self.createStore()
        await testStore.send(.scrollToStationRequest) {
            $0.shouldScrollToStation = true
        }

        // WHEN
        await testStore.send(.scrollToStationCompleted) {
            // THEN
            $0.shouldScrollToStation = false
        }
    }

    func testBackBtnTapped() async throws {
        // GIVEN
        let testStore = await self.createStore()

        // WHEN
        await testStore.send(.backBtnTapped)

        // THEN
        expect(self.mockDelegate.calledPop).to(
            beTrue(),
            description: "뒤로가기 버튼 탭 시 pop() 호출되어야 함"
        )
    }

    func testOnDisappear() async throws {
        // GIVEN
        let testStore = await self.createStore()

        // WHEN
        await testStore.send(.onDisappear)

        // THEN
        expect(self.mockDelegate.calledDisappear).to(
            beTrue(),
            description: "화면 퇴출 시 disappear() 호출되어야 함"
        )
    }

    func testBundleLoadFailed() async throws {
        // GIVEN
        let testStore = await self.createStore()

        // WHEN
        await testStore.send(.bundleLoadFailed)

        // THEN
        expect(self.mockDelegate.calledShowBundleError).to(
            beTrue(),
            description: "번들 로드 실패 시 showBundleErrorPopupAndDismiss() 호출되어야 함"
        )
    }
}

// MARK: - Methods

private extension RealtimeFeatureTests {
    func createStore(exceptionLastStation: String = "") async -> TestStore<RealtimeFeature.State, RealtimeFeature.Action> {
        let delegate = self.mockDelegate!
        let store = await TestStore(
            initialState: RealtimeFeature.State(
                subwayLine: .three,
                stationName: "교대",
                upDown: "상행",
                exceptionLastStation: exceptionLastStation
            ),
            reducer: {
                var feature = RealtimeFeature()
                feature.coordinatorDelegate = delegate
                return feature
            },
            withDependencies: { dependency in
                dependency.totalLoad = self.mockTotalLoad
            }
        )
        store.exhaustivity = .off(showSkippedAssertions: false)
        return store
    }
}
