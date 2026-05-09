# Tasks: Realtime_Test

## 참조
- spec: `.claude/specs/features/Realtime_Test/spec.md`
- plan: `.claude/specs/features/Realtime_Test/plan.md`

## Task 목록

### Phase 1. 더미 데이터 추가

#### [x] Task 1 — `DummyData.swift` (수정)
**파일**: `SubwayWhenTests/Dummy/DummyData.swift`
- `RealtimeTrainPosition` 더미 인스턴스 추가 (상행/하행 각 1개, 급행 1개)
- `StationSession` 더미 인스턴스 추가 (구간명 nil인 메인 구간 1개)

---

### Phase 2. MockRealtimeVCDelegate 생성

#### [x] Task 2 — `MockRealtimeVCDelegate.swift` (신규)
**파일**: `SubwayWhenTests/Mock/Manager/MockRealtimeVCDelegate.swift`
- `RealtimeVCDelegate` 프로토콜 채택
- `var calledPop: Bool = false`
- `var calledDisappear: Bool = false`
- `var calledShowBundleError: Bool = false`
- `var calledExceptionRemove: Bool = false`
- 각 메서드 구현 시 해당 플래그를 `true`로 설정

---

### Phase 3. TotalLoadModel 테스트 케이스 추가

#### [x] Task 3 — `TotalLoadModelTests.swift` (수정)
**파일**: `SubwayWhenTests/DataLoad/TotalLoadModelTests.swift`
- `testRealtimePositionLoad` — MockLoadModel에 정상 열차 위치 응답 주입 후 결과 검증
- `testRealtimePositionLoadError` — 빈 응답 주입 후 빈 배열 반환 검증
- `testStationIdList` — 호선별 구간 분류 정확성 검증 (2호선 기준: 본선/성수지선/신정지선 구분)

---

### Phase 4. LoadModel 테스트 케이스 추가

#### [x] Task 4 — `LoadModelTests.swift` (수정)
**파일**: `SubwayWhenTests/DataLoad/LoadModelTests.swift`
- `testRealtimePositionRequest` — MockURLSession에 정상 응답 주입 후 파싱 결과 검증 (trainNo, updnLine 등 필드 확인)
- `testRealtimePositionRequestError` — 에러 데이터 주입 후 nil 반환 검증

---

### Phase 5. RealtimeFeature 테스트 파일 생성

#### [x] Task 5 — `RealtimeFeatureTests.swift` (신규)
**파일**: `SubwayWhenTests/Realtime/RealtimeFeatureTests.swift`
- `TestTotalLoadTCADependency` 재사용, `MockRealtimeVCDelegate` 주입
- `createStore()`: `var feature = RealtimeFeature()` 생성 후 `feature.coordinatorDelegate = self.mockDelegate` 설정

테스트 케이스 목록:

| 테스트 메서드 | 검증 내용 |
|-------------|---------|
| `testOnAppear` | `isLoading=true`, `stationListLoaded` + `trainPositionLoaded` 수신 확인 |
| `testStationListLoaded` | `stationSessions` 저장, 400ms 후 `scrollToStationRequest` 수신 |
| `testStationListLoadedEmpty` | 빈 StationSession → `bundleLoadFailed` 수신 |
| `testTrainPositionLoaded` | `trainPositions` 저장, `isLoading=false` |
| `testRefreshBtnTappedWithinCooltime` | `lastRefreshedDate` 15초 이내 → effect 없음 |
| `testRefreshBtnTappedAfterCooltime` | `lastRefreshedDate` nil(초기) → `isLoading=true`, `trainPositionLoaded` 수신 |
| `testExceptionBtnTapped` | `dialogState` 비nil, 메시지에 `exceptionLastStation` 포함 |
| `testDialogOkBtnTapped` | `exceptionLastStation=""`, `trainPositionLoaded` 수신, `mockDelegate.calledExceptionRemove=true` |
| `testScrollToStationCompleted` | `shouldScrollToStation=false` |
| `testBackBtnTapped` | `mockDelegate.calledPop=true` |
| `testOnDisappear` | `mockDelegate.calledDisappear=true` |
| `testBundleLoadFailed` | `mockDelegate.calledShowBundleError=true` |

---

## 체크리스트

### 품질 (DoD)
- [x] 빌드 성공
- [x] 테스트 통과 (RealtimeFeatureTests 12개, TotalLoadModel 신규 6개, LoadModel 신규 2개)

### 기능 (AC)
- [x] Spec Acceptance Criteria 전부 충족
