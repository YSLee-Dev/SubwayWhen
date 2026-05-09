# Plan: Realtime+

## 참조 Spec
- @specs/features/Realtime+/spec.md

## 현재 상태 파악

### 재사용
- `RealtimeFeature.swift` — State(isUp, exceptionLastStation), Action 구조 그대로 유지
- `RealtimeView.swift` — 뷰 구조 변경 없음
- `RealtimeStationRowView.swift` — 변경 없음
- `RealtimeCoordinator.swift` — 변경 없음
- `RealtimeTrainPosition.updnLine` — 상하행 필터링에 활용 ("0" = 상행, "1" = 하행)
- `RealtimeTrainPosition.statnTnm` — 제외행 필터링에 활용 (종착역명)

### 수정
- `TotalLoadTCADependencyProtocol` — `realtimePositionLoad` 시그니처에 `isUp: Bool`, `exceptionLastStation: String` 파라미터 추가
- `TotalLoadProtocol` — 동일하게 시그니처 변경
- `TotalLoadModel.realtimePositionLoad` — 필터링 로직 구현 (상하행, 제외행, 9호선 반전)
- `TotalLoadTCADependency` — 변경된 시그니처에 맞게 위임 호출 수정
- `PreviewTotalLoadTCADependency` — 시그니처 수정 (필터링 로직 불필요, 파라미터만 추가)
- `TestTotalLoadTCADepdency` — 시그니처 수정
- `RealtimeFeature.trainPositionRequest` — `isUp`, `exceptionLastStation`을 함께 전달하도록 수정

### 문제 현황
1. `realtimePositionLoad`는 노선 전체 열차를 반환하지만, 상하행/제외행 필터링이 없음
2. `exceptionLastStation`이 State에 존재하지만 네트워크 요청에 미전달
3. 9호선(`SubwayLineData.nine`)은 상하행이 실제 반대 (기존 로직 참조: `TotalLoadModel`)

## 기술적 결정사항

- **필터링 위치 → TotalLoadModel**: 상하행/제외행 조건은 데이터 요청 조건이므로 네트워크 레이어에서 처리. Feature는 수신된 결과를 그대로 사용
- **rawTrainPositions 불필요**: TotalLoadModel이 이미 필터링된 결과를 반환하므로 State에 원본 보관 불필요
- **9호선 반전 처리 → TotalLoadModel 내 처리**: 기존 `TotalLoadModel`의 다른 로직과 동일하게 9호선은 isUp 방향을 반전하여 필터링
- **exceptionLastStation 재요청 방식**: exceptionLastStation 변경 시 `refreshBtnTapped`와 동일하게 네트워크 재요청 발생

## 구현 순서

### Phase 1. SubwayWhenNetworking — 프로토콜 및 구현체 시그니처 변경

1. `TotalLoadTCADependencyProtocol` — `realtimePositionLoad(subwayLine:isUp:exceptionLastStation:)` 로 변경
2. `TotalLoadProtocol` — 동일하게 변경
3. `TotalLoadModel.realtimePositionLoad` — 파라미터 추가 후 필터링 로직 구현:
   - 9호선 여부에 따라 `updnLine` 기준값 결정 ("0" = 상행, "1" = 하행, 9호선 반전)
   - `updnLine` 일치 필터
   - `statnTnm`이 `exceptionLastStation`에 미포함 필터 (빈 문자열이면 통과)
4. `TotalLoadTCADependency` — 위임 호출 시 파라미터 전달
5. `PreviewTotalLoadTCADependency` — 시그니처만 맞춤 (필터링 없이 반환)
6. `TestTotalLoadTCADepdency` — 시그니처만 맞춤

### Phase 2. RealtimeFeature — 호출부 수정

1. `trainPositionRequest(subwayLine:)` → `trainPositionRequest(state:)` 로 변경하여 `state.isUp`, `state.exceptionLastStation` 함께 전달
2. `Action`에 `exceptionStationSelected(String)` 추가
   - `exceptionBtnTapped` → `coordinatorDelegate?.showExceptionStationSheet()` 호출 (기존 유지)
   - `RealtimeCoordinator.showExceptionStationSheet` — 시트 표시 후 역 선택 콜백에서 `store.send(.exceptionStationSelected(station))` 호출
   - `exceptionStationSelected` 핸들러 — `state.exceptionLastStation` 갱신 후 네트워크 재요청(`trainPositionRequest(state:)`) 트리거

### Phase 3. 검증

- `exceptionLastStation`가 빈 문자열일 때: 상하행 필터만 적용
- `exceptionLastStation`가 있을 때: 상하행 + 제외행 모두 필터 적용
- 9호선: isUp=true여도 `updnLine == "1"` 기준으로 필터

## 완료 조건
- [ ] Spec Acceptance Criteria 충족: 선택된 노선의 실시간 열차 정보를 상하행·제외행 기준으로 필터링하여 표시
