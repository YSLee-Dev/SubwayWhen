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
    var cellData : DetailLoadData!
    
    let bag = DisposeBag()
    
    override func setUp() {
        let seoulSchedule = LoadModel(networkManager: NetworkManager(session: MockURLSession((response: urlResponse!, data: arrivalData))))
        
        self.model = DetailModel(totalLoadModel: TotalLoadModel(loadModel: seoulSchedule))
        
        self.cellData = .init(upDown: "상행", stationName: "교대", lineNumber: "", lineCode: "1003", useLine: "", stationCode: "", exceptionLastStation: "제외", backStationId: "", nextStationId: "", korailCode: "")
      
    }

    func testExceptionBtnTap(){
        // GIVEN
        let testScheduler = TestScheduler(initialClock: 0)
        let observer = testScheduler.createObserver(DetailLoadData.self)
        
        let detailViewData = BehaviorSubject<DetailLoadData>(value: self.cellData!)
        
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
                .next(1, .init(upDown: "상행", stationName: "교대", lineNumber: "", lineCode: "1003", useLine: "", stationCode: "", exceptionLastStation: "", backStationId: "", nextStationId: "", korailCode: ""))
            ])
        )
    }
    
    func testRealTimeData(){
        // GIVEN
        let testScheduler = TestScheduler(initialClock: 0)
        let detailViewData = BehaviorSubject<DetailLoadData>(value: self.cellData!)
        let realTime = BehaviorSubject<[Int]>(value: [])
        let observer = testScheduler.createObserver([Int].self)
        
        let dummy = arrivalDummyData.realtimeArrivalList
        
        realTime
            .subscribe(observer)
            .disposed(by: self.bag)
        
        // WHEN
        let reload = PublishSubject<Void>()
        let reloadEvnet = testScheduler.createHotObservable([
            .next(1, Void())
        ])
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
        
        Observable.combineLatest(detailViewData, reailTimeData){[weak self] data, realTime -> [RealtimeStationArrival] in
            self?.model.arrivalDataMatching(station: data, arrivalData: realTime) ?? []
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
