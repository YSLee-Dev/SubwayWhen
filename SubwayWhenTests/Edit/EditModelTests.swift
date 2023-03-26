//
//  EditModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/26.
//

import XCTest

import RxSwift
import RxBlocking
import Nimble

@testable import SubwayWhen

final class EditModelTests: XCTestCase {
    var model : EditModelProtocol!
    var saveStation : [SaveStation] = []
    
    override func setUp(){
        self.model = EditModel()
        self.saveStation.append(contentsOf: [
            .init(id: "1", stationName: "1", stationCode: "1", updnLine: "상행", line: "1", lineCode: "1", group: .one, exceptionLastStation: "1", korailCode: "1"),
            .init(id: "2", stationName: "2", stationCode: "2", updnLine: "상행", line: "2", lineCode: "2", group: .one, exceptionLastStation: "2", korailCode: "2"),
            .init(id: "3", stationName: "3", stationCode: "3", updnLine: "상행", line: "3", lineCode: "3", group: .two, exceptionLastStation: "3", korailCode: "3")
        ])
    }
    
    func testFixDataToGroupData(){
        // GIVEN
        let data = self.model.fixDataToGroupData(self.saveStation)
        let blocking = data.asObservable().toBlocking()
        let arrayData = try! blocking.toArray()
        let requestData = arrayData.first!
        
        // WHEN
        let requestGroupCount = requestData.count
        let dummyGroupCount = 2
        
        let requestGroupOneCount = requestData.filter{
            $0.sectionName == "출근"
            }
            .map{
                $0.items.count
            }
            .first
            
        let dummyGroupOneCount = 2
        
        let requestGroupTwoStationName = requestData[1].items.map{
                $0.stationName
            }
            .first
        let dummyGroupTwoStationName = "3"
        
        // THEN
        expect(requestGroupCount).to(
            equal(dummyGroupCount),
            description: "그룹은 총 2개여야함"
        )
        
        expect(requestGroupOneCount).to(
            equal(dummyGroupOneCount),
            description: "출근 그룹에는 데이터가 2개 있어야함"
        )
        
        expect(requestGroupTwoStationName).to(
            equal(dummyGroupTwoStationName),
            description: "그룹은 분리되도 기존 값은 변하면 안됨"
        )
    }
    
    func testFixDataToGroupDataError(){
        // GIVEN
        let data = self.model.fixDataToGroupData([])
        let blocking = data.asObservable().toBlocking()
        let arrayData = try! blocking.toArray()
        let requestData = arrayData.first!
        
        // WHEN
        let requestGroupCount = requestData.count
        let dummyGroupCount = 2
        
        let requestGroupOneCount = requestData.filter{
            $0.sectionName == "출근"
            }
            .map{
                $0.items.count
            }
            .first
            
        let dummyGroupOneCount = 0
        
        // THEN
        expect(requestGroupCount).to(
            equal(dummyGroupCount),
            description: "그룹은 총 2개여야함"
        )
        
        expect(requestGroupOneCount).to(
            equal(dummyGroupOneCount),
            description: "데이터가 없으면 빈배열이 나와야함"
        )
    }
}
