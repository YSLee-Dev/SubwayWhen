//
//  LocationModalModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/07/10.
//

import XCTest
import RxSwift
import RxBlocking
import Nimble

@testable import SubwayWhen

//class LocationModalModelTests: XCTestCase {
//    var model: LocationModalModelProtocol!
//    
//    override func setUp() {
//        let mock = MockURLSession((response: urlResponse!, data: vicinityData))
//        
//        let totalModel = TotalLoadModel(
//            loadModel: LoadModel(
//                networkManager: NetworkManager(
//                    session: mock
//                )
//            )
//        )
//        
//        self.model = LocationModalModel(model: totalModel)
//    }
//    
//    func testLocationToVicinityStationRequest() {
//        // GIVEN
//        let data = self.model.locationToVicinityStationRequest(
//            locationData: .init(lat: 37.49388026940836, lon: 127.01360357128935)
//        )
//        
//        let blocking = data.toBlocking()
//        let requestData = try! blocking.toArray().first?.first
//        let dummyData = vicinityStationsDummyData.documents.sorted {
//            let first = Int($0.distance) ?? 0
//            let second = Int($1.distance) ?? 1
//            
//            return first < second
//        }
//        
//        // WHEN
//        let requestIDData = requestData?.items.map {$0.id}
//        let dummyIDData = dummyData.map {"\($0.distance)\($0.name)"}
//        
//        let requestStationData = requestData?.items.map {$0.name}
//        let dummyStationData = dummyData.map { data in
//            let index = data.name.lastIndex(of: "역")!
//            return String(data.name[data.name.startIndex ..< index])
//        }
//        
//        let requestDistanceData = requestData?.items.map { data in
//            let formatRemove = data.distance.replacingOccurrences(of: ",", with: "")
//            let textRemove = formatRemove.replacingOccurrences(of: "m", with: "")
//            
//            return textRemove
//        }
//        let dummyDistanceData = dummyData.map {$0.distance}
//        
//        let requestLineName = requestData?.items.map {$0.line}
//        let dummyLineName = dummyData.map { data in
//            let index = data.name.lastIndex(of: "역")!
//            return String(data.name[data.name.index(after: index) ..< data.name.endIndex]).replacingOccurrences(of: " ", with: "")
//        }
//        
//        // THEN
//        expect(requestIDData).to(
//            equal(dummyIDData),
//            description: "ID 값은 각각의 거리와 지하철 역의 조합이여야 함"
//        )
//        
//        expect(requestStationData).to(
//            equal(dummyStationData),
//            description: "지하철역 이름은 '역'을 기준으로 잘라서 표시해야 함"
//        )
//        
//        expect(requestDistanceData).to(
//            equal(dummyDistanceData),
//            description: "지하철 역의 거리는 같아야함 (텍스트 포맷 제거 후)"
//        )
//        
//        expect(requestLineName).to(
//            equal(dummyLineName),
//            description: "라인은 Name을 기준으로 잘라서 표시해야함"
//        )
//    }
//}
