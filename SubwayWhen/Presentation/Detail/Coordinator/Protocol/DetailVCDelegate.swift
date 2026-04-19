//
//  DetailVCDelegate.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import Foundation

protocol DetailVCDelegate: AnyObject {
    func scheduleTap(schduleResultData : ([ResultSchdule], DetailSendModel))
    func reportBtnTap(reportLine: SubwayLineData, stationName: String)
    func pushRealtime(subwayLine: SubwayLineData, stationName: String, upDown: String, exceptionLastStation: String)
    func pop()
    func disappear()
}
