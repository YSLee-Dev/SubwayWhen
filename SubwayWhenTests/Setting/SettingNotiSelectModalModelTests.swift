//
//  SettingNotiSelectModalModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/07/11.
//

import Foundation

import XCTest

import RxBlocking
import RxSwift
import Nimble

@testable import SubwayWhen

class SettingNotiSelectModalModelTests: XCTestCase {
    var model: SettingNotiSelectModalModelProtocol!
    
    override func setUp() {
        self.model = SettingNotiSelectModalModel()
    }
    
    func testSaveStationToSectionData() {
        // GIVEN
        var saveStationData = SaveStation(
            id: "1", stationName: "강남", stationCode: "339", updnLine: "상행", line: "02호선", lineCode: "1002", group: .one, exceptionLastStation: "", korailCode: ""
        )
        
        let saveStationDataList = [saveStationData, arrivalGyodaeStation3Line, arrivalGyodaeStation3Line]
        
        let data = self.model.saveStationToSectionData(
            data: saveStationDataList, id: "1"
        )
        let blocking = data.asObservable().toBlocking()
        let requestData = try! blocking.toArray().first
        
        // WHEN
        let requestSectionCount = requestData?.count
        let dummySectionCount = 1
        
        let reuqestStationName = requestData?.first?.items.map {$0.stationName}
        let dummyStationName = saveStationDataList.map {$0.stationName}
        
        let requestCheckCell = requestData?.first?.items.map {$0.isChecked}
        let dummyCheckCell = [true, false, false]
        
        // THEN
        expect(requestSectionCount).to(
            equal(dummySectionCount),
            description: "세션은 하나만 존재해야함"
        )
        
        expect(reuqestStationName).to(
            equal(dummyStationName),
            description: "역 이름 및 순서는 동일해야함"
        )
        
        expect(requestCheckCell).to(
            equal(dummyCheckCell),
            description: "파라미터로 넣은 ID의 Cell Data만 True가 되어야 함"
        )
        
    }
}
