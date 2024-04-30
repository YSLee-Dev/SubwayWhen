//
//  ReportModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/27.
//

import XCTest

import RxSwift
import RxCocoa
import RxBlocking
import Nimble

@testable import SubwayWhen

final class ReportModelTests: XCTestCase {
    var model : ReportModelProtocol!
    
    override func setUp() {
        self.model = ReportModel()
    }
    
    func testLineListData(){
        // GIVEN
        let data = model.lineListData()
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestCount = arrayData.first?.count
        let dummyCount = 15
        
        let requestLastLine = arrayData.first?.last
        let dummyLastLine = "경강선"
        
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "count는 14개로 고정되어 있어야함"
        )
        
        expect(requestLastLine).to(
            equal(dummyLastLine),
            description: "모든 데이터는 동일해야함"
        )
    }
    
    func testOneQuestionData(){
        // GIVEN
        let data = self.model.oneStepQuestionData()
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestItemCount = arrayData.first?.first?.items.count
        let dummyItemCount = 1
        
        let requestSectionName = arrayData.first?.first?.sectionName
        let dummySectionName = "민원 호선"
        
        let requestItemType = arrayData.first?.first?.items.first?.type
        let dummyItemType = ReportTableViewCellType.Line
        
        // THEN
        expect(requestItemCount).to(
            equal(dummyItemCount),
            description: "count는 1개로 고정되어 있어야함"
        )
        
        expect(requestSectionName).to(
            equal(dummySectionName),
            description: "모든 데이터는 동일해야함"
        )
        
        expect(requestItemType).to(
            equal(dummyItemType),
            description: "타입은 동일해야함"
        )
    }
    
    func testTwoStepQuestionData(){
        // GIVEN
        let data = self.model.twoStepQuestionData()
        
        // WHEN
        let requestItemCount = data.items.count
        let dummyItemCount = 2
        
        let requestSectionName = data.sectionName
        let dummySectionName = "호선 정보"
        
        let requestFirstFocus = data.items.first?.focus
        let dummyFirstFocus = true
        
        // THEN
        expect(requestItemCount).to(
            equal(dummyItemCount),
            description: "count는 2개로 고정되어 있어야함"
        )
        
        expect(requestSectionName).to(
            equal(dummySectionName),
            description: "모든 데이터는 동일해야함"
        )
        
        expect(requestFirstFocus).to(
            equal(dummyFirstFocus),
            description: "첫 번째 값의 포커스는 True여야함"
        )
    }
    
    func testStepSideException(){
        // GIVEN
        let reportData = ReportBrandData.three
        let data = self.model.twoStepSideException(reportData)
        
        // WHEN
        let requestType = data?.type
        let dummyType = ReportTableViewCellType.TwoBtn
        
        let requestCellTitle = data?.cellTitle
        let dummyCellTitle = "현재 역이 지축 ~ 대화 안에 있나요?"
        
        // THEN
        expect(requestType).to(
            equal(dummyType),
            description: "타입은 TwoBtn으로 고정되어 있어야함"
        )
        
        expect(requestCellTitle).to(
            equal(dummyCellTitle),
            description: "3호선으로 두었을 때는 지축 ~ 대화 메세지가 나와야함"
        )
    }
    
    func testStepSideExceptionError(){
        // GIVEN
        let reportData = ReportBrandData.airport
        let data = self.model.twoStepSideException(reportData)
        
        // WHEN
        let requestType = data?.type
        
        let requestCellTitle = data?.cellTitle
        
        // THEN
        expect(requestType).to(
            beNil(),
            description: "1,3,4호선이 아니면 nil이 나와야함"
        )
        
        expect(requestCellTitle).to(
            beNil(),
            description: "1,3,4호선이 아니면 nil이 나와야함"
        )
    }
    
    func testThreeStepQuestion(){
        // GIVEN
        let data = self.model.theeStepQuestion()
        
        // WHEN
        let requestItemCount = data.items.count
        let dummyItemCount = 1
        
        let requestSectionName = data.sectionName
        let dummySectionName = "상세 정보"
        
        let requestFirstFocus = data.items.first?.focus
        let dummyFirstFocus = true
        
        // THEN
        expect(requestItemCount).to(
            equal(dummyItemCount),
            description: "count는 1개로 고정되어 있어야함"
        )
        
        expect(requestSectionName).to(
            equal(dummySectionName),
            description: "모든 데이터는 동일해야함"
        )
        
        expect(requestFirstFocus).to(
            equal(dummyFirstFocus),
            description: "첫 번째 값의 포커스는 True여야함"
        )
    }
    
    func testCellDataMatching(){
        // GIVEN
        let index = IndexPath(row: 1, section: 1)
        let matchIndex = IndexPath(row: 1, section: 1)
        let info = "INFO"
        
        let data = self.model.cellDataMatching(index: index, matchIndex: matchIndex, data: info)
        
        // WHEN
        let requestData = data
        let dummyData = info
        
        // THEN
        expect(requestData).to(
            equal(dummyData),
            description: "Index가 같으므로, 값이 나와야함"
        )
    }
    
    func testCellDataMatchingError(){
        // GIVEN
        let index = IndexPath(row: 0, section: 1)
        let matchIndex = IndexPath(row: 1, section: 1)
        let info = "INFO"
        
        let data = self.model.cellDataMatching(index: index, matchIndex: matchIndex, data: info)
        
        // WHEN
        let requestData = data
        
        // THEN
        expect(requestData).to(
            beNil(),
            description: "Index가 다르면, nil이 나와야함"
        )
    }
    
    func testCellDataSave(){
        let nowData : [ReportTableViewCellSection] = [
            .init(sectionName: "정보", items: [
                .init(cellTitle: "타이틀", cellData: "셀정보", type: .TextField, focus: true),
                .init(cellTitle: "타이틀2", cellData: "셀정보2", type: .TextField, focus: false)
            ]),
            .init(sectionName: "정보2", items: [
                .init(cellTitle: "타이틀3", cellData: "타이틀3", type: .TwoBtn, focus: true)
            ])
        ]
        
        let index = IndexPath(row: 0, section: 1)
        let info = "SAVEDATA"
        let data = self.model.cellDataSave(nowData: nowData, data: info, index: index)
        
        // WHEN
        let requestCellData = data[index.section].items[index.row].cellData
        let dummyCellData = info
        
        let requestCellFocus = data[index.section].items[index.row].focus
        let dummyCellFocus = false
        
        let requestCellTitle = data[index.section].items[index.row].cellTitle
        let dummyCellTitle = "타이틀3"
        
        // THEN
        expect(requestCellData).to(
            equal(dummyCellData),
            description: "indexPath에 맞게 데이터가 변경되어야함"
        )
        
        expect(requestCellFocus).to(
            equal(dummyCellFocus),
            description: "포커스는 false가 되어야함"
        )
        
        expect(requestCellTitle).to(
            equal(dummyCellTitle),
            description: "포커스, 데이터 이외의 값은 변경되면 안됨"
        )
    }
    
    func testCellDataSaveError(){
        let nowData : [ReportTableViewCellSection] = [
            .init(sectionName: "정보", items: [
                .init(cellTitle: "타이틀", cellData: "셀정보", type: .TextField, focus: true),
                .init(cellTitle: "타이틀2", cellData: "셀정보2", type: .TextField, focus: false)
            ]),
            .init(sectionName: "정보2", items: [
                .init(cellTitle: "타이틀3", cellData: "타이틀3", type: .TwoBtn, focus: true)
            ])
        ]
        
        let index = IndexPath(row: 2, section: 1)
        let info = "SAVEDATA"
        let data = self.model.cellDataSave(nowData: nowData, data: info, index: index)
        
        // WHEN
        expect(data).toNot(
            beNil(),
            description: "Index값을 넘어도 앱이 크레쉬 나지 않아야함"
        )
    }
    
}
