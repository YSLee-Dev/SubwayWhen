//
//  ReportCheckModalModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/27.
//

import Foundation

class ReportCheckModalModel : ReportCheckModalModelProtocol{
    func createMsg(nowHour : Int, nowMinute : Int, data : ReportMSGData) -> String{
                       """
                    호선: \(data.line.rawValue)
                    행선지: \(data.destination)
                    열차위치: \(data.trainCar)
                    현재위치: (\(nowHour)시 \(nowMinute)분) \(data.nowStation)
                    \(data.contants)
                    """
    }
    
    func numberMatching(data : ReportMSGData) -> String{
        if data.line == .two || data.line == .five || data.line == .six || data.line == .seven || data.line == .eight || (data.line == .one && data.brand == "Y") || (data.line == .three && data.brand == "N") || (data.line == .four && data.brand == "N"){
            // 서울교통공사
            return "1577-1234"
        }else if data.line == .nine{
            // 9호선
            return "1544-4009"
        }else if data.line == .shinbundang{
            // 신분당선
            return "031-8018-7777"
        }else if data.line == .gyeongui || data.line == .gyeongchun || data.line == .airport || data.line == .suinbundang || (data.line == .one && data.brand == "N") || (data.line == .three && data.brand == "Y") || (data.line == .four && data.brand == "Y"){
            // 코레일
            return "1544-7769"
        }else {
            return ""
        }
    }
}
