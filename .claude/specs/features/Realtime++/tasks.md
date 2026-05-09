# Tasks: Realtime++

## 참조
- spec: `.claude/specs/features/Realtime++/spec.md`
- plan: `.claude/specs/features/Realtime++/plan.md`

## Task 목록

### Phase 1. 데이터 모델 추가

#### [x] Task 1 — `StationSession.swift` (신규)
**파일**: `SubwayWhenNetworking/DataLoad/Entity/StationId/StationSession.swift`
- `public struct StationSession: Equatable` 선언
- `public let name: String?` — 세션명 (nil = 본선/단일 세션)
- `public let stations: [DetailStationId]`

---

### Phase 2. SubwayWhenNetworking — stationIdList 시그니처 변경

#### [x] Task 2 — `TotalLoadModel.swift`
**파일**: `SubwayWhenNetworking/DataLoad/TotalLoadModel.swift`
- `stationIdList(subwayLine:isUp:)` 반환 타입: `[DetailStationId]` → `[StationSession]`
- `subwayLine` switch로 노선별 세션 분리 구현:
  - **`.one`** (1호선):
    - 공통: stationId `<= "1001000141"` → `StationSession(name: nil, stations:)`
    - 경인선: stationId `> "1001000141"` && contains `"000"` → `StationSession(name: "경인선", stations:)`
    - 경부선: stationId contains `"080"` → `StationSession(name: "경부선", stations:)`
  - **`.two`** (2호선):
    - 본선: stationId `<= "1002000243"` → `StationSession(name: nil, stations:)`
    - 성수지선: `"1002002111"` ~ `"1002002114"` → `StationSession(name: "성수지선", stations:)`
    - 신정지선: stationId `>= "1002002341"` → `StationSession(name: "신정지선", stations:)`
  - **`.five`** (5호선):
    - 본선: stationId contains `"000"` → `StationSession(name: nil, stations:)`
    - 마천지선: stationId contains `"080"` → `StationSession(name: "마천지선", stations:)`
  - **default**: `[StationSession(name: nil, stations: 기존 정렬 결과)]`
- 각 세션 내 stations는 `isUp` 기준 asc/desc 정렬 유지

---

#### [x] Task 3 — `TotalLoadProtocol.swift`
**파일**: `SubwayWhenNetworking/DataLoad/Entity/Protocol/TotalLoadProtocol.swift`
- `stationIdList(subwayLine:isUp:)` 반환 타입을 `[StationSession]` 으로 변경

---

#### [x] Task 4 — `TotalLoadTCADependencyProtocol.swift`
**파일**: `SubwayWhenNetworking/DataLoad/Entity/Protocol/TotalLoadTCADependencyProtocol.swift`
- `stationIdList(subwayLine:isUp:)` 반환 타입을 `[StationSession]` 으로 변경

---

#### [x] Task 5 — `TotalLoadTCADependency.swift`
**파일**: `SubwayWhenNetworking/DataLoad/TCADependecy/TotalLoadTCADependency.swift`
- `stationIdList(subwayLine:isUp:)` 반환 타입을 `[StationSession]` 으로 변경 (위임 호출 유지)

---

#### [x] Task 6 — `PreviewTotalLoadTCADependency.swift`
**파일**: `SubwayWhenNetworking/DataLoad/TCADependecy/PreviewTotalLoadTCADependency.swift`
- `stationIdList(subwayLine:isUp:)` 반환 타입을 `[StationSession]` 으로 변경
- 기존 `[DetailStationId]` 반환 값을 `[StationSession(name: nil, stations: 기존값)]` 으로 래핑

---

#### [x] Task 7 — `TestTotalLoadTCADepdency.swift`
**파일**: `SubwayWhenNetworking/DataLoad/TCADependecy/TestTotalLoadTCADepdency.swift`
- `stationIdListData` 타입을 `[StationSession]` 으로 변경 (초기값: `[]`)
- `stationIdList(subwayLine:isUp:)` 반환 타입을 `[StationSession]` 으로 변경

---

### Phase 3. RealtimeFeature 수정

#### [x] Task 8 — `RealtimeFeature.swift`
**파일**: `SubwayWhen/Presentation/Realtime/RealtimeFeature.swift`
- `State`:
  - `stationList: [DetailStationId]` → `stationSessions: [StationSession] = []`
- `Action`:
  - `stationListLoaded([DetailStationId])` → `stationListLoaded([StationSession])`
- `Reducer`:
  - `onAppear`: `totalLoad.stationIdList` 호출 결과를 `send(.stationListLoaded(_))` 로 전달 (타입만 변경)
  - `stationListLoaded`: 빈 조건을 `sessions.allSatisfy { $0.stations.isEmpty }` 로 변경, `state.stationSessions` 갱신
  - `scrollToStationRequest` / 스크롤 타겟: `state.stationSessions.flatMap { $0.stations }` 로 flat 접근

---

### Phase 4. RealtimeView 수정

#### [x] Task 9 — `RealtimeView.swift`
**파일**: `SubwayWhen/Presentation/Realtime/RealtimeView.swift`
- `LazyVStack` 내 단일 `Section` → `ForEach(store.stationSessions, id: \.name)` 로 다중 Section
- 각 Section:
  - `header`: `session.name` 이 있으면 텍스트 헤더 표시 (스타일: `ViewStyle.FontSize.smallSize`, secondary color), `nil` 이면 헤더 없음 (`EmptyView`)
  - `content`: 기존 `RealtimeStationRowView` 동일 (`session.stations` 순회)
- train position 매칭: `store.stationSessions.flatMap { $0.stations }` 에서 `statnId` 비교 (기존 로직 유지)

---

## 체크리스트

### 품질 (DoD)
- [ ] 빌드 성공
- [ ] 테스트 통과

### 기능 (AC)
- [ ] 1호선 진입 시 구로 기준으로 공통/경인선/경부선 3개 구간으로 나뉘어 표시
- [ ] 2호선 진입 시 본선/성수지선/신정지선으로 나뉘어 표시
- [ ] 5호선 진입 시 본선/마천지선으로 나뉘어 표시
- [ ] 그 외 노선(3·4·6호선 등)은 단일 세션으로 기존과 동일하게 표시
