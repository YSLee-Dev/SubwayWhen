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
        Observable<[String]>.just([
            ReportBrandData.not.rawValue,
            ReportBrandData.one.rawValue,
            ReportBrandData.two.rawValue,
            ReportBrandData.three.rawValue,
            ReportBrandData.four.rawValue,
            ReportBrandData.five.rawValue,
            ReportBrandData.six.rawValue,
            ReportBrandData.seven.rawValue,
            ReportBrandData.eight.rawValue,
            ReportBrandData.nine.rawValue,
            ReportBrandData.gyeongui.rawValue,
            ReportBrandData.airport.rawValue,
            ReportBrandData.gyeongchun.rawValue,
            ReportBrandData.suinbundang.rawValue,
            ReportBrandData.shinbundang.rawValue,
        ])
    }
    
    func oneStepQuestionData() -> Observable<[ReportTableViewCellSection]>{
        Observable<[ReportTableViewCellSection]>.just([ReportTableViewCellSection(sectionName: "민원 호선", items: [.init(cellTitle: "몇호선 민원을 접수하시겠어요?", cellData: "", type: .Line, focus: false)])])
    }
    
    func twoStepQuestionData() -> ReportTableViewCellSection{
        ReportTableViewCellSection(sectionName: "호선 정보", items: [
            .init(cellTitle: "열차의 행선지를 입력해주세요.", cellData: "", type: .TextField, focus: true),
            .init(cellTitle: "현재 역을 입력해주세요.", cellData: "", type: .TextField, focus: false)
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
            .init(cellTitle: "칸 위치나 열차번호를 입력해주세요.", cellData: "", type: .TextField, focus: true)])
    }
    
    func cellDataMatching(index: IndexPath, matchingIndex : IndexPath, data : String) -> String?{
        if index.section == matchingIndex.section, index.row == matchingIndex.row{
            return data
        }else{
            return nil
        }
    }
    
    func cellDataSave(nowData : [ReportTableViewCellSection], data : String ,index : IndexPath) -> [ReportTableViewCellSection]{
        
        var changeData = nowData
        changeData[index.section].items[index.row].cellData = data
        changeData[index.section].items[index.row].focus = false
        
        return changeData
    }
}
