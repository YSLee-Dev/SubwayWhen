//
//  DetailResultScheduleModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/23.
//

import XCTest

import Nimble
import RxSwift
import RxBlocking

@testable import SubwayWhen

final class DetailResultScheduleModelTests: XCTestCase {

    var model : DetailResultScheduleModel!
    var dummyResultSchedule : [ResultSchdule]!
    
    override func setUp() {
        self.model = DetailResultScheduleModel()
        
        let seoulSchedule = LoadModel(networkManager: NetworkManager(session: MockURLSession((response: urlResponse!, data: seoulStationSchduleData))))
        
        let seoulScheduleModel = DetailModel(totalLoadModel: TotalLoadModel(loadModel: seoulSchedule))
        
        let data = seoulScheduleModel.scheduleLoad(scheduleGyodaeStation3Line)
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        self.dummyResultSchedule = arrayData.first!
    }

    func testResutScheduleToDetailResultSection(){
        // GIVEN
        let data = self.model.resultScheduleToDetailResultSection(self.dummyResultSchedule)
        let dummyData = self.dummyResultSchedule
        
        // WHEN
        let requestCount = data.count
        let dummyCount = 25
        
        let request10Count = data
            .flatMap{request in
                request.items
            }
            .filter{
                $0.hour == "10"
            }
            .flatMap{
                $0.minute
            }
            .count
        let dummy10Count = dummyData
            .flatMap{ data in
                data.filter{
                    let index = $0.startTime.index($0.startTime.startIndex, offsetBy: 1)
                    
                    return $0.startTime[$0.startTime.startIndex...index] == "10"
                }
            }?.count
        
        let requestSctionName = data
            .filter{
                $0.sectionName == "20시"
            }
            .map{
                $0.hour
            }
        let requestHour = data
            .flatMap{
                $0.items
            }
            .filter{
                $0.hour == "20"
            }
            .map{
                Int($0.hour) ?? 0
            }
         
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "0~24시간을 체크하기 때문에 25가 나와야함"
        )
        
        expect(request10Count).to(
            equal(dummy10Count),
            description: "데이터가 동일하기 때문에 10시의 개수는 동일해야함"
        )
        
        expect(requestSctionName).to(
            equal(requestHour),
            description: "sectionName과 Hour의 시간은 동일해야함"
        )
    }
    
    func testResutScheduleToDetailResultSectionError(){
        // GIVEN
        let data = self.model.resultScheduleToDetailResultSection([])
        
        // WHEN
        let requestCount = data.count
        let dummyCount = 25
        
        let request10Count = data
            .flatMap{request in
                request.items
            }
            .filter{
                $0.hour == "10"
            }
            .flatMap{
                $0.minute
            }
            .count
        let dummy10Count = 0
         
        // THEN
        expect(requestCount).to(
            equal(dummyCount),
            description: "데이터가 없어도 배열 자체는 나와야 함"
        )
        
        expect(request10Count).to(
            equal(dummy10Count),
            description: "데이터가 없기 때문에 minute 개수는 0이여야함"
        )
    }
    
    func testNowTimeMatching(){
        // GIVEN
        let data = self.model.nowTimeMatching(self.model.resultScheduleToDetailResultSection(self.dummyResultSchedule), nowHour: 5)
        
        // WHEN
        let requestData = data
        let dummyData = 5
        
        // THEN
        expect(requestData).to(
            equal(dummyData),
            description: "시간과 동일한 (5)가 나와야함"
        )
    }
    
    func testNowTimeMatchingError(){
        // GIVEN
        let data = self.model.nowTimeMatching([], nowHour: 5)
        
        // WHEN
        let requestData = data
        let dummyData = 0
        
        // THEN
        expect(requestData).to(
            equal(dummyData),
            description: "데이터가 없으면 0이 나와야함"
        )
    }
}
