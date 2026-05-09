# Plan: Realtime_Test

## 참조 Spec
- @specs/features/Realtime_Test/spec.md

## 현재 상태 파악

- 신규:
  - `SubwayWhenTests/Realtime/RealtimeFeatureTests.swift` — RealtimeFeature TCA 테스트
  - `SubwayWhenTests/Mock/Manager/MockRealtimeVCDelegate.swift` — RealtimeVCDelegate Mock (delegate 호출 검증용)
- 재사용:
  - `SubwayWhenNetworking/DataLoad/TCADependecy/TestTotalLoadTCADepdency.swift` — 이미 존재하는 TCA 의존성 테스트 더블 (재사용)
  - `SubwayWhenTests/Dummy/DummyData.swift`, `DummyLoad.swift` — 기존 더미 데이터 (재사용 및 확장)
  - `SubwayWhenTests/DataLoad/TotalLoadModelTests.swift` — 기존 테스트 (realtimePositionLoad, stationIdList 케이스 추가)
  - `SubwayWhenTests/DataLoad/LoadModelTests.swift` — 기존 테스트 (realtimePositionRequest 케이스 추가)
- 수정:
  - `SubwayWhenTests/Dummy/DummyData.swift` — RealtimeTrainPosition, StationSession 더미 데이터 추가
  - `SubwayWhenTests/DataLoad/TotalLoadModelTests.swift` — realtimePositionLoad, stationIdList 테스트 케이스 추가
  - `SubwayWhenTests/DataLoad/LoadModelTests.swift` — realtimePositionRequest 테스트 케이스 추가

## 기술적 결정사항

- **RealtimeFeatureTests는 신규 파일 생성**: 기존 패턴(`DetailFeatureTests`, `SearchFeatureTests`)과 동일하게 `SubwayWhenTests/Realtime/` 폴더에 신규 생성
- **TestTotalLoadTCADependency 재사용**: `realtimePositionList`, `stationIdListData` 프로퍼티가 이미 존재하므로 별도 Mock 생성 없이 재사용
- **CoordinatorDelegate Mock 생성**: `RealtimeCoordinator`가 `RealtimeVCDelegate`를 준수하므로, `MockRealtimeVCDelegate`를 만들어 `RealtimeFeature.coordinatorDelegate`에 주입 — 각 액션에서 올바른 delegate 메서드가 호출되는지 검증. Mock은 `calledPop`, `calledDisappear`, `calledShowBundleError`, `calledExceptionRemove` Bool 플래그로 호출 여부를 추적
- **쿨타임 테스트**: `lastRefreshedDate`를 State에서 직접 설정하여 15초 이내/이후 시나리오 구분
- **TotalLoadModel 테스트 추가**: `realtimePositionLoad`와 `stationIdList`는 기존 `TotalLoadModelTests`에 케이스 추가 (새 파일 불필요)
- **LoadModel 테스트 추가**: `realtimePositionRequest`를 기존 `LoadModelTests`에 케이스 추가

## 구현 순서

### Phase 1. 더미 데이터 추가

- `DummyData.swift`에 `RealtimeTrainPosition` 더미 인스턴스 추가
- `DummyData.swift`에 `StationSession` 더미 인스턴스 추가
- `DummyLoad.swift`에 실시간 열차 위치 API 응답용 JSON 픽스처 추가 (필요 시)

### Phase 2. TotalLoadModel 테스트 케이스 추가

- `TotalLoadModelTests.swift`에 아래 케이스 추가:
  - `testRealtimePositionLoad` — 정상 응답, 상하행 필터, 제외 역 필터
  - `testRealtimePositionLoadError` — 빈 배열 반환
  - `testStationIdList` — 호선별 구간 분류 검증 (1호선 경인/경부, 2호선 성수/신정, 5호선 마천)

### Phase 3. LoadModel 테스트 케이스 추가

- `LoadModelTests.swift`에 아래 케이스 추가:
  - `testRealtimePositionRequest` — 정상 응답 파싱
  - `testRealtimePositionRequestError` — 에러 시 nil 반환

### Phase 4. MockRealtimeVCDelegate 생성

- `SubwayWhenTests/Mock/Manager/MockRealtimeVCDelegate.swift` 신규 생성
- `RealtimeVCDelegate` 프로토콜 채택
- 호출 여부 추적 플래그:
  - `var calledPop: Bool`
  - `var calledDisappear: Bool`
  - `var calledShowBundleError: Bool`
  - `var calledExceptionRemove: Bool`

### Phase 5. RealtimeFeature 테스트 파일 생성

- `SubwayWhenTests/Realtime/RealtimeFeatureTests.swift` 신규 생성
- `createStore()`에서 `feature.coordinatorDelegate = self.mockDelegate` 주입
- 아래 테스트 케이스 작성:

| 메서드명 | 검증 내용 |
|---------|---------|
| `testOnAppear` | isLoading=true로 전환, stationListLoaded + trainPositionLoaded 수신 |
| `testStationListLoaded` | stationSessions 저장, scrollToStationRequest 수신 |
| `testStationListLoadedEmpty` | 빈 배열 → bundleLoadFailed 수신 |
| `testTrainPositionLoaded` | trainPositions 저장, isLoading=false |
| `testRefreshBtnTappedWithinCooltime` | 15초 이내 → .none (재요청 없음) |
| `testRefreshBtnTappedAfterCooltime` | 15초 이후 → lastRefreshedDate 업데이트, trainPositionLoaded 수신 |
| `testExceptionBtnTapped` | dialogState 생성 |
| `testDialogOkBtnTapped` | exceptionLastStation="", trainPositionLoaded 재수신, mockDelegate.calledExceptionRemove=true |
| `testScrollToStationCompleted` | shouldScrollToStation=false |
| `testBackBtnTapped` | mockDelegate.calledPop=true |
| `testOnDisappear` | mockDelegate.calledDisappear=true |
| `testBundleLoadFailed` | mockDelegate.calledShowBundleError=true |

## 완료 조건

- [ ] `testOnAppear` 통과
- [ ] `testStationListLoaded` 통과
- [ ] `testStationListLoadedEmpty` 통과
- [ ] `testTrainPositionLoaded` 통과
- [ ] `testRefreshBtnTappedWithinCooltime` 통과
- [ ] `testRefreshBtnTappedAfterCooltime` 통과
- [ ] `testExceptionBtnTapped` 통과
- [ ] `testDialogOkBtnTapped` 통과
- [ ] `testScrollToStationCompleted` 통과
- [ ] `testBackBtnTapped` 통과 (mockDelegate.calledPop)
- [ ] `testOnDisappear` 통과 (mockDelegate.calledDisappear)
- [ ] `testBundleLoadFailed` 통과 (mockDelegate.calledShowBundleError)
- [ ] `testDialogOkBtnTapped` delegate 호출 통과 (mockDelegate.calledExceptionRemove)
- [ ] `testRealtimePositionLoad` (TotalLoadModel) 통과
- [ ] `testStationIdList` (TotalLoadModel) 통과
- [ ] `testRealtimePositionRequest` (LoadModel) 통과
- [ ] Spec Acceptance Criteria 충족
