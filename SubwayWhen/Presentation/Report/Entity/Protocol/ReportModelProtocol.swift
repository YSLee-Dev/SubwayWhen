//
//  ReportModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/27.
//

import Foundation

import RxSwift

protocol ReportModelProtocol{
    func lineListData() -> Observable<[String]>
    func oneStepQuestionData() -> Observable<[ReportTableViewCellSection]>
    func twoStepQuestionData() -> ReportTableViewCellSection
    func twoStepSideException(_ data:ReportBrandData) -> ReportTableViewCellData?
    func theeStepQuestion() -> ReportTableViewCellSection
    func cellDataMatching(index: IndexPath, matchIndex : IndexPath, data : String) -> String?
    func cellDataSave(nowData : [ReportTableViewCellSection], data : String ,index : IndexPath) -> [ReportTableViewCellSection]
}
