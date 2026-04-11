//
//  Strings.swift
//  SubwayWhen
//
//  Created by 이윤수 on 7/18/25.
//

import Foundation

struct Strings {
    struct Common{}
    struct Report {}
    struct Setting {}
    struct Main {}
    struct Realtime {}
}

extension Strings.Common {
    /// 상행
    static let up = "상행"
    /// 하행
    static let down = "하행"
    /// 네
    static let yes = "네"
    /// 아니오
    static let no = "아니오"
    /// 취소
    static let cancel = "취소"
    /// 확인
    static let check = "확인"
    /// 저장하기
    static let save = "저장"
    /// 시
    static let hour = "시"
    /// 닫기
    static let close = "닫기"
}

extension Strings.Report {
    /// 지하철 민원
    static let title = "지하철 민원"
    
    /// 민원 호선
    static let oneStepTitle = "민원 호선"
    /// 몇호선 민원을 접수하시겠어요?
    static let oneStepQuestion = "몇호선 민원을 접수하시겠어요?"
    
    /// 호선 정보
    static let twoStepTitle = "호선 정보"
    /// 열차의 행선지를 입력해주세요. (행)
    static let twoStepQuestion1 = "열차의 행선지를 입력해주세요. (행)"
    /// 현재 역을 입력해주세요. (역)
    static let twoStepQuestion2 = "현재 역을 입력해주세요. (역)"
    /// 현재 역이 청량리 ~ 서울역 안에 있나요?
    static let twoStepQuestion3_1 = "현재 역이 청량리 ~ 서울역 안에 있나요?"
    /// 현재 역이 대화 ~ 지축 안에 있나요?
    static let twoStepQuestion3_2 = "현재 역이 대화 ~ 지축 안에 있나요?"
    /// 현재 역이 선바위 ~ 오이도 안에 있나요?
    static let twoStepQuestion3_3 = "현재 역이 선바위 ~ 오이도 안에 있나요?"
    
    /// 상세 정보
    static let threeStepTitle = "상세 정보"
    /// 고유(열차)번호를 입력해주세요.
    static let threeStepQuestion1 = "고유(열차)번호를 입력해주세요."
    /// 고유번호를 확인할 수 없어요.
    static let canNotThreeStep = "고유번호를 확인할 수 없어요."
    
    /// 고유번호가 없으면 민원 처리가 원활하지 않을 수 있어요.\n고유번호는 각 객차 끝 부분에 숫자로 적혀있어요.
    static let threeStepPassAlert = "고유번호가 없으면 민원 처리가 원활하지 않을 수 있어요.\n고유번호는 각 객차 끝 부분에 숫자로 적혀있어요."
    /// 입력하기
    static let threeStepPassAlertNo = "입력하기"
    /// 입력하지 않고 진행하기
    static let threeStepPassAlertYes = "입력하지 않고 진행하기"
    
    /// 민원 정보
    static let fourStepTitle = "민원 정보"
    /// 민원내용을 선택하거나 입력해주세요.
    static let fourStepQuestion = "민원내용을 선택하거나 입력해주세요."
    
    /// 차내 더움
    static let fourStepOptionTitle1 = "차내 더움"
    /// 차내 추움
    static let fourStepOptionTitle2 = "차내 추움"
    /// 폭력 사건
    static let fourStepOptionTitle3 = "차내 잡상인"
    /// 차내 전도
    static let fourStepOptionTitle4 = "차내 전도"
    /// 차내 취객
    static let fourStepOptionTitle5 = "차내 취객"
    /// 지연 심각
    static let fourStepOptionTitle6 = "지연 심각"
    /// 내용 직접 입력
    static let fourStepOptionTitle7 = "내용 직접 입력"
    
    /// 차내가 덥습니다. 에어컨 조절 부탁드립니다.
    static let fourStepOptionSub1 = "차내가 덥습니다. 에어컨 조절 부탁드립니다."
    /// 차내가 춥습니다. 난방 조절 부탁드립니다.
    static let fourStepOptionSub2 = "차내가 춥습니다. 난방 조절 부탁드립니다."
    /// 차내에서 잡상인이 물건을 팔고 있습니다.
    static let fourStepOptionSub3 = "차내에서 잡상인이 물건을 팔고 있습니다."
    /// 차내에서 전도를 하는 사람이 있습니다.
    static let fourStepOptionSub4 = "차내에서 전도를 하는 사람이 있습니다."
    /// 차내에 취객이 있어 고성방가를 하고 있습니다.
    static let fourStepOptionSub5 = "차내에 취객이 있어 고성방가를 하고 있습니다."
    /// 열차 지연이 심각합니다. 정시운행 부탁드립니다.
    static let fourStepOptionSub6 = "열차 지연이 심각합니다. 정시운행 부탁드립니다."
    
