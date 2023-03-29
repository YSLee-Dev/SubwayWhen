//
//  ReportCheckModalModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/27.
//

import XCTest

import RxSwift
import RxBlocking
import Nimble

@testable import SubwayWhen

final class ReportCheckModalModelTests: XCTestCase {
    var model : ReportCheckModalModelProtocol!
    var msgData : ReportMSGData!
    
    override func setUp() {
        self.model = ReportCheckModalModel()
        self.msgData = ReportMSGData(line: .one, nowStation: "시청", destination: "인천", trainCar: "1-4", contants: "너무 더워요.", brand: "Y")
    }
    
    func testCreateMsg(){
        // GIVEN
        let data = self.model.createMsg(data: self.msgData)
        
        // WHEN
        let requestData = data
        let dummyData =  """
                    \(self.msgData.line.rawValue) \(self.msgData.destination)행 \(self.msgData.trainCar)
                    현재 \(self.msgData.nowStation)역
                    \(self.msgData.contants)
                    """
        
        // THEN
        expect(requestData).to(
            equal(dummyData),
            description: "같은 데이터이기 때문에 값이 같아야함"
        )
    }
    
    func testNumberMatching(){
        // GIVEN
        let threeMSGData = ReportMSGData(line: .three, nowStation: "", destination: "", trainCar: "", contants: "", brand: "Y")
        let sevenMSGData = ReportMSGData(line: .seven, nowStation: "", destination: "", trainCar: "", contants: "", brand: "N")
        let shinMSGData = ReportMSGData(line: .shinbundang, nowStation: "", destination: "", trainCar: "", contants: "", brand: "N")
        let gyeonguiMSGData = ReportMSGData(line: .gyeongui, nowStation: "", destination: "", trainCar: "", contants: "", brand: "N")
        
        let oneData = self.model.numberMatching(data: self.msgData)
        let threeData = self.model.numberMatching(data: threeMSGData)
        let sevenData = self.model.numberMatching(data: sevenMSGData)
        let shinData = self.model.numberMatching(data: shinMSGData)
        let gyeonguiData = self.model.numberMatching(data: gyeonguiMSGData)
        
        // WHEN
        let requestNumber = oneData
        let dummyData = "1577-1234"
        
        let requestThreeNumber = threeData
        let dummyThreeData = "1544-7769"
        
        let requestSevenNumber = sevenData
        let dummySevenData = "1577-1234"
        
        let requestShinNumber = shinData
        let dummyShinData = "031-8018-7777"
        
        let requestGyeonguiNumber = gyeonguiData
        let dummyGyeonguiData = "1544-7769"
        
        // THEN
        expect(requestNumber).to(
            equal(dummyData),
            description: "1호선이지만, brand가 Y이기 때문에 서울교통공사 연락처가 나와야함"
        )
        
        expect(requestThreeNumber).to(
            equal(dummyThreeData),
            description: "3호선이지만, brand가 Y이기 때문에 코레일 연락처가 나와야함"
        )
        
        expect(requestSevenNumber).to(
            equal(dummySevenData),
            description: "7호선이면 서울교통공사 연락처가 나와야함"
        )
        
        expect(requestShinNumber).to(
            equal(dummyShinData),
            description: "신분당선이면, 신분당선 연락처가 나와야함"
        )
        
        expect(requestGyeonguiNumber).to(
            equal(dummyGyeonguiData),
            description: "경의중앙선이면 코레일 연락처가 나와야함"
        )
    }
    
    func testNumberMatchingError(){
        // GIVEN
        let msgData = ReportMSGData(line: .not, nowStation: "", destination: "", trainCar: "", contants: "", brand: "N")
        let data = self.model.numberMatching(data: msgData)
        
        // WHEN
        let requestNumber = data
        let dummyData = ""
        
        // THEN
        expect(requestNumber).to(
            equal(dummyData),
            description: "노선이 없으면 공백이 나와야함"
        )
    }
}
