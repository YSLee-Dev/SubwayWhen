---
name: test-style
description: 테스트 컨벤션을 정의한 문서
---

## 테스트 명령어

```bash
# 전체 테스트
xcodebuild test -workspace SubwayWhen.xcworkspace -scheme SubwayWhen -destination 'platform=iOS Simulator,name=iPhone 16'

# 단일 클래스
xcodebuild test ... -only-testing:SubwayWhenTests/CongestionModalFeatureTests

# 단일 메서드
xcodebuild test ... -only-testing:SubwayWhenTests/CongestionModalFeatureTests/testModalInit
```

---

## 1. 네이밍

- 클래스명: `{Name}FeatureTests` (TCA), `{Name}ModelTests` / `{Name}ViewModelTests` (MVVM-C)
- 메서드명: `func test_{시나리오}`

```swift
func testModalInit()
func testStationBtnTapped()
func testSearchStationToResultVCSectionError()   // 에러 케이스는 Error 접미사
```

---

## 2. TCA Feature 테스트 구조

```swift
class XxxFeatureTests: XCTestCase {

    // MARK: - Properties
    
    var mockManager: TestXxxManager!

    // MARK: - LifeCycle
    
    override func setUp() {
        self.mockManager = TestXxxManager()
        self.mockManager.someData = dummyData       // 테스트 데이터 주입
        FixInfo.saveSetting.someProperty = value    // 전역 상태 초기화 (필요 시)
    }

    // MARK: - Tests
    
    func testSomething() async throws {
        // GIVEN
        let testStore = await self.createStore()

        // WHEN
        await testStore.send(.someAction) { state in
            // THEN
            state.someProperty = expectedValue
        }

        // THEN (파생 effect 검증)
        await testStore.receive(.derivedAction) { state in
            state.anotherProperty = anotherValue
        }
    }
}

// MARK: - Methods

private extension XxxFeatureTests {
    func createStore() async -> TestStoreOf<XxxFeature> {
        let store = await TestStore(
            initialState: XxxFeature.State(),
            reducer: { XxxFeature() },
            withDependencies: { dependency in
                dependency.xxxManager = self.mockManager
            }
        )
        store.exhaustivity = .off(showSkippedAssertions: false)
        return store
    }
}
```

**규칙:**
- `createStore()`는 `private extension`에 분리
- `exhaustivity = .off(showSkippedAssertions: false)` 기본 설정
- `send()` 클로저에서 state 변화 검증, `receive()`로 파생 액션 검증
- `#if DEBUG` 헬퍼 프로퍼티 접근 시 `$0.testXXX` 형태 사용

---

## 3. MVVM-C 테스트 구조

```swift
class XxxModelTests: XCTestCase {
    var model: XxxModelProtocol!
    var errorModel: XxxModelProtocol!           // 에러 케이스 전용 모델

    override func setUp() {
        let mock = MockURLSession((response: urlResponse!, data: dummyData))
        self.model = XxxModel(model: TotalLoadModel(
            loadModel: LoadModel(networkManager: NetworkManager(session: mock))
        ))

        self.errorModel = XxxModel(model: TotalLoadModel(
            loadModel: LoadModel(networkManager: NetworkManager(session: MockURLSession(
                (response: urlResponse!, data: errorData)
            )))
        ))
    }

    func testSomething() {
        // GIVEN
        let result = self.model.someRequest("교대").toBlocking()
        let arrayData = try! result.toArray().first!

        // WHEN
        let value = arrayData.someProperty

        // THEN
        expect(value).to(equal(expectedValue), description: "설명")
        expect(arrayData.count).to(equal(dummyCount), description: "count 검증")
    }

    func testSomethingError() {
        // GIVEN
        let result = self.errorModel.someRequest("교대").toBlocking()
        let arrayData = try! result.toArray().first

        // THEN
        expect(arrayData).to(beNil(), description: "에러 시 nil 반환")
    }
}
```

**규칙:**
- assertion은 Nimble `expect(...).to(...)` 사용 — `XCTAssert` 직접 사용 금지
- `description:` 파라미터로 실패 메시지 명시
- 에러 케이스는 별도 `errorModel`로 분리하여 테스트
- `RxBlocking` — `.toBlocking().toArray().first!`로 동기 변환

---

## 4. 테스트 더블 작성

```swift
// Test{Name} — TCA 의존성용
final class TestXxxManager: XxxManagerProtocol {
    var someData: DataType!          // 테스트에서 주입할 데이터

    func fetchData() -> DataType {
        return self.someData
    }
}

// Mock{Name} — URLSession / LoadModel 등 네트워킹용
final class MockURLSession: URLSessionProtocol {
    // 고정 응답 반환
}
```

**규칙:**
- TCA 의존성 더블: `Test{Name}` 접두사, 프로토콜 채택, 데이터 주입용 `var` 프로퍼티 공개
- 네트워킹 더블: `Mock{Name}` 접두사
- 위치: `SubwayWhenTests/Mock/Manager/`

---

## 5. 더미 데이터

- JSON 픽스처: `SubwayWhenTests/Dummy/DummyData/*.json`
- Swift 더미 팩토리: `DummyData.swift`, `DummyLoad.swift`
- 새 JSON이 필요할 경우 `DummyData/` 폴더에 추가 후 `DummyLoad.swift`에서 로딩

---

## 6. GIVEN / WHEN / THEN 주석

모든 테스트에 GIVEN / WHEN / THEN 주석 필수. 여러 단계가 있으면 반복 사용:

```swift
// GIVEN
let testStore = await self.createStore()

// WHEN
await testStore.send(.buttonTapped)

// THEN
await testStore.receive(.dataLoaded) { state in
    state.items = expectedItems
}

// WHEN (2번째 인터랙션)
await testStore.send(.refreshTapped)

// THEN
await testStore.receive(.dataLoaded)
```
