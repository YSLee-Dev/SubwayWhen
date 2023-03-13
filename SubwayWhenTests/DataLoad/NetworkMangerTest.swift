//
//  NetworkMangerTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/01.
//

import XCTest

import RxSwift
import RxTest
import RxBlocking
import RxOptional
import Nimble

@testable import SubwayWhen

class NetworkMangerTests : XCTestCase{
    let bag = DisposeBag()
    
    override func setUp() {
    }
    
    func testNetworkManger(){
        // GIVEN
        let url = "Test.url"
        guard let urlResponse = HTTPURLResponse(url: URL(string: url)!,
                                          statusCode: 200,
                                          httpVersion: nil,
                                          headerFields: nil)
        else {return}
        
        
        let mockURL = MockURLSession((response: urlResponse, data: arrivalData))
        let mockNetworkManger = NetworkManager(session: mockURL)
        
        // WHEN
        let requestData = mockNetworkManger.requestData(url, dataType: LiveStationModel.self)
        
        let value = requestData
            .map{ data -> LiveStationModel? in
                guard case let .success(value) = data else {return nil}
                return value
            }
            .map{$0!}
            .asObservable()
        
        let blocking = value.toBlocking()
        let arrayValue = try! blocking.toArray()
        
        // THEN (디코딩 테스트)
        expect(arrayValue.first?.realtimeArrivalList.first?.stationName).to(equal("교대"))
    
    }
}
