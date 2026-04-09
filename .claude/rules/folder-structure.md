---
name: folder-structure
description: 프로젝트 폴더 구조 규칙을 정의한 문서
---

## 타겟 구성

```
SubwayWhen/                    # 메인 앱 타겟 (UIKit + SwiftUI)
SubwayWhenTests/               # 테스트 타겟
SubwayWhenDetailWidget/        # ActivityKit 익스텐션
SubwayWhenHomeWidget/ # WidgetKit 익스텐션
SubwayWhenNetworking/          # 네트워킹 프레임워크
```

---

## SubwayWhen/ (메인 앱)

```
SubwayWhen/
├── Application/               # 앱 초기화, 생명주기
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── Coordinator/ # 앱 코디네이터
│   └── Sub/                   # 앱 레벨 공통 유틸
│
├── Configuration/             # 전역 상태, 앱 설정 엔티티
│   ├── FixInfo.swift          # 전역 상태 (saveStation, saveSetting)
│   ├── AppConfig.swift
│   └── Entity/
│
├── Service/                   # TCA 의존성 구현체
│   ├── Dependency+.swift      # DependencyValues 등록
│   ├── Congestion/
│   │   ├── Entity/Protocol/
│   │   └── TCADependency/
│   ├── Location/
│   │   ├── LocationManager.swift
│   │   ├── Entity/
│   │   └── TCADependency/
│   └── Notification/
│       ├── Entitly/        
│       └── TCADependency/
│
├── Presentation/              # UI 레이어 (화면별 폴더)
│   ├── Common/                # 재사용 공통 컴포넌트
│   │   ├── UIKit/
│   │   └── SwiftUI/
│   ├── Main/
│   ├── Search/
│   ├── Detail/
│   ├── Edit/
│   ├── Setting/
│   ├── Report/
│   ├── Tutorial/
│   ├── NoNetwork/
│   └── Popup/
│
├── Util/                      # 유틸리티, 익스텐션
│   ├── Extension/
│   └── Logger/
│
└── Resource/                  # 리소스 파일
    ├── Assets.xcassets/
    ├── Json/
    ├── Lottie/
    └── Strings.swift
```

---

## Presentation/ 화면 폴더 구조

### TCA 화면 (신규 화면 기준)

```
Presentation/{FeatureName}/
├── {Name}Feature.swift            # TCA Reducer
├── {Name}View.swift               # SwiftUI 루트 뷰
├── Coordinator/
│   └── Protocol/
├── Sub/                           # 서브 SwiftUI 뷰 (50줄 초과 시 분리)
└── Entity/                        # 해당 Feature 전용 모델
    └── Protocol/
```

### MVVM-C 화면 (레거시 유지보수 기준)

```
Presentation/{FeatureName}/
├── {Name}VC.swift                 # UIViewController
├── {Name}ViewModel.swift
├── {Name}Model.swift
├── Coordinator/
│   └── Protocol/
├── Sub/                           # UITableViewCell, 서브 뷰 등
└── Entity/
    └── Protocol/
```

### 중첩 기능 (Modal / SubFeature)

화면 내 별도 Modal이나 하위 기능은 부모 폴더 아래에 중첩:

```
Presentation/Setting/
├── SettingVC.swift
├── ...
├── SettingNotiModal/              # 알림 설정 모달
│   ├── Coordinator/
│   ├── Entitly/
│   └── SettingNotiSelectModal/    # 2단계 중첩 허용
│       └── ...
```

---

## SubwayWhenNetworking/ (네트워킹 프레임워크)

```
SubwayWhenNetworking/
├── DataLoad/
│   ├── NetworkManager.swift       # URLSession 래퍼
│   ├── LoadModel.swift            # 서울/코레일 API 호출
│   ├── TotalLoadModel.swift       # 데이터 조합 오케스트레이터
│   ├── Entity/                    # 도메인별 데이터 모델
│   │   └── Protocol/              # 네트워킹 추상화 프로토콜
│   └── LoadModel/
│
├── TCADependecy/                  # TCA 의존성 키 및 구현체
│   ├── TotalLoadTCADependency.swift       # 프로덕션
│   ├── PreviewTotalLoadTCADependency.swift # SwiftUI Preview
│   ├── TestTotalLoadTCADepdency.swift     # 테스트 더블
│   └── Key/
│
└── CoreData/                      # 신분당선 시간표 캐시
```

---

## 파일 배치 규칙

1. **공통 컴포넌트**인가?
   - UIKit → `Presentation/Common/UIKit/`
   - SwiftUI → `Presentation/Common/SwiftUI/`

2. **특정 화면 전용**인가?
   - 해당 화면 폴더(`Presentation/{Name}/`) 아래에 위치
   - 재사용 가능성 있으면 `Sub/` 폴더

3. **네트워크 엔티티(DTO)**인가?
   - `SubwayWhenNetworking/DataLoad/Entity/{Domain}/` 아래에 위치

4. **TCA 의존성**인가?
   - 서비스 구현체 → `SubwayWhen/Service/{ServiceName}/`
   - 의존성 키 등록 → `SubwayWhen/Service/Dependency+.swift`

5. **테스트 더블**인가?
   - Manager Mock → `SubwayWhenTests/Mock/Manager/`
   - JSON 픽스처 → `SubwayWhenTests/Dummy/DummyData/`

6. **유틸리티 / 익스텐션**인가?
   - `SubwayWhen/Util/Extension/{Type}+.swift`

### 프로토콜 파일 위치

프로토콜은 구현체와 같은 폴더의 `Protocol/` 서브폴더에 위치:

```
Service/Congestion/
├── CongestionManager.swift       # 구현체
├── Entity/
│   └── Protocol/
│       └── CongestionManagerProtocol.swift   # 프로토콜
└── TCADependency/
```

### Entity 폴더 vs Configuration/Entity

| 위치 | 기준 |
|------|------|
| `Configuration/Entity/` | 앱 전역에서 사용하는 핵심 모델 (`SaveStation`, `SaveSetting`) |
| `Presentation/{Name}/Entity/` | 특정 화면에서만 사용하는 UI 모델 |
| `SubwayWhenNetworking/Entity/` | 네트워크 응답 DTO |

---

## Resource/ 파일 배치 규칙

| 파일 종류 | 위치 |
|----------|------|
| 이미지, 아이콘, 앱 컬러 | `Assets.xcassets/` |
| 노선 색상 | `Assets.xcassets/` — 한국어 노선명 키 (`"02호선"`) |
| Lottie 애니메이션 | `Resource/Lottie/` |
| 로컬 JSON 데이터 | `Resource/Json/` |
| 문자열 상수 | `Resource/Strings.swift` (또는 해당 Feature Extension) |
| CoreData 모델 | `SubwayWhenNetworking/CoreData/` |
| 번들 plist | `SubwayWhenNetworking/DataLoad/` (`DetailStationIdList.plist`) |
