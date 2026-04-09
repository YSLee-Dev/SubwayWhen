---
name: swift-style
description: Swift 코딩 컨벤션을 정의한 문서
---


## 1. 네이밍 (Naming)

### 파일 / 타입명

| 항목 | 규칙 | 예시 |
|------|------|------|
| TCA Reducer | `{Name}Feature` | `SearchFeature` |
| SwiftUI View | `{Name}View` | `SearchView` |
| UIViewController | `{Name}VC` | `ModalVC` |
| ViewModel | `{Name}ViewModel` | `ModalViewModel` |
| Coordinator | `{Name}Coordinator` | `SearchCoordinator` |
| Protocol | `{Name}Protocol` | `SearchVCActionProtocol` |
| Extension 파일 | `{Type}+.swift` | `UIView+.swift` |
| Entity / DTO | 도메인 기반 PascalCase | `SaveStation`, `LiveArrivalData` |

### 함수 / 변수

- camelCase 사용
- 함수명은 동사로 시작: `fetchData()`, `configureLayout()`, `bindViewModel()`
- Bool 변수는 `is`, `has`, `should` 프리픽스 사용

### 프로토콜

- 역할을 나타낼 때: `{Name}Protocol` 접미사
- 능력을 나타낼 때: `-able`, `-ing` 접미사

### TCA Action 케이스

- 사용자 인터랙션: 과거형 동사 + 대상 (`buttonTapped`, `cellSelected`)
- 시스템/생명주기: `onAppear`, `onDisappear`, `didLoad`
- 비동기 결과 수신: `dataLoaded`, `dataResult`, `fetchCompleted`
- 내부 상태 변경: `binding` (BindableAction)

---

## 2. 코드 구조 (Code Structure)

### MARK 섹션 순서 (TCA Feature는 State / Action / body 구조를 따르므로 MARK 미적용)
```swift
// MARK: - Properties
// MARK: - Init
// MARK: - Life Cycle(UIViewController / Class) / View (Swift UI View)
// MARK: - Method
```

### Extension으로 프로토콜 채택 분리

프로토콜 채택은 본문에 포함하지 않고 별도 `extension`으로 분리:

```swift
// MARK: - SearchVCActionProtocol
extension SearchCoordinator: SearchVCActionProtocol {
    func pushDetail(data: SaveStation) { ... }
}
```

### 접근 제어 분리

같은 타입의 `private` 멤버는 하단 `extension`에 모아서 선언:

```swift
// MARK: - Method
private extension MainViewModel {
    func processData(_ data: [SaveStation]) { ... }
}
```

---

## 3. Swift 언어 관용구 (Swift Idioms)

### guard let vs if let

- 이후 코드 흐름에서 값이 반드시 필요한 경우 → `guard let` (조기 탈출)
- 분기 처리가 필요한 경우 → `if let`

### weak self 캡처

- RxSwift 클로저, 비동기 콜백, TCA `.run {}` 내부에서 `self` 참조 시 `weak` 캡처
- `guard`으로 `self`를 안전하게 사용

### 타입 추론

- 우변으로 타입이 명확한 경우 타입 생략
- 컬렉션 리터럴, 함수 반환 타입은 명시

### Optional Handling

- `!` 강제 언래핑 금지 — `guard let` 또는 `??` 사용
- 테스트 코드에서만 예외 허용 (`try!`, `as!`)

---

## 4. RxSwift 패턴

### Driver vs Observable 선택

| 상황 | 타입 |
|------|------|
| UI 바인딩 (VC → View) | `Driver` |
| 내부 데이터 스트림 | `Observable` |
| 초기 값 이벤트 방출| `BehaviorRelay` |
| 단순 이벤트 방출 | `PublishRelay` / `PublishSubject` |

### withUnretained 사용

클로저 내 `[weak self]` + `guard let self` 대신 `withUnretained` 활용:

---

## 5. TCA 패턴

### State 선언 순서
    1. 공개 프로퍼티 — 초기값과 함께 선언
    2. fileprivate 프로퍼티 — 내부 로직용
    3. @Presents — 하위 화면 상태
    
### Action 선언 순서
    1. 바인딩
    2. 생명주기
    3. 사용자 인터랙션
    4. 비동기 결과
    5. 하위 액션

### body 선언 순서

```swift
var body: some Reducer<State, Action> {
    BindingReducer()    // 항상 첫 번째
    Reduce { state, action in
        // 핵심 로직
    }
    .ifLet(\.alertState, action: \.alert)   // 하위 Reducer는 마지막
}
```

---

## 6. UIKit / SwiftUI 스타일
### UIKit - 뷰 세팅 기준

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    self.layout()       // 1. 뷰 계층 구성 + SnapKit
    self.attribute()    // 2. 속성 설정
    self.bind()         // 3. RxSwift 바인딩
}
```

### SwiftUI — 뷰 분리 기준

- `body`가 50줄 초과 시 서브뷰로 분리
- 반복되는 UI 패턴은 별도 View 컴포넌트로 추출
- `Sub/` 폴더에 위치

---

## 7. 접근 제어 (Access Control)

### 기본 원칙

가능한 한 좁은 접근 제어 사용: `private` → `fileprivate` → `internal` → `public` 순으로 확장

| 수준 | 사용 기준 |
|------|----------|
| `private` | 같은 타입 선언 내에서만 사용 |
| `fileprivate` | 같은 파일 내 extension에서 접근 필요 시 |
| `internal` (기본값) | 모듈 내 다른 타입에서 접근 필요 시 — 명시 생략 |
| `public` | SubwayWhenNetworking → SubwayWhen 노출 시 (최대한 자제) |

---

## 8. 재사용성

- String은 코드에 정의하지 않고, Resource/Strings에 있는지 검사 후 참조해서 사용
    - 만약 없을 경우 해당 기능에 맞는 Extension 내부에 String을 정의 후 사용
- View는 바로 만들지 않고, Presentation > Common에 있는지 검사 후 있는 경우 재사용
    - 없는 경우에만 제작
- Font 사이즈, radius, Padding, Animation 등은 ViewStyle에 정의된 문서를 확인 후 있는 경우 재사용
    - 없는 경우에만 직접 사용
    
---

## 9. 에러 처리

- 에러가 발생한 경우 AppLogger의 log() 사용해서 log를 표시한다.
| 이름 | 사용 기준 |
|------|----------|
| `Network` | `네트워크 통신` |
| `Core` | `앱 코어(중요) 로직` |
| `View` | `VC, ViewModel 로직` |
| `Coordinator` | `코디네이터 로직` |
| `LiveActivity` | `LiveActivity 로직` |
| `CoreData` | `CoreData 로직` |
