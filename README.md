# 지하철 민실씨 (SubwayWhen)

<img src="https://user-images.githubusercontent.com/94354145/228749712-667ce825-2134-4a94-ab3b-2887843f9fa8.png" height="150" />

> 지하철 민원 & 실시간 위치 & 시간표를 한눈에 보여주는 '지하철 민실씨'<br/>
> V1.0 개발기간: 2022.11.29 ~ 2023.03.30<br/>
> V1.1 개발기간: 2023.04.18 ~ 2023.05.25<br/>
> v1.2 개발기간: 2023.06.20 ~ 2023.07.12<br/>
> v1.3 개발기간: 2023.09.18 ~ 2023.10.11<br/>
> v1.3.1 개발기간: 2024.01.09 ~ 2024.03.07<br/>
> v1.4 개발기간: 2024.03.28 ~ 2024.04.30<br/>
> v1.5 개발기간: 2024.08.26 ~ 2024.09.30<br/>
 
## 📋 지하철 민실씨 소개, 기능
<div align=left>
<img src="https://github.com/YSLee-Dev/SubwayWhen/assets/94354145/ed1d2dfc-9a21-4923-b312-e726387b206b.png" height="350" />
<img src="https://github.com/YSLee-Dev/SubwayWhen/assets/94354145/c25f2cc5-0530-40c1-859a-848626946f6a.png" height="350" />
<img src="https://github.com/YSLee-Dev/SubwayWhen/assets/94354145/1613caae-15ad-42b7-9271-6b2e51dd3d4b.png" height="350" />
<img src="https://github.com/YSLee-Dev/SubwayWhen/assets/94354145/f809acc6-8e18-4b8b-b697-4ce480fc22ce.png" height="350" />
 <br>
 
<img src="https://github.com/YSLee-Dev/SubwayWhen/assets/94354145/ed1d2dfc-9a21-4923-b312-e726387b206b.png" height="350" />
<img src="https://github.com/YSLee-Dev/SubwayWhen/assets/94354145/3a846c53-6a71-42e0-881a-c2d6080c4e4d.png" height="350" />
<img src="https://github.com/YSLee-Dev/SubwayWhen/assets/94354145/348270e5-752f-4c8b-aab8-b561878a9048" height="350" />
<img src="https://github.com/YSLee-Dev/SubwayWhen/assets/94354145/3c80ea6a-348c-41dc-8131-fe99a3cd30c8.png" height="350" />
</div>

<br/>

> 지하철 민실씨는 지하철 민원 접수부터 실시간 도착 정보, 시간표 정보까지 '한눈에, 빠르고 편하게' 확인할 수 있는 앱입니다.
-	민원 호선을 선택 후 간단한 정보만 입력하면 민원을 편하게 접수할 수 있습니다.
-	지하철역을 검색 후 저장하면, 내가 원하는 역만 보거나 중간 종착 열차를 빼고 볼 수 있습니다.
-	실시간 도착 정보와 시간표 정보를 비교하여 사용자의 판단을 돕습니다.
-	출근과 퇴근 그룹으로 나누어 저장하여, 내 출퇴근 탑승 역만 볼 수 있습니다.
-	출퇴근 그룹에 시간을 매핑하여 원하는 시간대에 원하는 그룹을 볼 수 있고, 알림도 받을 수 있습니다. (알림은 v1.2부터 사용 가능)
-	Live Activity, 위젯 기능으로 홈/잠금화면에서도 지하철 시간표를 확인할 수 있습니다. (Live Activity: v1.1부터 사용 가능, 위젯: v1.4부터 사용 가능)
- 주변에 있는 지하철을 바로 확인하고 검색할 수 있습니다. (v1.2부터 사용 가능)

<br/>

## 🗓️ 지하철 민실씨의 스토리보드
- 민실씨의 스토리보드는 <a href = "https://carnelian-gateway-8a5.notion.site/465f44b6767546789c458d3ddfed0579">노션에서 관리</a>하고 있습니다.

<br/>

## 🛠 지하철 민실씨에 사용된 라이브러리 / 프레임워크
- UIKit, SwiftUI, WidgetKit, ActivityKit
- RxSwift, RxCocoa, RxDataSources, RxOptional, RxAlamofire, TCA(ComposableArchitecture)
- Alamofire, Then, SnapKit, lottie-ios, AcknowList, Firebase/Analytics, Firebase/Database
- Nimble, RxBlocking, RxTest

<br/>

## 💡 지하철 민실씨에 사용된 아키텍쳐
### ✅ MVVM-C + input/output 패턴 (일부 미적용)
### 🔄 TCA(ComposableArchitecture) (일부 적용)
<img src="https://github.com/user-attachments/assets/eb09e82c-111a-481f-8c56-c0b7a2aac090" height="400" />

> MVVM 
- View(VC)는 View를 그리는데 집중하고, ViewModel과 Model가 데이터 처리를 하도록 분리하였습니다.
- 데이터 처리 로직이 분리됨에 따라 ViewModel, Model을 각각 테스트 할 수 있었습니다.
``` 
- ViewModel은 VC에서 전달된 데이터를 Model을 통해 가공하여, Observable형태로 VC에 전달하는 역할을 수행합니다.
- Model은 ViewModel이 전달해준 데이터를 바탕으로 네트워크 통신 및 데이터를 가공 후 다시 ViewModel에 
돌려주는 역할을 수행합니다.
``` 
> Coordinator
- UINavigationController를 이용한 화면전환을 Coordinator를 사용하도록 분리하였습니다.
- Present를 이용한 화면전환도 Coordinator를 사용하도록 리팩토링 중입니다. (v1.2~)
- VC와 ViewModel간의 의존성 주입을 Coordinator에서 진행하였습니다.
``` 
- 민실씨의 AppCoordinator은 TabbarController의 선언도 같이하게 설계하였습니다.
- 민실씨의 경우 앱의 첫 화면부터 Tabbar가 존재하기 때문에 AppCoordinator와 TabbarCoordinator를 분리하는게 
비효율적이라 생각이 들어 AppCoordinator가 TabbarController도 선언하도록 하였습니다.
``` 
> Singleton
- Live Activity, UNUserNotificationCenter, CoreData를 관리하는 Manager를 싱글톤 객체로 생성하여 관리하였습니다.
``` 
- UIKit에서 Live Activity를 사용하기 위해 Manager을 두 개의 Target에서 빌드되도록 했습니다.
- Manager 객체는 유일성 위해 싱글톤으로 생성하고, 만든 인스턴스를 static으로 선언하여
어디서든 접근할 수 있게 하였습니다.
```
> TCA (ComposableArchitecture)
- 단방향 데이터 흐름을 통해 데이터 출처를 명확하게 하고, 다양한 Effects(Action)로 State와 Error를 처리하게 하였습니다.
- UIKit + MVVM-C로 개발된 화면을 리팩토링 중입니다. (v1.5 ~ )
```
- 비동기 작업 중 화면을 나간 경우 .cancel()을 통해 즉시 작업이 중단되도록 설계했습니다.
- TCA의 Dependency 관리는 Networking 프레임워크에서 진행하게 설계했습니다.
이에 따라 각 프레임워크에서 TCA를 사용할 수 있게 Common 프레임워크를 제작 후 Target Dependencies를
채택하여 사용할 수 있게 했습니다.
``` 
<br/>

## 🔗 지하철 민실씨 다운로드 링크
- https://apps.apple.com/us/app/지하철-민실씨/id6446166573
