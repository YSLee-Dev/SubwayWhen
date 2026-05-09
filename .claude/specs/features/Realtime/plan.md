# Plan: Realtime

## 참조 Spec
- @specs/features/Realtime/spec.md

## 참조 Skill
신규 화면 생성 시
- @skills/create-feature/SKILL.md

## 현재 상태 파악

### 재사용
- `realtimePositionLoad(subwayLine:)` — `TotalLoadTCADependencyProtocol`에 이미 정의됨. 호선별 실시간 열차 위치 로드에 사용
- `StationTitleViewInSUI` — 호선 색상 배지 표시에 재사용
- `NavigationBarScrollViewInSUI` — 스크롤 뷰 + 네비게이션 통합 컴포넌트 재사용
- `MainStyleViewInSUI` — 카드 컨테이너 스타일 재사용
- `ViewStyle` (fontSize, radius, padding 상수) — 그대로 사용

### 수정
- `RealtimeFeature.swift` — 현재 skeleton. State / Action / Reducer 전면 구현 필요
- `RealtimeView.swift` — 현재 EmptyView. 실제 UI 구현 필요
- `RealtimeCoordinatorProtocol.swift` — 현재 빈 protocol. 팝업 후 dismiss 델리게이트 추가 필요
- `TotalLoadTCADependencyProtocol.swift` — `stationIdList(subwayLine:)` 메서드 추가 필요
- `TotalLoadTCADependency.swift` / `PreviewTotalLoadTCADependency.swift` / `TestTotalLoadTCADepdency.swift` — 위 메서드 구현 추가
- `DetailVCDelegate.swift` — `pushRealtime(subwayLine:stationName:)` 메서드 추가
- `DetailFeature.swift` — `realtimeBtnTapped` Action 추가, Reducer에서 delegate 호출
- `DetailArrivalView.swift` — `realtimeBtnTapped: (() -> ())?` 콜백 파라미터 추가 및 탭 연결
- `DetailView.swift` — `DetailArrivalView`에 `store.send(.realtimeBtnTapped)` 핸들러 연결
- `DetailCoordinator.swift` — `pushRealtime` 구현 (RealtimeCoordinator push)

### 삭제
- 없음

---

## 기술적 결정사항

- **`stationIdList`는 TCA 의존성에 동기 메서드로 추가**: plist 번들 로딩은 async 불필요. 기존 `TotalLoadProtocol`에는 이미 존재하므로, `TotalLoadTCADependencyProtocol`에도 동일 시그니처 `stationIdList(subwayLine: SubwayLineData) -> [DetailStationId]`로 추가

- **입력 모델은 노선 + 역명 분리**: `State`에 `let subwayLine: SubwayLineData`, `let stationName: String`을 별도로 받음. 향후 역명 없이 노선만으로 진입하는 케이스를 고려하여 `SaveStation`을 직접 주입하지 않음

- **번들 로딩 실패 시 Coordinator 위임**: `RealtimeCoordinatorProtocol`에 `showBundleErrorPopupAndDismiss()` 추가. Feature → Coordinator 델리게이트 패턴으로 처리 (UIKit Coordinator 브릿지)

- **실시간 데이터 로드 실패는 에러 표시 없이 빈 상태 유지**: spec의 불변 조건 1 충족. 역 목록은 번들에서, 열차 위치는 네트워크에서 분리하여 독립적으로 처리

- **자동 갱신 없음 (v1)**: 수동 새로고침만 지원. 타이머 로직은 DetailFeature 참고하여 후속 스펙으로 분리

---

## 구현 순서

### Phase 1. TCA Dependency 확장
- `TotalLoadTCADependencyProtocol`에 `stationIdList(subwayLine:) -> [DetailStationId]` 추가
- `TotalLoadTCADependency` (프로덕션 구현체)에 해당 메서드 구현 — 기존 `TotalLoadModel.stationIdList` 위임
- `PreviewTotalLoadTCADependency`에 더미 데이터 반환 구현
- `TestTotalLoadTCADepdency`에 주입 가능한 `var stationIdListData: [DetailStationId]` 추가 후 반환

### Phase 2. RealtimeFeature 구현
- `State`: `subwayLine: SubwayLineData`, `stationName: String`, `stationList: [DetailStationId]`, `trainPositions: [RealtimeTrainPosition]`, `isLoading: Bool`
- `Action`: `onAppear`, `stationListLoaded([DetailStationId])`, `trainPositionLoaded([RealtimeTrainPosition])`, `refreshBtnTapped`, `bundleLoadFailed`
- `Reducer`:
  - `onAppear` → 번들 로딩(동기) + 실시간 위치 로딩(async) 병렬 실행
  - `stationListLoaded([])` (빈 배열) → `.bundleLoadFailed` 발송
  - `bundleLoadFailed` → `coordinatorDelegate?.showBundleErrorPopupAndDismiss()` 호출
  - `trainPositionLoaded` → `state.trainPositions` 업데이트 (실패 시 빈 배열 유지)
  - `refreshBtnTapped` → 실시간 위치 재로딩

