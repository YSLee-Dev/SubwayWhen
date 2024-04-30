//
//  MainModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/22.
//

import XCTest

import RxSwift
import RxCocoa
import RxBlocking
import Nimble

@testable import SubwayWhen

final class MainModelTests: XCTestCase {
    let bag = DisposeBag()
    
    var model : MainModel!
    var scheduleModel : MainModel!
    
    override func setUp() {
        let totalModel = TotalLoadModel(loadModel: LoadModel(networkManager: NetworkManager(session: MockURLSession((response: urlResponse!, data: arrivalData)))))
        self.model = MainModel(totalLoadModel: totalModel)
        
        let scheduleTotalModel = TotalLoadModel(loadModel: LoadModel(networkManager: NetworkManager(session: MockURLSession((response: urlResponse!, data: seoulStationSchduleData)))))
        self.scheduleModel = MainModel(totalLoadModel: scheduleTotalModel)
    }
    
    func testTimeGroupSet(){
        // GIVEN
        let oneTime = 8
        let twoTime = 21
        let data = self.model.timeGroup(oneTime: oneTime, twoTime: twoTime, nowHour: 9)
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestData = arrayData.first
        let dummyData = SaveStationGroup.one
        
        // THEN
        expect(requestData).to(
            equal(dummyData),
            description: "현재 시각을 지난 시간이 나와야 함"
        )
    }
    
    func testTimeGroupNotSet(){
        // GIVEN
        let oneTime = 0
        let twoTime = 0
        let data = self.model.timeGroup(oneTime: oneTime, twoTime: twoTime, nowHour: 12)
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        
        // WHEN
        let requestData = arrayData.first
        
        // THEN
        expect(requestData).to(
            beNil(),
            description: "설정된 값이 없을 경우 Nil이 나와야 함"
        )
    }
    
    func testCreateMainTableViewSection(){
        // GIVEN
        let data = self.model.createMainTableViewSection([mainCellDummyData])
        
        // WHEN
        let requestFirstSectionTitle = data.first?.sectionName
        let duumyFirstSectionTitle = ""
        
        let requestSecondSectionTitle = data[1].sectionName
        let duumySecondSectionTitle = "실시간 현황"
        
        let requestThreeSectionData = data[2].items.first
        let dummyThreeSectionData = mainCellDummyData
        
        // THEN
        expect(requestFirstSectionTitle).to(
            equal(duumyFirstSectionTitle),
            description: "첫 번째 Section의 타이틀은 없어야 함"
        )
        
        expect(requestSecondSectionTitle).to(
            equal(duumySecondSectionTitle),
            description: "두 번째 Section의 타이틀은 (실시간 현황)이여야 함"
        )
        
        expect(requestThreeSectionData).to(
            equal(dummyThreeSectionData),
            description: "통신 데이터는 동일해야함"
        )
    }
    
    func testMainCellDataToScheduleData(){
        // GIVEN
        let data = self.scheduleModel.mainCellDataToScheduleData(mainCellDummyData)
        
        // WHEN
        let requestType = data?.lineScheduleType
        let dummyType = ScheduleType.Seoul
        
        let requestCode = data?.stationCode
        let dummyCode = mainCellDummyData.stationCode
        
        let requestException = data?.exceptionLastStation
        let dummyException = mainCellDummyData.exceptionLastStation
        
        // THEN
        expect(requestType).to(
            equal(dummyType),
            description: "3호선 교대 데이터이기 때문에 Seoul이 나와야 함"
        )
        
        expect(requestCode).to(
            equal(dummyCode),
            description: "StationCode는 동일해야함"
        )
        
        expect(requestException).to(
            equal(dummyException),
            description: "Exception은 동일해야함"
        )
    }
    
    func testScheduleLoad(){
        // GIVEN
        let data = self.scheduleModel.scheduleLoad(scheduleGyodaeStation3Line)
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        let arrayFirstData = arrayData.first
        
        // WHEN
        let requestFirstStartTime = arrayFirstData?.first?.startTime
        let dummyFirstStartTime =  seoulScheduleDummyData.SearchSTNTimeTableByFRCodeService.row.first?.startTime
    
        let requestCount = arrayFirstData?.count
        let dummyCount = 1
        
        // THEN
        expect(requestFirstStartTime).toNot(
            equal(dummyFirstStartTime),
            description: "같은 데이터를 사용하지만, isNow가 True이기 때문에 값이 달라야 함"
        )
        
        expect(requestCount).to(
            equal(dummyCount),
            description: "isFirst가 True이기 때문에 개수는 1개여야 함"
        )
        
    }
    
    func testScheduleDataToMainTableViewCell(){
        // GIVEN
        let data = self.scheduleModel.scheduleLoad(scheduleGyodaeStation3Line)
        let blocking = data.toBlocking()
        let arrayData = try! blocking.toArray()
        let arrayFirstData = arrayData.first?.first
        
        let cellData = self.scheduleModel.scheduleDataToMainTableViewCell(data: arrayFirstData!, nowData: mainCellDummyData)
        
        // WHEN
        let requestStationName = cellData.stationName
        let dummyStationName = mainCellDummyData.stationName
        
        let requestArrivalTime = cellData.arrivalTime
        let dummyArrivalTime = mainCellDummyData.arrivalTime
        
        let requestType = cellData.type
        let dummyType = MainTableViewCellType.schedule
        
        let requestLineNumber = cellData.lineNumber
        let dummyLineNumber = mainCellDummyData.lineNumber
        
        // THEN
        expect(requestStationName).to(
            equal(dummyStationName),
            description: "역 이름은 동일해야함"
        )
        
        expect(requestArrivalTime).toNot(
            equal(dummyArrivalTime),
            description: "시간표 데이터로 변경되었기 때문에 시간은 달라야함"
        )
        
        expect(requestType).to(
            equal(dummyType),
            description: "시간표 데이터로 변경되었기 때문에 타입은 스케줄 타입이여야 함"
        )
        
        expect(requestLineNumber).to(
            equal(dummyLineNumber),
            description: "라인넘버를 포함한 기본 정보는 동일해야함"
        )
        
    }

}
