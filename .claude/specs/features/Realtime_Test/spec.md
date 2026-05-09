# Realtime_Test

## 무엇을 하는가
새로 추가된 Realtime와 관련된 로직 테스트 케이스 작성 및 테스트 실행

## 동작 명세
- 트리거: XCTest 실행
- 결과: 테스트 함수 실행에 따른 성공/실패
- 사이드이펙트: 테스트 함수마다 다름
- 불변 조건: 테스트 결과는 성공/실패 중 하나는 무조건 리턴 해야함

## 무엇이 잘못될 수 있는가
- 테스트 함수 조건마다 다름

## 무엇에 의존하는가
### 의존성
- XCTest: 테스트
- ComposableArchitecture: TCA

### 테스트 해야하는 파일
- TotalLoadModel
- LoadModel
- RealtimeFeature
- RealtimeCoordinator
- 기타 파일

### 제약
- rules, CLADUE.md에 맞춰서 테스트 케이스 작성 및 테스트 

## Acceptance Criteria
- [x] RealtimeFeatureTests 12개 케이스 전체 통과
- [x] TotalLoadModelTests — realtimePositionLoad 상행/하행/제외역/에러, stationIdList 2호선 구간분리 포함 전체 통과
- [x] LoadModelTests — testRealtimePositionRequest, testRealtimePositionRequestError 포함 전체 통과
- [x] MockRealtimeVCDelegate 생성 및 coordinatorDelegate 검증 완료
