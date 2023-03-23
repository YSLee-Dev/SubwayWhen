//
//  MainViewModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/21.
//

import XCTest

import RxSwift
import RxCocoa
import RxTest
import RxBlocking
import Nimble

@testable import SubwayWhen

final class MainViewModelTests: XCTestCase {
    let bag = DisposeBag()
    
    var model : MainModel!
    
    override func setUp() {
        let totalModel = TotalLoadModel(loadModel: LoadModel(networkManager: NetworkManager(session: MockURLSession((response: urlResponse!, data: seoulStationSchduleData)))))
        self.model =  MainModel(totalLoadModel: totalModel)
    }
    
    func testMainCellData(){
        // GIVEN
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver([MainTableViewCellData].self)
        
        // 데이터를 로드 후
        let dataEvnet = scheduler.createHotObservable([
            .next(3, mainCellDummyData),
            .next(5, mainCellDummyData)
        ])
        
        // WHEN
        let data = BehaviorRelay<[MainTableViewCellData]>(value: [])
        data
            .subscribe(observer)
            .disposed(by: self.bag)
        
        dataEvnet
            .map{value in
                var now = data.value
                now.append(value)
                return now
            }
            .bind(to: data)
            .disposed(by: self.bag)
        
        scheduler.start()
        
        // THEN
        expect(observer.events).to(
            equal([
                .next(0, []),
                .next(3, [mainCellDummyData]),
                .next(5, [mainCellDummyData, mainCellDummyData])
            ]),
            description: "동일한 정보를 배출하기 때문에, 두개가 이어진 배열이여야 함"
        )
    }
    
    func testScheduleCellTransform(){
        // GIVEN
        let scheduler = TestScheduler(initialClock: 0)
        
        let observer = scheduler.createObserver([MainTableViewCellData].self)
        
        let groupData = BehaviorRelay<[MainTableViewCellData]>(value: [mainCellDummyData, mainCellDummyData])
        
        groupData
            .subscribe(observer)
            .disposed(by: self.bag)
        
        // WHEN
        // 데이터 통신으로 인해 클릭 보다 값이 늦음
        let scheduleDataEvnet = scheduler.createColdObservable([
            .next(2, [ResultSchdule(startTime: "000001", type: .Seoul, isFast: "", startStation: "교대", lastStation: "교대")]),
            .next(5, [ResultSchdule(startTime: "000001", type: .Seoul, isFast: "", startStation: "교대", lastStation: "교대")]),
            .next(7, [ResultSchdule(startTime: "000001", type: .Seoul, isFast: "", startStation: "교대", lastStation: "사당")])
        ])
        
        let scheduleData = PublishSubject<[ResultSchdule]>()
        scheduleDataEvnet
            .subscribe(scheduleData)
            .disposed(by: self.bag)
        
        let indexEvnet = scheduler.createColdObservable([
            .next(1, IndexPath(row: 0, section: 0)),
            .next(3, IndexPath(row: 1, section: 0))
        ])
        
        let indexData = PublishSubject<IndexPath>()
        indexEvnet
            .subscribe(indexData)
            .disposed(by: self.bag)
        
        scheduleData
            .withLatestFrom(indexData){[weak self] scheduleData, index -> [MainTableViewCellData] in
                
                guard let scheduleData = scheduleData.first else {return []}
                
                let nowData = groupData.value[index.row]
                guard let newData = self?.model.scheduleDataToMainTableViewCell(data: scheduleData, nowData: nowData) else {return []}
                
                var now = groupData.value
                now[index.row] = newData
                return now
            }
            .bind(to: groupData)
            .disposed(by: self.bag)
        
        scheduler.start()
        
        // THEN
        // 스케줄 통신 후 해당 index에 값이 바뀌는 부분 검증
        expect(observer.events).to(
            equal([
                .next(0, [mainCellDummyData,mainCellDummyData]),
                .next(2, [
                    MainTableViewCellData(upDown: "상행", arrivalTime: "000001", previousStation: "", subPrevious: "정보없음", code: "000001", subWayId: "1003", stationName: "교대", lastStation: "교대행", lineNumber: "1003", isFast: "", useLine: "", group: "", id: "-", stationCode: "340", exceptionLastStation: "", type: .schedule, backStationId: "1003000339", nextStationId: "1003000341", korailCode: ""), mainCellDummyData
                ]),
                .next(5, [
                    MainTableViewCellData(upDown: "상행", arrivalTime: "000001", previousStation: "", subPrevious: "정보없음", code: "000001", subWayId: "1003", stationName: "교대", lastStation: "교대행", lineNumber: "1003", isFast: "", useLine: "", group: "", id: "-", stationCode: "340", exceptionLastStation: "", type: .schedule, backStationId: "1003000339", nextStationId: "1003000341", korailCode: ""), MainTableViewCellData(upDown: "상행", arrivalTime: "000001", previousStation: "", subPrevious: "정보없음", code: "000001", subWayId: "1003", stationName: "교대", lastStation: "교대행", lineNumber: "1003", isFast: "", useLine: "", group: "", id: "-", stationCode: "340", exceptionLastStation: "", type: .schedule, backStationId: "1003000339", nextStationId: "1003000341", korailCode: "")
                ]),
                .next(7, [
                    MainTableViewCellData(upDown: "상행", arrivalTime: "000001", previousStation: "", subPrevious: "정보없음", code: "000001", subWayId: "1003", stationName: "교대", lastStation: "교대행", lineNumber: "1003", isFast: "", useLine: "", group: "", id: "-", stationCode: "340", exceptionLastStation: "", type: .schedule, backStationId: "1003000339", nextStationId: "1003000341", korailCode: ""),  MainTableViewCellData(upDown: "상행", arrivalTime: "000001", previousStation: "", subPrevious: "정보없음", code: "000001", subWayId: "1003", stationName: "교대", lastStation: "사당행", lineNumber: "1003", isFast: "", useLine: "", group: "", id: "-", stationCode: "340", exceptionLastStation: "", type: .schedule, backStationId: "1003000339", nextStationId: "1003000341", korailCode: "")
                ])
            ])
        )
    }
}
