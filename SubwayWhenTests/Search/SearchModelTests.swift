//
//  SearchModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/28.
//

import XCTest

import RxSwift
import RxBlocking
import Nimble

@testable import SubwayWhen
@testable import SubwayWhenNetworking

//class SearchModelTests : XCTestCase{
//    var model : SearchModelProtocol!
//    var errorModel : SearchModelProtocol!
//    
//    override func setUp() {
//        let mock = MockURLSession((response: urlResponse!, data: stationNameSearchData))
//        self.model = SearchModel(model: TotalLoadModel(loadModel: LoadModel(networkManager: NetworkManager(session: mock))))
//        
//        self.errorModel = SearchModel(model:  TotalLoadModel(loadModel: LoadModel(networkManager: NetworkManager(session: MockURLSession(((response: urlResponse!, data: arrivalErrorData)))))))
//    }
//    
//    func testSearchStationToResultVCSection(){
//        // GIVEN
//        let searchData = self.model.stationNameSearchRequest("교대")
//        let blocking = searchData.toBlocking()
//        let arrayData = try! blocking.toArray().first!
//        
//        let data = self.model.searchStationToResultVCSection(arrayData)
//        
//        // WHEN
//        let reuqestStationName = data.first?.items.first?.stationName
//        let dummyStationName = stationNameSearcDummyhData.SearchInfoBySubwayNameService.row.first?.stationName
//        
//        let requestLineNumber = data.first?.items.first?.lineNumber
//        let dummyStationLineNumber = stationNameSearcDummyhData.SearchInfoBySubwayNameService.row.first?.lineNumber.rawValue
//        
//        let requestCount = data.count
//        let dummyCount = stationNameSearcDummyhData.SearchInfoBySubwayNameService.row.count
//        
//        // THEN
//        expect(reuqestStationName).to(
//            equal(dummyStationName),
//            description: "ResultVCSection로 변경되도 값은 동일해야함"
//        )
//        
//        expect(requestLineNumber).to(
//            equal(dummyStationLineNumber),
//            description: "ResultVCSection로 변경되도 값은 동일해야함"
//        )
//        
//        expect(requestCount).to(
//            equal(dummyCount),
//            description: "데이터가 동일하기 때문에 count도 동일해야함"
//        )
//    }
//    
//    func testSearchStationToResultVCSectionError(){
//        // GIVEN
//        let searchData = self.errorModel.stationNameSearchRequest("교대")
//        let blocking = searchData.toBlocking()
//        let arrayData = try! blocking.toArray().first ?? SearchStaion(SearchInfoBySubwayNameService: SearchInfoBySubwayNameService(row: []))
//        
//        let data = self.errorModel.searchStationToResultVCSection(arrayData)
//        
//        // WHEN
//        let reuqestStationName = data.first?.items.first?.stationName
//        
//        let requestLineNumber = data.first?.items.first?.lineNumber
//        
//        let requestCount = data.count
//        let dummyCount = 0
//        
//        // THEN
//        expect(reuqestStationName).to(
//            beNil(),
//            description: "데이터가 없으면 nil이 나와야함"
//        )
//        
//        expect(requestLineNumber).to(
//            beNil(),
//            description: "데이터가 없으면 nil이 나와야함"
//        )
//        
//        expect(requestCount).to(
//            equal(dummyCount),
//            description: "데이터가 없으면 count는 0이 나와야함"
//        )
//    }
//}
