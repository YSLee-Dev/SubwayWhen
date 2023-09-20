//
//  DetailVCDelegate.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import Foundation

protocol DetailVCDelegate{
    func scheduleTap(schduleResultData : schduleResultData)
    func pop()
    func disappear()
    func exceptionLastStationPopup(station: String)
}
