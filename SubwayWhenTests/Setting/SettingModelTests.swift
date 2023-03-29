//
//  SettingModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/29.
//

import XCTest

import RxSwift
import RxBlocking
import Nimble

@testable import SubwayWhen

class SettingModelTests : XCTestCase{
    var model : SettingModelProtocol!
    
    override func setUp() {
        self.model = SettingModel()
    }
    
    func testCreateSettingList(){
        // GIVEN
        let data = self.model.createSettingList()
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestCount = arrayData.first?.count
        let dummyCount = 4
        
        let lastSettingTitle = arrayData.first?.last?.items.last?.settingTitle
        let dummySettingTitle = "기타"
        
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "세션의 count는 4개로 같아야함"
        )
        
        expect(lastSettingTitle).to(
            equal(dummySettingTitle),
            description: "마지막 title은 (기타)가 나와야함"
        )
    }
    
    func testIndexMaching(){
        // GIVEN
        let index = IndexPath(row: 1, section: 1)
        let matchIndex = IndexPath(row: 1, section: 1)
        let info = "INFO"
        let su =  1
        
        let data = self.model.indexMatching(index: index, matchIndex: matchIndex, data: info)
        let dataSu = self.model.indexMatching(index: index, matchIndex: matchIndex, data: su)
        
        // WHEN
        let requestData = data
        let dummyData = info
        
        let requestSuData = dataSu
        let dummySuData = su
        
        // THEN
        expect(requestData).to(
            equal(dummyData),
            description: "Index가 같으므로, 값이 나와야함"
        )
        
        expect(requestSuData).to(
            equal(dummySuData),
            description: "Index가 같으므로, 값이 나와야함"
        )
    }
    
    func testIndexMachingError(){
        // GIVEN
        let index = IndexPath(row: 1, section: 1)
        let matchIndex = IndexPath(row: 0, section: 1)
        let double = 0.0
        
        let data = self.model.indexMatching(index: index, matchIndex: matchIndex, data: double)
        
        // WHEN
        let requestData = data
        
        // THEN
        expect(requestData).to(
            beNil(),
            description: "Index가 다르므로, nil이 나와야함"
        )
    }
}
