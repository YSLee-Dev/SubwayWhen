# Tasks: Realtime

## Phase 1. Detail → Realtime 진입 연결 (임시)

### [x] Task 1 — `DetailVCDelegate.swift`
**파일**: `SubwayWhen/Presentation/Detail/Coordinator/Protocol/DetailVCDelegate.swift`
- `pushRealtime(subwayLine: SubwayLineData, stationName: String)` 메서드 선언 추가

---

### [x] Task 2 — `DetailFeature.swift`
**파일**: `SubwayWhen/Presentation/Detail/DetailFeature.swift`
- `Action`에 `realtimeBtnTapped` 케이스 추가
- Reducer에서 `.realtimeBtnTapped` → `coordinatorDelegate?.pushRealtime(subwayLine:stationName:)` 호출
  - `subwayLine`: `SubwayLineData(rawValue: state.sendedLoadModel.lineNumber) ?? .not`
  - `stationName`: `state.sendedLoadModel.stationName`

---

### [x] Task 3 — `DetailArrivalView.swift`
**파일**: `SubwayWhen/Presentation/Detail/Sub/DetailArrivalView.swift`
- `realtimeBtnTapped: (() -> ())?` 파라미터 추가
- 상단 실시간 현황 카드(`MainStyleViewInSUI` 첫 번째 블록) 전체에 `.onTapGesture { realtimeBtnTapped?() }` 연결

---

### [x] Task 4 — `DetailView.swift`
**파일**: `SubwayWhen/Presentation/Detail/DetailView.swift`
- `DetailArrivalView` 호출 시 `realtimeBtnTapped: { store.send(.realtimeBtnTapped) }` 인자 추가

---

### [x] Task 5 — `RealtimeCoordinator.swift` (신규)
**파일**: `SubwayWhen/Presentation/Realtime/Coordinator/RealtimeCoordinator.swift`
- `Coordinator` 프로토콜 채택
- `init(navigation: UINavigationController, subwayLine: SubwayLineData, stationName: String)`
- `start()`: `RealtimeFeature.State(subwayLine:stationName:)` 초기화 → `RealtimeView` → `UIHostingController` push
- `RealtimeCoordinatorProtocol` 채택, `showBundleErrorPopupAndDismiss()` 구현:
  - UIAlertController로 에러 팝업 표시 후 `navigation.popViewController(animated: true)`

---

### [x] Task 6 — `DetailCoordinator.swift`
**파일**: `SubwayWhen/Presentation/Detail/Coordinator/DetailCoordinator.swift`
- `DetailVCDelegate.pushRealtime` 구현:
  - `RealtimeCoordinator(navigation:subwayLine:stationName:)` 생성 후 `start()` 호출
  - `childCoordinator.append(realtimeCoordinator)`

---

## Phase 2. TCA Dependency 확장

### [x] Task 7 — `TotalLoadTCADependencyProtocol.swift`
**파일**: `SubwayWhenNetworking/DataLoad/Entity/Protocol/TotalLoadTCADependencyProtocol.swift`
- `stationIdList(subwayLine: SubwayLineData) -> [DetailStationId]` 메서드 선언 추가

---

### [x] Task 8 — `TotalLoadTCADependency.swift`
**파일**: `SubwayWhenNetworking/DataLoad/TCADependecy/TotalLoadTCADependency.swift`
- `stationIdList(subwayLine:)` 구현 — `TotalLoadModel.stationIdList` 위임

---

### [x] Task 9 — `PreviewTotalLoadTCADependency.swift`
**파일**: `SubwayWhenNetworking/DataLoad/TCADependecy/PreviewTotalLoadTCADependency.swift`
- `stationIdList(subwayLine:)` 구현 — Preview용 더미 `[DetailStationId]` 반환

---

### [x] Task 10 — `TestTotalLoadTCADepdency.swift`
**파일**: `SubwayWhenNetworking/DataLoad/TCADependecy/TestTotalLoadTCADepdency.swift`
- `var stationIdListData: [DetailStationId] = []` 프로퍼티 추가
- `stationIdList(subwayLine:)` 구현 — `stationIdListData` 반환

---

## Phase 3. Coordinator 수정

