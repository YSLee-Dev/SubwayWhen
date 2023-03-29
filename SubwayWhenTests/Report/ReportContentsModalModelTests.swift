//
//  ReportContentsModalModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/27.
//

import XCTest

import RxSwift
import RxBlocking
import Nimble

@testable import SubwayWhen

final class ReportContentsModalModelTests: XCTestCase {
    var model : ReportContentsModalModelProtocol!

    override func setUp() {
        self.model = ReportContentsModalModel()
    }
    
    func testReportList(){
        // GIVEN
        let data = self.model.reportList()
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray().first
        
        // WHEN
        let requestCount = arrayData?.first?.items.count
        let duumyCount = 9
        
        let requestFirst = arrayData?.first?.items.first?.contents
        let dummyFirst = "차내가 덥습니다. 에어컨 조절 요청드립니다."
        
        // THEN
        expect(requestCount).to(
            equal(duumyCount),
            description: "count는 9으로 같아야함"
        )
        
        expect(requestFirst).to(
            equal(dummyFirst),
            description: "데이터가 동일하기 때문에 첫 번째 데이터의 값도 동일해야함"
        )
    }
    
}
