//
//  SubwayLineData.swift
//  SubwayWhenNetworking
//
//  Created by 이윤수 on 12/5/24.
//

import Foundation

enum SubwayLineData : String, Equatable {
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
    
    var useLine: String{
        switch self {
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
    var lineCode: String{
        switch self {
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
}
