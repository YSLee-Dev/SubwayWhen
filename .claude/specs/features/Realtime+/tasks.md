# Tasks: Realtime+

## Phase 1. SubwayWhenNetworking — 프로토콜 및 구현체 시그니처 변경

- [x] 1-1. `TotalLoadTCADependencyProtocol` — `realtimePositionLoad(subwayLine:isUp:exceptionLastStation:)` 로 시그니처 변경
- [x] 1-2. `TotalLoadProtocol` — 동일하게 시그니처 변경
- [x] 1-3. `TotalLoadModel.realtimePositionLoad` — 파라미터 추가 후 필터링 로직 구현
  - 9호선 여부에 따라 `updnLine` 기준값 결정 ("0" = 상행, "1" = 하행, 9호선 반전)
  - `updnLine` 일치 필터
  - `statnTnm`이 `exceptionLastStation`에 미포함 필터 (빈 문자열이면 통과)
- [x] 1-4. `TotalLoadTCADependency` — 변경된 시그니처에 맞게 위임 호출 수정
- [x] 1-5. `PreviewTotalLoadTCADependency` — 시그니처만 맞춤 (필터링 없이 반환)
- [x] 1-6. `TestTotalLoadTCADepdency` — 시그니처만 맞춤

## Phase 2. RealtimeFeature — 호출부 및 액션 수정

- [x] 2-1. `trainPositionRequest(subwayLine:)` → `trainPositionRequest(state:)` 로 변경, `state.isUp` · `state.exceptionLastStation` 함께 전달
- [x] 2-2. `Action`에 `exceptionStationSelected(String)` 추가
- [x] 2-3. `exceptionStationSelected` 핸들러 구현 — `state.exceptionLastStation` 갱신 후 `trainPositionRequest(state:)` 트리거
- [x] 2-4. `RealtimeCoordinatorProtocol` — `showExceptionStationSheet()` 유지 (Coordinator가 store 보관하여 직접 send)
- [x] 2-5. `RealtimeCoordinator.showExceptionStationSheet` — 시트 구현, 역 선택 시 `store.send(.exceptionStationSelected(station))` 호출
