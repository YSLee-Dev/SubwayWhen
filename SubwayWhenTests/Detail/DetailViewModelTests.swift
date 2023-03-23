//
//  DetailViewModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/23.
//

import XCTest

import Nimble
import RxSwift
import RxTest

@testable import SubwayWhen

final class DetailViewModelTests: XCTestCase {
    var model : DetailModel!
    var cellData : MainTableViewCellData!
    
    let bag = DisposeBag()
    
    override func setUp() {
        let seoulSchedule = LoadModel(networkManager: NetworkManager(session: MockURLSession((response: urlResponse!, data: arrivalData))))
        
        self.model = DetailModel(totalLoadModel: TotalLoadModel(loadModel: seoulSchedule))
        
        self.cellData = .init(upDown: "상행", arrivalTime: "", previousStation: "", subPrevious: "", code: "지원하지 않는 호선이에요.", subWayId: "1003", stationName: "교대", lastStation: "", lineNumber: "", isFast: "", useLine: "", group: "", id: "", stationCode: "", exceptionLastStation: "제외", type: .real, backStationId: "", nextStationId: "",  korailCode: "")
    }

    func testExceptionBtnTap(){
        // GIVEN
        let testScheduler = TestScheduler(initialClock: 0)
        let observer = testScheduler.createObserver(MainTableViewCellData.self)
        
        let detailViewData = BehaviorSubject<MainTableViewCellData>(value: self.cellData!)
        
        detailViewData
            .subscribe(observer)
            .disposed(by: self.bag)
        
        // WHEN
        // 재로딩 버튼 클릭 시
        let exceptionBtnEvent = testScheduler.createHotObservable([
            .next(1, Void())
        ])
        
        let exceptionBtn = PublishSubject<Void>()
        exceptionBtnEvent
            .subscribe(exceptionBtn)
            .disposed(by: self.bag)
        
        exceptionBtn
            .withLatestFrom(detailViewData)
            .map{
                var now = $0
                now.exceptionLastStation = ""
                return now
            }
            .bind(to: detailViewData)
            .disposed(by: self.bag)
        
        testScheduler.start()
        
        // THEN
        expect(observer.events).to(
            equal([
                .next(0, self.cellData!),
                .next(1, .init(upDown: "상행", arrivalTime: "", previousStation: "", subPrevious: "", code: "지원하지 않는 호선이에요.", subWayId: "1003", stationName: "교대", lastStation: "", lineNumber: "", isFast: "", useLine: "", group: "", id: "", stationCode: "", exceptionLastStation: "", type: .real, backStationId: "", nextStationId: "",  korailCode: ""))
            ])
        )
    }
    
    func testRealTimeData(){
        // GIVEN
        let testScheduler = TestScheduler(initialClock: 0)
        let detailViewData = BehaviorSubject<MainTableViewCellData>(value: self.cellData!)
        let realTime = BehaviorSubject<[Int]>(value: [])
        let observer = testScheduler.createObserver([Int].self)
        
        let dummy = arrivalDummyData.realtimeArrivalList
        
        realTime
            .subscribe(observer)
            .disposed(by: self.bag)
        
        // WHEN
        let reloadEvnet = testScheduler.createHotObservable([
            .next(1, Void())
        ])
        let reload = PublishSubject<Void>()
        reloadEvnet
            .subscribe(reload)
            .disposed(by: self.bag)
        
        let reloadData = reload
            .withLatestFrom(detailViewData)
        
        let reailTimeData = reloadData
            .withUnretained(self)
            .flatMapLatest{ viewModel, data in
                viewModel.model.arrvialDataLoad(data.stationName)
            }
        
        Observable.combineLatest(detailViewData, reailTimeData){[weak self] station, realTime -> [RealtimeStationArrival] in
            self?.model.arrivalDataMatching(station: station, arrivalData: realTime) ?? []
        }
        .map{ data in
            data.map{
                Int($0.arrivalTime) ?? 0
            }
        }
        .bind(to: realTime)
        .disposed(by: self.bag)
        
        
        testScheduler.start()
        
        // THEN
        expect(observer.events).to(
            equal([
                .next(0, []),
                .next(1,
                     [
                        Int(dummy[0].arrivalTime) ?? 0,
                        // 상하행 구분 데이터 X
                        Int(dummy[2].arrivalTime) ?? 1
                     ]
                     )
            ])
        )
        
    }
}
