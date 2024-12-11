//
//  SearchStaion.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import Foundation

struct SearchStaion : Decodable {
    let SearchInfoBySubwayNameService : SearchInfoBySubwayNameService
}

struct SearchInfoBySubwayNameService : Decodable{
    let row : [searchStationInfo]
}

struct searchStationInfo : Decodable, Equatable{
    let stationName : String
    let lineNumber : line
    let stationCode : String
    
    enum CodingKeys : String, CodingKey{
        case stationName = "STATION_NM"
        case lineNumber = "LINE_NUM"
        case stationCode = "FR_CODE"
    }
    
    enum line : String, Decodable{
        case one = "01호선"
        case two = "02호선"
        case three = "03호선"
        case four = "04호선"
        case five = "05호선"
        case six = "06호선"
        case seven = "07호선"
        case eight = "08호선"
        case nine = "09호선"
        case gyeonggang = "경강선"
        case gyeongui = "경의선"
        case airport = "공항철도"
        case gyeongchun = "경춘선"
        case seohae = "서해선"
        case suinbundang = "수인분당선"
        case shinbundang = "신분당선"
        case gimpo = "김포도시철도"
        case sillim = "신림선"
        case yongin = "용인경전철"
        case ui = "우이신설경전철"
        case uijeingbu = "의정부경전철"
        case incheon1 = "인천선"
        case incheon2 = "인천2호선"
        case gtxA = "GTX-A"
        case not = "not"
    }
    
    var useLine : String{
        switch lineNumber {
        case .one:
            return "1호선"
        case .two:
            return "2호선"
        case .three:
            return "3호선"
        case .four:
            return "4호선"
        case .five:
            return "5호선"
        case .six:
            return "6호선"
        case .seven:
            return "7호선"
        case .eight:
            return "8호선"
        case .nine:
            return "9호선"
        case .gyeonggang:
            return "경강"
        case .gyeongui:
            return "경의중앙"
        case .airport:
            return "공항"
        case .gyeongchun:
            return "경춘"
        case .seohae:
            return "서해"
        case .suinbundang:
            return "수인분당"
        case .shinbundang:
            return "신분당"
        case .gimpo:
            return "김포"
        case .sillim:
            return "신림"
        case .yongin:
            return "용인"
        case .ui:
            return "우이"
        case .uijeingbu:
            return "의정부"
        case .incheon1:
            return "인천1"
        case .incheon2:
            return "인천2"
        case .gtxA:
            return "GTX-A"
        case .not:
            return "NOT"
        }
    }
    
    var lineCode : String{
        switch lineNumber {
        case .one:
            return "1001"
        case .two:
            return "1002"
        case .three:
            return "1003"
        case .four:
            return "1004"
        case .five:
            return "1005"
        case .six:
            return "1006"
        case .seven:
            return "1007"
        case .eight:
            return "1008"
        case .nine:
            return "1009"
        case .gyeongui:
            return "1063"
        case .airport:
            return "1065"
        case .gyeongchun:
            return "1067"
        case .suinbundang:
            return "1075"
        case .shinbundang:
            return "1077"
        case .ui:
            return "1092"
        case .gtxA:
            return "1032"
        case .seohae:
            return "1093"
        case .gyeonggang:
            return "1081"
        default :
            return ""
        }
    }
    
    // 부역명 필수 지하철역
    var useStationName : String{
        switch self.stationName{
        case "쌍용":
            return "쌍용(나사렛대)"
        case "총신대입구":
            return "총신대입구(이수)"
        case "신정":
            return "신정(은행정)"
        case "오목교":
            return "오목교(목동운동장앞)"
        case "군자":
            return "군자(능동)"
        case "아차산":
            return "아차산(어린이대공원후문)"
        case "광나루":
            return "광나루(장신대)"
        case "천호":
            return "천호(풍납토성)"
        case "굽은다리":
            return "굽은다리(강동구민회관앞)"
        case "새절":
            return "새절(신사)"
        case "증산":
            return "증산(명지대앞)"
        case "월드컵경기장":
            return "월드컵경기장(성산)"
        case "대흥":
            return "대흥(서강대앞)"
        case "안암":
            return "안암(고대병원앞)"
        case "월곡":
            return "월곡(동덕여대)"
        case "상월곡":
            return "상월곡(한국과학기술연구원)"
        case "화랑대":
            return "화랑대(서울여대입구)"
        case "공릉":
            return "공릉(서울산업대입구)"
        case "어린이대공원":
            return "어린이대공원(세종대)"
        case "이수":
            return "총신대입구(이수)"
        case "숭실대입구":
            return "숭실대입구(살피재)"
        case "몽촌토성":
            return "몽촌토성(평화의문)"
        case "남한산성입구":
            return "남한산성입구(성남법원, 검찰청)"
        default:
            return self.stationName
        }
    }
}
