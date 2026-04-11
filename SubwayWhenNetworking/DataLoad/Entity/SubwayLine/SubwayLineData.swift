//
//  SubwayLineData.swift
//  SubwayWhenNetworking
//
//  Created by 이윤수 on 12/5/24.
//

import Foundation

enum SubwayLineData : String, Decodable, Equatable, CaseIterable {
    case one = "01호선"
    case two = "02호선"
    case three = "03호선"
    case four = "04호선"
    case five = "05호선"
    case six = "06호선"
    case seven = "07호선"
    case eight = "08호선"
    case nine = "09호선"
    case gyeongui = "경의선"
    case seohae = "서해선"
    case suinbundang = "수인분당선"
    case shinbundang = "신분당선"
    case gyeonggang = "경강선"
    case gyeongchun = "경춘선"
    case airport = "공항철도"
    case gimpo = "김포도시철도"
    case sillim = "신림선"
    case yongin = "용인경전철"
    case ui = "우이신설경전철"
    case uijeingbu = "의정부경전철"
    case incheon1 = "인천선"
    case incheon2 = "인천2호선"
    case gtxA = "GTX-A"
    case not = "not"
    
    init(subwayId: String) {
        switch subwayId {
        case "1001": self = .one
        case "1002": self = .two
        case "1003" : self = .three
        case "1004": self = .four
        case "1005": self = .five
        case "1006": self = .six
        case "1007": self = .seven
        case "1008": self = .eight
        case "1009": self = .nine
        case "1063": self = .gyeongui
        case "1065": self = .airport
        case "1067": self =  .gyeongchun
        case "1075": self = .suinbundang
        case "1077": self = .shinbundang
        case "1092": self = .ui
        case "1032": self = .gtxA
        case "1093": self =  .seohae
        case "1081": self = .gyeonggang
        case "1094": self = .sillim
        default: self = .not
        }
    }
    
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
        case .sillim:
            return "1094"
        default :
            return ""
        }
    }
    
    var realtimeLineName: String {
        switch self {
        case .one:          return "1호선"
        case .two:          return "2호선"
        case .three:        return "3호선"
        case .four:         return "4호선"
        case .five:         return "5호선"
        case .six:          return "6호선"
        case .seven:        return "7호선"
        case .eight:        return "8호선"
        case .nine:         return "9호선"
        case .gyeongui:     return "경의중앙선"
        case .airport:      return "공항철도"
        case .gyeongchun:   return "경춘선"
        case .suinbundang:  return "수인분당선"
        case .shinbundang:  return "신분당선"
        case .ui:           return "우이신설선"
        case .gtxA:         return "GTX-A"
        default:            return ""
        }
    }

    var allowScheduleLoad: Bool {
        return !( self == .airport  || self == .ui || self == .not  || self == .gyeonggang || self == .seohae || self == .gtxA || self == .sillim )
    }
    
    var allowReport: Bool {
        return !(self == .ui || self == .gtxA || self == .seohae || self == .sillim || self == .gimpo || self == .yongin || self == .uijeingbu || self == .incheon1 || self == .incheon2 || self == .not)
    }
    
    var hasTwoOperators: Bool {
        return self == .one || self == .three || self == .four
    }
}
