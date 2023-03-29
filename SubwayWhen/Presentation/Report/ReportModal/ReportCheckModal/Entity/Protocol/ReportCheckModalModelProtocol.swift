//
//  ReportCheckModalModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/27.
//

import Foundation

protocol ReportCheckModalModelProtocol{
    func createMsg(data : ReportMSGData) -> String
    func numberMatching(data : ReportMSGData) -> String
}
