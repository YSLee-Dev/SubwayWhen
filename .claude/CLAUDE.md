## 프로젝트 개요
지하철 민원 접수부터 실시간 도착 정보, 시간표 정보까지 **'한눈에, 빠르고 편하게'** 확인할 수 있는 iOS 앱

---

## 빌드 & 테스트 명령어

```bash
# 앱 빌드
xcodebuild build -workspace SubwayWhen.xcworkspace -scheme SubwayWhen -destination 'platform=iOS Simulator,name=iPhone 16'

# 전체 테스트 실행
xcodebuild test -workspace SubwayWhen.xcworkspace -scheme SubwayWhen -destination 'platform=iOS Simulator,name=iPhone 16'

# 단일 테스트 클래스 실행
xcodebuild test -workspace SubwayWhen.xcworkspace -scheme SubwayWhen -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:SubwayWhenTests/CongestionModalFeatureTests

# 단일 테스트 메서드 실행
xcodebuild test -workspace SubwayWhen.xcworkspace -scheme SubwayWhen -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:SubwayWhenTests/CongestionModalFeatureTests/testModalInit
```

---

## 규칙 문서 참조

세부 컨벤션은 아래 규칙 문서를 참조

| 문서 | 경로 | 내용 |
|------|------|------|
| Swift 스타일 | `.claude/rules/swift-style.md` | 네이밍, 코드 구조, TCA/RxSwift 패턴, 접근 제어 등 |
| 폴더 구조 | `.claude/rules/folder-structure.md` | 타겟별 디렉토리 구조, 파일 배치 규칙 |
| 테스트 스타일 | `.claude/rules/test-style.md` | TCA TestStore, MVVM-C RxBlocking, 테스트 더블 작성 |
| Git 컨벤션 | `.claude/rules/git-style.md` | 커밋 키워드, 메시지 규칙 |

---

## 아키텍처 개요

**MVVM-C**(레거시)와 **TCA**(v1.5+부터 마이그레이션 진행 중) 두 아키텍처가 공존

> **신규 화면은 반드시 TCA + SwiftUI. 
기존 MVVM-C 화면은 TCA 마이그레이션 없이 유지보수만.**

### 타겟 구성

- **SubwayWhen** — 메인 앱 타겟 (UIKit + SwiftUI)
- **SubwayWhenNetworking** — 네트워킹, 데이터 모델, CoreData, TCA 의존성 등록을 담당하는 별도 프레임워크
- **SubwayWhenDetailWidget** — ActivityKit 익스텐션
- **SubwayWhenHomeWidget** — WidgetKit 익스텐션
- **SubwayWhenTests** — 테스트 타겟

### MVVM-C 패턴 (레거시 화면)

- **VC** (UIViewController) — UI 렌더링만 담당, RxCocoa 바인딩으로 ViewModel 출력을 구독
- **ViewModel** — VC 입력을 RxSwift Observable 출력으로 변환, 데이터 처리는 Model에 위임
- **Model** — 네트워크 요청과 데이터 변환 담당, Observable 반환
- **Coordinator** — 화면 전환/표시 관리, VC와 ViewModel 간 의존성 주입 수행

`AppCoordinator`는 `TabBarController`도 소유합니다(메인 · 검색 · 설정 탭). 자식 Coordinator는 `childCoordinator: [Coordinator]`에 저장되며 `didDisappear` 시 제거됩니다.

### TCA 패턴 (신규 화면)

TCA로 마이그레이션된 화면: `SearchFeature`, `DetailFeature`, `ReportFeature`, `SettingFeature`, `CongestionModalFeature`, `RealtimeFeature`

- Feature는 `@Reducer struct` 하나에 `State`, `Action`, `body`(Reducer)를 정의
- 비동기 작업은 `.run {}` 이펙트 사용, `.cancellable(id:)` / `.cancel(id:)`로 취소
- 화면 전환 사이드 이펙트(present, push)는 Feature의 `weak var delegate: SomeProtocol?`을 통해 외부로 위임 — TCA와 UIKit Coordinator 레이어를 연결하는 브릿지

### TCA 의존성

`SubwayWhen/Service/Dependency+.swift`에서 `DependencyValues` 익스텐션으로 등록:

| 키 | 타입 | 용도 |
|-----|------|---------|
| `totalLoad` | `TotalLoadTCADependencyProtocol` | 모든 네트워크 데이터 패칭 |
| `locationManager` | `LocationManagerProtocol` | Core Location |
| `notificationManager` | `NotificationManagerProtocol` | UNUserNotificationCenter |
| `congestionManager` | `CongestionManagerProtocol` | 역 혼잡도 데이터 |

구현체는 `SubwayWhenNetworking/`(`totalLoad`)과 `SubwayWhen/Service/`(나머지)에 위치. 테스트 더블은 `SubwayWhenTests/Mock/`에 있음.

### 전역 상태

`FixInfo`(`SubwayWhen/Configuration/FixInfo.swift`)는 두 개의 static 프로퍼티를 가지며, `didSet`을 통해 공유 `UserDefaults`에 자동으로 영속화됩니다:
- `FixInfo.saveStation: [SaveStation]` — 사용자가 저장한 지하철역 목록
- `FixInfo.saveSetting: SaveSetting` — 앱 설정 (열차 아이콘, 혼잡도 기준역, 튜토리얼 플래그 등)

### 네트워킹 레이어 (`SubwayWhenNetworking`)

- `NetworkManager` — URLSession 기반 순수 HTTP 통신 (Mocking을 위한 프로토콜 지원)
- `LoadModel` — `NetworkManager` 래퍼, 서울/코레일 API 호출 담당
- `TotalLoadModel` — 다수의 `LoadModel` 호출을 조율, 앱 레벨 모델로 변환, Firebase/Database 및 로컬 번들 plist(`DetailStationIdList.plist`) 읽기도 담당
- `CoreDataScheduleManager` — 신분당선 시간표를 CoreData에 캐시
- `TotalLoadTCADependency` — RxSwift Observable을 `withCheckedContinuation`으로 async/await에 브릿지하여 TCA Effect에서 사용 가능하게 변환

---

## 주의사항

- IMPORTANT 네트워크 요청은 `NetworkManager` 사용 (URLSession 직접 사용 금지)
- IMPORTANT `RequestToken.plist`는 Commit을 포함한 git과 관련된 행동 금지
- IMPORTANT 공통 컴포넌트(`Presentation/Common/`)·문자열(`Strings.swift`)·`ViewStyle` 상수는 새로 만들기 전에 기존 항목을 먼저 확인 후 재사용

---