### [x] Task 11 — `RealtimeCoordinatorProtocol.swift`
**파일**: `SubwayWhen/Presentation/Realtime/Coordinator/Protocol/RealtimeCoordinatorProtocol.swift`
- `showBundleErrorPopupAndDismiss()` 메서드 선언 추가

---

## Phase 4. RealtimeFeature 구현

### [x] Task 12 — `RealtimeFeature.swift`
**파일**: `SubwayWhen/Presentation/Realtime/RealtimeFeature.swift`
- `weak var coordinatorDelegate: RealtimeCoordinatorProtocol?` 추가
- `@Dependency(\.totalLoad) private var totalLoad` 추가
- `State` 구현:
  - `let subwayLine: SubwayLineData`
  - `let stationName: String`
  - `var stationList: [DetailStationId] = []`
  - `var trainPositions: [RealtimeTrainPosition] = []`
  - `var isLoading: Bool = false`
- `Action` 구현:
  - `onAppear`
  - `stationListLoaded([DetailStationId])`
  - `trainPositionLoaded([RealtimeTrainPosition])`
  - `refreshBtnTapped`
  - `bundleLoadFailed`
- `Reducer` 구현:
  - `onAppear` → 번들 로딩(동기, `.run`) + 실시간 위치 로딩(async) 병렬 실행, `isLoading = true`
  - `stationListLoaded` → 빈 배열이면 `.bundleLoadFailed` 발송, 아니면 `state.stationList` 업데이트
  - `trainPositionLoaded` → `state.trainPositions` 업데이트, `isLoading = false`
  - `bundleLoadFailed` → `coordinatorDelegate?.showBundleErrorPopupAndDismiss()` 호출
  - `refreshBtnTapped` → 실시간 위치 재로딩 (isLoading = true)

---

## Phase 5. RealtimeView 구현

### [x] Task 13 — `RealtimeStationRowView.swift` (신규/수정)
**파일**: `SubwayWhen/Presentation/Realtime/Sub/RealtimeStationRowView.swift`
- 역 1행 표시 서브뷰
- 입력:
  - `stationName: String`
  - `isSelected: Bool`
  - `trainStatus: TrainIconStatus?`
  - `trainInfo: String?` — "신사행 도착" 등, 열차 없으면 nil
  - `subwayLine: SubwayLineData` — 노선 색상용
  - `TrainIconStatus`: `enum { case arriving, departing, passing }` — 동일 파일 내 정의
- 레이아웃 (HStack 순서):
  ```
  HStack
    ├─ [열차 정보] Text(trainInfo ?? "") - smallSize, 고정 너비, trailing 정렬
    ├─ [노선색 수직선 + 열차 아이콘] ZStack
    │    - Rectangle: Color(subwayLine.rawValue), 항상 표시
    │    - 열차 아이콘: FixInfo.saveSetting.detailVCTrainIcon
    │        - passing: overlay alignment .top
    │        - arriving: overlay alignment .center
    │        - departing: overlay alignment .bottom
    └─ [역명] Text: selected = bold+accentColor, 기본 = regular+primary
  ```
- `ViewStyle.FontSize.mediumSize` / `ViewStyle.padding` 사용

---

### [x] Task 14 — `RealtimeView.swift`
**파일**: `SubwayWhen/Presentation/Realtime/RealtimeView.swift`
- `NavigationBarScrollViewInSUI` 로 전체 래핑, title: 노선명
- 상단 호선 배지: `StationTitleViewInSUI(title: subwayLine.useLine, lineColor: subwayLine.rawValue, size: 75, isFill: true)`
- 역 목록: `List` — `stationList`를 순서대로 표시, 각 행은 `RealtimeStationRowView`
  - `trainPositions`에서 `statnId == DetailStationId.stationId` 매칭으로 아이콘 상태 결정
  - `trainSttus == "0"` 진입, `"2"` 출발, 나머지 통과
- 새로고침 버튼 (`toolbar` 또는 `NavigationBarScrollViewInSUI` 우측) → `.refreshBtnTapped`
- `isLoading == true` 일 때 `ProgressView` 표시
- `.onAppear { store.send(.onAppear) }`
