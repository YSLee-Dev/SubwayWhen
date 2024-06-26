//
//  ReportModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/27.
//

import Foundation
import RxSwift

class ReportModel : ReportModelProtocol {
    func lineListData() -> Observable<[String]>{
        Observable<[String]>.just(
            ReportBrandData.allCases.map {$0.rawValue}
        )
    }
    
    func oneStepQuestionData() -> Observable<[ReportTableViewCellSection]>{
        Observable<[ReportTableViewCellSection]>.just([ReportTableViewCellSection(sectionName: "민원 호선", items: [.init(cellTitle: "몇호선 민원을 접수하시겠어요?", cellData: "", type: .Line, focus: false)])])
    }
    
    func twoStepQuestionData() -> ReportTableViewCellSection{
        ReportTableViewCellSection(sectionName: "호선 정보", items: [
            .init(cellTitle: "열차의 행선지를 입력해주세요. (행)", cellData: "", type: .TextField, focus: true),
            .init(cellTitle: "현재 역을 입력해주세요. (역)", cellData: "", type: .TextField, focus: false)
        ])
    }
    
    func twoStepSideException(_ data:ReportBrandData) -> ReportTableViewCellData?{
        if data == ReportBrandData.one {
            return .init(cellTitle: "현재 역이 청량리 ~ 서울역 안에 있나요?", cellData: "", type: .TwoBtn, focus: false)
        }else if data == ReportBrandData.three{
            return .init(cellTitle: "현재 역이 지축 ~ 대화 안에 있나요?", cellData: "", type: .TwoBtn, focus: false)
        }else if data == ReportBrandData.four{
            return .init(cellTitle: "현재 역이 오이도 ~ 선바위 안에 있나요?", cellData: "", type: .TwoBtn, focus: false)
        }else{
            return nil
        }
    }
    
    func theeStepQuestion() -> ReportTableViewCellSection{
        ReportTableViewCellSection(sectionName: "상세 정보", items: [
            .init(cellTitle: "고유(열차)번호를 입력해주세요.", cellData: "", type: .TextField, focus: true)])
    }
    
    func cellDataMatching(index: IndexPath, matchIndex : IndexPath, data : String) -> String?{
        if index.section == matchIndex.section,
            index.row == matchIndex.row{
            return data
        }else{
            return nil
        }
    }
    
    func cellDataSave(nowData : [ReportTableViewCellSection], data : String ,index : IndexPath) -> [ReportTableViewCellSection]{
        var changeData = nowData
        
        if nowData.count > index.section{
            if nowData[index.section].items.count > index.row{
                changeData[index.section].items[index.row].cellData = data
                changeData[index.section].items[index.row].focus = false
            }
        }
        
        return changeData
    }
}