### Phase 3. RealtimeCoordinatorProtocol 수정
- `showBundleErrorPopupAndDismiss()` 메서드 선언 추가
- `weak var coordinatorDelegate: RealtimeCoordinatorProtocol?` 를 Feature에 추가

### Phase 4. RealtimeView 구현
레이아웃 구조:
```
NavigationView
  └─ VStack
      ├─ StationTitleViewInSUI  ← 호선명 배지 (여기서만 사용)
      └─ List (스크롤)
          └─ 역명 행 (Sub/RealtimeStationRowView)
              ├─ [열차 정보] - 해당 역에 열차가 있을 때만 표시 (e.g. "신사행 도착")
              ├─ [노선색 수직선 + 열차 아이콘]
              │    - 수직선은 노선 색(SubwayLineData.rawValue)으로 항상 표시
              │    - 열차 아이콘(FixInfo.saveSetting.detailVCTrainIcon) 위치:
              │        - 통과(전역출발): 수직선 상단 (역 이름보다 앞)
              │        - 진입: 수직선 중앙 (역 위치)
              │        - 출발: 수직선 하단 (역 이름보다 뒤)
              └─ [역명] - 선택된 역 bold + accent, 기본 regular
```
- `trainPositions`에서 역 ID(`statnId`)가 `DetailStationId.stationId`와 일치하면 아이콘 표시
- `trainSttus == "0"` 진입, `"2"` 출발, 나머지 통과
- `trainInfo` = `"\(position.statnTnm)행 \(position.trainStatus)"` 형태로 RealtimeView에서 계산 후 전달
- `stationName`과 일치하는 역 행은 강조(bold 또는 색상)
- 새로고침 버튼 → `.refreshBtnTapped`
- 역명 행 뷰는 `Sub/RealtimeStationRowView.swift`로 분리

#### RealtimeStationRowView 파라미터
- `stationName: String`
- `isSelected: Bool`
- `trainStatus: TrainIconStatus?`
- `trainInfo: String?` — "신사행 도착" 등, 열차 없으면 nil
- `subwayLine: SubwayLineData` — 노선 색상용

---

### Phase 5. Detail → Realtime 진입 연결 (임시)
`DetailArrivalView` 탭 → `DetailFeature` → `DetailCoordinator` → `RealtimeCoordinator` 순으로 위임

- `DetailVCDelegate`에 `pushRealtime(subwayLine: SubwayLineData, stationName: String)` 추가
- `DetailFeature.Action`에 `realtimeBtnTapped` 추가, Reducer에서 `coordinatorDelegate?.pushRealtime(subwayLine:stationName:)` 호출
  - `subwayLine`: `SubwayLineData(rawValue: state.sendedLoadModel.lineNumber)`
  - `stationName`: `state.sendedLoadModel.stationName`
- `DetailArrivalView`에 `realtimeBtnTapped: (() -> ())?` 콜백 파라미터 추가
  - 기존 `MainStyleViewInSUI` 전체(실시간 현황 카드)에 `.onTapGesture { realtimeBtnTapped?() }` 연결
- `DetailView`에서 `DetailArrivalView` 호출 시 `realtimeBtnTapped: { store.send(.realtimeBtnTapped) }` 전달
- `DetailCoordinator`에서 `DetailVCDelegate.pushRealtime` 구현:
  - `RealtimeCoordinator(navigation:subwayLine:stationName:)` 생성 후 `start()` 호출
  - `childCoordinator`에 추가
- `RealtimeCoordinator.swift` 신규 생성:
  - `navigation.pushViewController(UIHostingController(rootView: RealtimeView(...)), animated: true)`
  - `RealtimeCoordinatorProtocol` 채택, `showBundleErrorPopupAndDismiss()` 구현 (Alert + pop)

---

## 완료 조건
- [ ] Spec Acceptance Criteria 충족
  - [ ] 선택된 노선의 전체 역 정보를 보여줄 수 있다
  - [ ] 선택된 노선의 실시간 열차 정보를 보여줄 수 있다
  - [ ] 네트워크 에러가 발생한 경우에도 역 정보는 표시한다
  - [ ] 번들을 가져오지 못한 경우 팝업을 표출하고 뒤로 이동한다
