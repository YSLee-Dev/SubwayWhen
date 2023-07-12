//
//  SettingNotiModalViewModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/07/11.
//

import Foundation

import XCTest
import RxSwift
import RxTest
import Nimble

@testable import SubwayWhen

class SettingNotiModalViewModelTests: XCTestCase {
    var bag = DisposeBag()
    var oneStationTap: BehaviorSubject<NotificationManagerRequestData>!
    var twoStationTap: BehaviorSubject<NotificationManagerRequestData>!
    
    override func setUp() {
        self.oneStationTap = BehaviorSubject<NotificationManagerRequestData>(value: NotificationManagerRequestData(id: "", stationName: "", useLine: "", line: "", group: .one))
        self.twoStationTap = BehaviorSubject<NotificationManagerRequestData>(value: NotificationManagerRequestData(id: "", stationName: "", useLine: "", line: "", group: .two))
    }
    
    override func tearDown() {
        self.oneStationTap = nil
        self.twoStationTap = nil
        self.bag = DisposeBag()
    }
    
    
    func testSaveStationLoad() {
        // GIVEN
        let scheduler = TestScheduler(initialClock: 0)
        
        let oneStationObserver = scheduler.createObserver(NotificationManagerRequestData.self)
        oneStationTap
            .subscribe(oneStationObserver)
            .disposed(by: self.bag)
        
        let twoStationObserver = scheduler.createObserver(NotificationManagerRequestData.self)
        twoStationTap
            .subscribe(twoStationObserver)
            .disposed(by: self.bag)
        
        // WHEN
        scheduler.createColdObservable([
            .next(1, [
                NotificationManagerRequestData(id: "1", stationName: "교대", useLine: "03호선", line: "1003", group: .one),
                NotificationManagerRequestData(id: "2", stationName: "강남", useLine: "02호선", line: "1002", group: .two)
            ])
        ])
        .withUnretained(self)
        .subscribe(onNext: {tests,  data in
            let nilData = NotificationManagerRequestData(id: "", stationName: "", useLine: "", line: "", group: .one)
            let nilDataTwo = NotificationManagerRequestData(id: "", stationName: "", useLine: "", line: "", group: .two)
            
            tests.oneStationTap.onNext(data.first ?? nilData)
            tests.twoStationTap.onNext(data.last ?? nilDataTwo)
        })
        .disposed(by: self.bag)
        
        scheduler.start()
        
        // THEN
        expect(oneStationObserver.events).to(
            equal([
                .next(0, .init(id: "", stationName: "", useLine: "", line: "", group: .one)),
                .next(1, NotificationManagerRequestData(id: "1", stationName: "교대", useLine: "03호선", line: "1003", group: .one))
            ]),
            description: "초기값이 있어야며, 초기값 이후에는 불러온 사용"
        )
        
        expect(twoStationObserver.events).to(
            equal([
                .next(0, .init(id: "", stationName: "", useLine: "", line: "", group: .two)),
                .next(1,  NotificationManagerRequestData(id: "2", stationName: "강남", useLine: "02호선", line: "1002", group: .two))
            ]),
            description: "초기값이 있어야며, 초기값 이후에는 불러온 사용"
        )
    }
    
    func testOkBtnTapDataSend() {
        // GIVEN
        let scheduler = TestScheduler(initialClock: 0)
        
        self.oneStationTap.onNext(NotificationManagerRequestData(id: "1", stationName: "교대", useLine: "03호선", line: "1003", group: .one))
        
        let totalObserver = scheduler.createObserver([NotificationManagerRequestData].self)
        let totalData = PublishSubject<[NotificationManagerRequestData]>()
        
        totalData
            .subscribe(totalObserver)
            .disposed(by: self.bag)
        
        // WHEN
        let okData = PublishSubject<Void>()
        scheduler.createColdObservable([
            .next(3, Void())
        ])
        .subscribe(okData)
        .disposed(by: self.bag)
        
        let total = Observable.combineLatest(self.oneStationTap, self.twoStationTap) {
            [$0, $1]
        }
        
        okData
            .withLatestFrom(total)
            .bind(to: totalData)
            .disposed(by: self.bag)
        
        scheduler.start()
        
        // THEN
        expect(totalObserver.events).to(
            equal([
                    .next(3, [
                        NotificationManagerRequestData(id: "1", stationName: "교대", useLine: "03호선", line: "1003", group: .one),
                        NotificationManagerRequestData(id: "", stationName: "", useLine: "", line: "", group: .two)
                    ])
            ]),
            description: "초기값 이후에는 다른 그룹이 선택되지 않아도 방출되어야 함"
        )
    }
    
}
