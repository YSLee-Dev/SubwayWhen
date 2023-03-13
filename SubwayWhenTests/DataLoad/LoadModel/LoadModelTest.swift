//
//  LoadModelTest.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/13.
//

import XCTest

import RxSwift
import RxOptional
import RxBlocking
import Nimble

@testable import SubwayWhen

class LoadModelTest : XCTestCase{
    var arrivalLoadModel : LoadModelProtocol!
    var scheduleLoadModel : LoadModelProtocol!
    
    
    override func setUp() {
        let url = "Test.url"
        guard let urlResponse = HTTPURLResponse(url: URL(string: url)!,
                                          statusCode: 200,
                                          httpVersion: nil,
                                          headerFields: nil)
        else {return}
        
        let mockURL = MockURLSession((response: urlResponse, data: arrivalData))
        let networkManager = NetworkManager(session: mockURL)
        self.arrivalLoadModel = LoadModel(networkManager: networkManager)
        
        let schduleMockURL = MockURLSession((response: urlResponse, data: arrivalData))
        self.scheduleLoadModel = LoadModel(networkManager: NetworkManager(session: schduleMockURL))
    }
    
    func testStationArrivalRequest(){
        //GIVEN
        let data = self.arrivalLoadModel.stationArrivalRequest(stationName: "교대")
        let filterData = data
            .asObservable()
            .map{ data ->  LiveStationModel? in
            guard case .success(let value) = data else {return nil}
            return value
        }
        .filterNil()
        
        // WHEN
        let dummyData = try! JSONDecoder().decode(LiveStationModel.self, from: arrivalData)
        
        let bloacking = filterData.toBlocking()
        let requestData = try! bloacking.toArray()
        
        let requestStationName = requestData.first?.realtimeArrivalList.first?.stationName // MODEL VALUE
        let dummyStationName = dummyData.realtimeArrivalList.first?.stationName // DUMMY VALUE
        
        
        // THEN
        expect(requestStationName).to(
            equal(dummyStationName),
            description: "불러온 지하철 역이 동일해야함"
        )
    }
    
    func testSeoulStationScheduleLoad(){
        print(seoulStationSchdulData)
    }
}