    /// 입력되지 않은 값이 있어 민원을 접수할 수 없어요.\n열차 고유번호를 제외한 모든 질문에는 답변을 해주세요.
    static let cannotReportAlertTitle = "입력되지 않은 값이 있어 민원을 접수할 수 없어요.\n열차 고유번호를 제외한 모든 질문에는 답변을 해주세요."
}

extension Strings.Setting {
    /// 설정
    static let setting = "설정"
    
    /// 출근
    static let workTime = "출근"
    /// 퇴근
    static let leaveTime = "퇴근"
    
    /// 홈 화면
    static let homeScreen = "홈 화면"
    /// 혼잡도 이모지
    static let trafficLightEmoji = "혼잡도 이모지"
    /// 출퇴근 지하철역
    static let workAlarm = "출퇴근 지하철역"
    /// 한 글자만 입력할 수 있어요.
    static let emojiLimit = "한 글자만 입력할 수 있어요."
    
    /// 검색 화면
    static let searchScreen = "검색 화면"
    /// 중복 저장 방지
    static let duplicatePrevention = "중복 저장 방지"
    
    /// 상세 화면
    static let detailScreen = "상세 화면"
    /// 자동 새로 고침
    static let autoRefresh = "자동 새로 고침"
    /// 시간표 자동 정렬
    static let autoSortTimeTable = "시간표 자동 정렬"
    /// Live Activity
    static let liveActivity = "Live Activity"
    /// 열차 아이콘
    static let trainIcon = "열차 아이콘"
    
    /// 상세화면의 열차 아이콘을 변경하는 기능이에요.
    static let trainIconDescription = "상세화면의 열차 아이콘을 변경하는 기능이에요."
    /// 현재역
    static let currentStation = "현재역"
    /// 전역
    static let backStation = "전역"
    
    /// 오픈 라이선스
    static let openLicense = "오픈 라이선스"
    /// 기타
    static let other = "기타"
}

extension Strings.Main {
    /// 홈
    static let title = "홈"
    /// 현재 지하철 예상 혼잡도
    static let currentTraffic = "현재 지하철 예상 혼잡도"
    /// 중요 알림
    static let importantAlarm = "중요 알림"
    /// 편집
    static let edit = "편집"
    /// 실시간 현황
    static let liveStatus = "실시간 현황"
    /// 🔄 당겨서 새로고침
    static let refresh = "🔄 당겨서 새로고침"
    
    /// 오늘 하루도\n좋은 하루 보내세요.
    static let defaultMessage = "오늘 하루도\n좋은 하루 보내세요."
    
    /// 주말 멘트
    static let weekendMessages = [
        "행복하고 즐거운 주말\n좋은 하루 보내세요!",
        "행복한 일만 가득한 주말\n행복한 주말 보내세요!",
        "여유로운 주말\n재충전하는 시간 되세요!"
    ]
    
    /// 월요일 멘트
    static let mondayMessages = [
        "월요일,\n한 주도 화이팅해봐요!",
        "월요일이지만\n좋은 일만 가득하길!",
        "월요일,\n오늘도 멋진 하루 만들어봐요!"
    ]
    
    /// 화요일 멘트 목록
    static let tuesdayMessages = [
        "화요일,\n평범하지만 행복한 날로 만들어봐요!",
        "화요일,\n어제보다 한 걸음 더!",
        "화요일,\n오늘도 잘 하고 있어요!",
    ]
    
    /// 수요일 멘트 목록
    static let wednesdayMessages = [
        "수요일,\n수많은 즐거움이 가득할거에요!",
        "수요일,\n벌써 반이나 왔어요!",
    ]
    
    /// 목요일 멘트 목록
    static let thursdayMessages = [
        "목요일,\n거의 다 왔어요, 조금만 더!",
        "목요일,\n내일이면 금요일이에요!",
    ]
    
    /// 금요일 멘트 목록
    static let fridayMessages = [
        "금요일,\n행복한 하루 보내세요!",
        "금요일,\n즐거운 주말이 기다려요!"
    ]
    
    /// 데이터를 로드하고 있어요.
    static let dataLoading = "데이터를 로드하고 있어요."
    /// 행
    static let bound = "행"
    /// 정보 없음
    static let notAvailable = "정보 없음"
    
    /// 버튼을 눌러서 지하철 역을 추가할 수 있어요!
    static let emptyBtnMessage = "버튼을 눌러서 지하철 역을 추가할 수 있어요!"
    /// 시간표 로드 중
    static let timetableLoding = "시간표 로드 중"
    /// 민원 접수
    static let reportIssue = "민원 접수"
    
    /// 선택된 지하철역의 예상 혼잡도를 확인할 수 있어요.
    static let congestionModalSubTitle = "선택된 지하철역의 예상 혼잡도를 확인할 수 있어요."
}

extension Strings.Realtime {
    /// 오류
    static let bundleErrorTitle = "오류"
    /// 역 정보를 불러오지 못했어요.\n잠시 후 다시 시도해주세요.
    static let bundleErrorMessage = "역 정보를 불러오지 못했어요.\n잠시 후 다시 시도해주세요."
}
