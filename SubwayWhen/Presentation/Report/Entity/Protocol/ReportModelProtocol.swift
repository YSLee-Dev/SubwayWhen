//
//  ReportModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/27.
//

import Foundation

protocol ReportModelProtocol{
    func lineListData() -> [String]
    func oneStepQuestionData() -> [ReportTableViewCellSection]
    func twoStepQuestionData() -> ReportTableViewCellSection
    func twoStepSideException(_ data:ReportBrandData) -> ReportTableViewCellData?
    func theeStepQuestion() -> ReportTableViewCellSection
    func cellDataSave(nowData : [ReportTableViewCellSection], index : IndexPath, isFocus : Bool)
}
