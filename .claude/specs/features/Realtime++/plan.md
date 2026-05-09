# Plan: Realtime++

## 참조 Spec
- @specs/features/Realtime++/spec.md

## 현재 상태 파악

### 현황 분석
1호선(lineId: 1001)은 **구로역(stationId: 1001000141)** 에서 두 개의 노선으로 분기
- **경인선**: `1001000142` ~ `1001000161` (구일 ~ 인천)
- **경부선**: `1001080142` ~ `1001080176` (가산디지털단지 ~ 신창)

현재 `stationIdList(subwayLine:isUp:)` 는 `[DetailStationId]` (flat 리스트)를 반환하므로 분기 표현 불가.
현재 `RealtimeFeature.State.stationList`, `RealtimeView`는 단일 Section으로 역을 표시.

### 신규
- `StationSession.swift` — 세션(구간) 모델

### 수정
- `TotalLoadModel.stationIdList` — 반환 타입을 `[StationSession]` 으로 변경, 분기 로직 구현
- `TotalLoadProtocol` — `stationIdList` 시그니처 변경
- `TotalLoadTCADependencyProtocol` — `stationIdList` 시그니처 변경
- `TotalLoadTCADependency` — 위임 호출 반환 타입 변경
- `PreviewTotalLoadTCADependency` — 단일 세션 더미 반환
- `TestTotalLoadTCADepdency` — `stationIdListData` 타입을 `[StationSession]` 으로 변경
- `RealtimeFeature` — `stationList` → `stationSessions`, Action 교체
- `RealtimeView` — 세션별 Section 렌더링 (세션명 헤더 포함)

### 재사용
- `RealtimeStationRowView` — 변경 없음
- `UpDownExceptionViewInSUI` — 변경 없음
- `DetailStationId` — 변경 없음

---

## 기술적 결정사항

- **기존 `stationIdList` 수정**: 새 메서드를 추가하는 대신 기존 메서드의 반환 타입을 `[StationSession]` 으로 변경. 호출부가 RealtimeFeature 하나뿐이므로 영향 범위가 좁음  
- **분기 감지 방법**: 노선별 stationId 범위/패턴으로 세션 분리  
  - **1호선 (`.one`)**: 구로(1001000141) 기준  
    - 공통: stationId `<= "1001000141"` → `name: nil`  
    - 경인선: stationId `> "1001000141"` && contains `"000"` → `name: "경인선"`  
    - 경부선: stationId contains `"080"` → `name: "경부선"`  
  - **2호선 (`.two`)**: 지선이 별도 stationId 대역으로 분리됨  
    - 본선(순환): stationId `<= "1002000243"` → `name: nil`  
    - 성수지선: stationId `"1002002111"` ~ `"1002002114"` → `name: "성수지선"`  
    - 신정지선: stationId `>= "1002002341"` → `name: "신정지선"`  
  - **5호선 (`.five`)**: 강동(1005000548) 이후 분기  
    - 본선: stationId contains `"000"` → `name: nil`  
    - 마천지선: stationId contains `"080"` → `name: "마천지선"`  
- **단일 세션 노선**: 그 외 모든 노선은 `[StationSession(name: nil, stations: 전체)]` 반환  
- **isUp 정렬**: 각 세션 내 stations는 기존과 동일하게 stationId asc/desc 정렬 유지  
- **State 구조**: `stationList: [DetailStationId]` → `stationSessions: [StationSession]`. flat 접근 필요 시 `.flatMap { $0.stations }` 사용  

---

## 구현 순서

### Phase 1. 데이터 모델 추가

1. `StationSession.swift` 신규 생성  
   - `public struct StationSession: Equatable`  
   - `public let name: String?`  
   - `public let stations: [DetailStationId]`

---

### Phase 2. SubwayWhenNetworking — 기존 stationIdList 시그니처 변경

2. `TotalLoadModel.stationIdList` 수정  
   - 반환 타입: `[DetailStationId]` → `[StationSession]`  
   - `subwayLine` switch로 노선별 분기:
     - **`.one`**: 공통(`<= "1001000141"`, name: nil) / 경인선(`> "1001000141"` && `"000"`) / 경부선(`"080"`)  
     - **`.two`**: 본선(`<= "1002000243"`, name: nil) / 성수지선(`"1002002111"~"1002002114"`) / 신정지선(`>= "1002002341"`)  
     - **`.five`**: 본선(`"000"`, name: nil) / 마천지선(`"080"`)  
     - **default**: 단일 세션  
   - 각 세션 내 stations는 `isUp` 기준 asc/desc 정렬  
3. `TotalLoadProtocol` — `stationIdList` 반환 타입 `[StationSession]` 으로 변경  
4. `TotalLoadTCADependencyProtocol` — 동일하게 반환 타입 변경  
5. `TotalLoadTCADependency` — 위임 호출만 유지, 반환 타입 따라감  
6. `PreviewTotalLoadTCADependency` — 단일 `StationSession` 더미 반환  
7. `TestTotalLoadTCADepdency` — `stationIdListData` 타입을 `[StationSession]` 으로 변경  

---

### Phase 3. RealtimeFeature 수정

8. `State`:  
   - `stationList: [DetailStationId]` → `stationSessions: [StationSession] = []`  
   - 기존 `stationList` 참조는 `stationSessions.flatMap { $0.stations }` 으로 대체  
9. `Action`:  
   - `stationListLoaded([DetailStationId])` → `stationListLoaded([StationSession])`  
10. `Reducer`:  
    - `stationListLoaded`: 모든 세션의 stations가 비어있으면 `.bundleLoadFailed`, 아니면 `state.stationSessions` 갱신  

---

### Phase 4. RealtimeView 수정

11. `LazyVStack` 내 단일 `Section` → `ForEach(stationSessions)` 로 다중 Section  
    - 각 Section의 `header`: `session.name != nil` 이면 노선명 텍스트 표시, `nil` 이면 헤더 없음  
    - 각 Section의 `content`: 기존 `RealtimeStationRowView` 동일  

---

## 완료 조건

- [ ] 1호선 진입 시 구로 기준으로 공통/경인선/경부선 3개 구간으로 나뉘어 표시
