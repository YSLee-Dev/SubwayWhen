//
//  DetailVCDelegate.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import Foundation

protocol DetailVCDelegate: AnyObject {
    func scheduleTap(schduleResultData : ([ResultSchdule], DetailSendModel))
    func pop()
    func disappear()
}
