# 지하철 민실씨 (SubwayWhen)

<img src="https://user-images.githubusercontent.com/94354145/228749712-667ce825-2134-4a94-ab3b-2887843f9fa8.png" height="150" />

> 지하철 민원 & 실시간 위치 & 시간표를 한눈에 보여주는 '지하철 민실씨'<br/>
> V1.0 개발기간: 2022.11.29 ~ 2023.03.30<br/>
> V1.1 개발기간: 2023.04.18 ~ 2023.05.25
 
<br/>
 
## 📋 지하철 민실씨 소개, 기능
<div align=left>
<img src="https://user-images.githubusercontent.com/94354145/228754681-6bcc47df-66d2-4fb1-bc3b-d83473901ef9.png" height="350" />
<img src="https://user-images.githubusercontent.com/94354145/228755344-1950519e-a5b2-44d3-888a-d9f2fc335965.png" height="350" />
<img src="https://user-images.githubusercontent.com/94354145/228755347-377ce4c6-db40-4cc8-9518-d235d469a2de.png" height="350" />
<img src="https://user-images.githubusercontent.com/94354145/228755359-a7fe579e-5a94-43d9-ae14-af934c4968f6.png" height="350" />
<img src="https://user-images.githubusercontent.com/94354145/228755378-da3b22ed-f62f-493e-94d4-f888fb2c6ff5.png" height="350" />
</div>

<br/>

> 지하철 민실씨는 지하철 민원 접수부터 실시간 도착 정보, 시간표 정보까지 '한눈에, 빠르고 편하게' 확인할 수 있는 앱입니다.
-	민원 호선을 선택 후 간단한 정보만 입력하면 민원을 편하게 접수할 수 있습니다.
-	지하철역을 검색 후 저장하면, 내가 원하는 역만 보거나 중간 종착 열차를 빼고 볼 수 있습니다.
-	실시간 도착 정보와 시간표 정보를 비교하여 사용자의 판단을 돕습니다.
-	출근과 퇴근 그룹으로 나누어 저장하여, 내 출퇴근 탑승 역만 볼 수 있습니다.
-	출퇴근 그룹에 시간을 매핑하여 원하는 시간대에 원하는 그룹을 볼 수 있습니다.
-	Live Activity 기능으로 잠금화면에서도 지하철 시간표를 확인할 수 있습니다. (v1.1부터 사용 가능)

<br/>

## 🗓️ 지하철 민실씨의 스토리보드
- 민실씨의 스토리보드는 <a href = "https://carnelian-gateway-8a5.notion.site/465f44b6767546789c458d3ddfed0579">노션에서 관리</a>하고 있습니다.

<br/>

## 🛠 지하철 민실씨에 사용된 라이브러리
- RxSwift, RxCocoa, RxDataSources, RxOptional, RxAlamofire
- Alamofire, Then, SnapKit, lottie-ios, AcknowList, Firebase/Analytics, Firebase/Database
- Nimble, RxBlocking, RxTest

<br/>

## 💡 지하철 민실씨에 사용된 아키텍쳐
### ✅ MVVM-C
<img src="https://user-images.githubusercontent.com/94354145/228791125-092fef3e-fed0-4aa3-9a3e-90003c48757b.png" height="350" />

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
- VC와 ViewModel간의 의존성 주입을 Coordinator에서 진행하였습니다.
``` 
- 민실씨의 AppCoordinator은 TabbarController의 선언도 같이하게 설계하였습니다.
- 민실씨의 경우 앱의 첫 화면부터 Tabbar가 존재하기 때문에 AppCoordinator와 TabbarCoordinator를 분리하는게 
비효율적이라 생각이 들어 AppCoordinator가 TabbarController도 선언하도록 하였습니다.
``` 
> Singleton
- Live Activity를 관리하는 Manager를 싱글톤 객체로 생성하여 관리하였습니다.
``` 
- UIKit에서 Live Activity를 사용하기 위해 Manager을 두 개의 Target에서 빌드되도록 했습니다.
- Manager 객체는 유일성 위해 싱글톤으로 생성하고, 만든 인스턴스를 static으로 선언하여
어디서든 접근할 수 있게 하였습니다.
``` 
<br/>

## 🔗 지하철 민실씨 다운로드 링크
- https://apps.apple.com/us/app/지하철-민실씨/id6446166573
