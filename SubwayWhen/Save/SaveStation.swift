//
//  SaveStation.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/29.
//

import Foundation

struct SaveStation : Codable{
    let id : String
    let stationName : String
    let stationCode : String
    let updnLine : String
    let line : String
    let lineCode : String
    var group : SaveStationGroup
    let exceptionLastStation : String
    var korailCode : String
    
    var useLine: String{
        let zeroCut = self.line.replacingOccurrences(of: "0", with: "")
        
        if zeroCut.count < 4 {
            return String(zeroCut[zeroCut.startIndex ..< zeroCut.index(zeroCut.startIndex, offsetBy: zeroCut.count)])
        }else{
            return String(zeroCut[zeroCut.startIndex ..< zeroCut.index(zeroCut.startIndex, offsetBy: 4)])
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
