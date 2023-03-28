//
//  ModalModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/28.
//

import XCTest

import RxSwift
import RxBlocking
import Nimble

@testable import SubwayWhen

class ModalModelTests : XCTestCase{
    var model : ModalModelProtocol!
    
    override func setUp() {
        self.model = ModalModel()
    }
    
    func testUseLineToKorailCode(){
        // GIVEN
        let requestLineOne = self.model.useLineTokorailCode("경의중앙")
        let requestLineTwo = self.model.useLineTokorailCode("신분당")
        let requestLineThree = self.model.useLineTokorailCode("01호선")
        
        // WHEN
        let dummyLineOne = "K4"
        let dummyLineTwo = "D1"
        let dummyLineThree = ""
        
        // THEN
        expect(requestLineOne).to(
            equal(dummyLineOne),
            description: "경의중앙선은 K4가 나와야함"
        )
        
        expect(requestLineTwo).to(
            equal(dummyLineTwo),
            description: "신분당선은 D1이 나와야함"
        )
        
        expect(dummyLineThree).to(
            equal(requestLineThree),
            description: "보기에 없을 경우 공백을 리턴해야함"
        )
    }
    
    func testUpdownFix(){
        // GIVEN
        let requestOne = self.model.updownFix(updown: false, line: "2호선")
        let requestTwo = self.model.updownFix(updown: true, line: "2호선")
        let requestThree = self.model.updownFix(updown: true, line: "3호선")
        
        // WHEN
        let dummyOne = "외선"
        let dummyTwo = "내선"
        let dummyThree = "상행"
        
        // THEN
        expect(requestOne).to(
            equal(dummyOne),
            description: "2호선에 updown이 false이면 외선이 나와야함"
        )
        
        expect(requestTwo).to(
            equal(dummyTwo),
            description: "2호선에 updown이 true이면 내선이 나와야함"
        )
        
        expect(requestThree).to(
            equal(dummyThree),
            description: "2호선이 아닌경우 updown이 true이면 상행이 나와야함"
        )
    }
}
