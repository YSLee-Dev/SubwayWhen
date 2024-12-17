//
//  SearchViewModalTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/28.
//

import XCTest

import RxSwift
import RxBlocking
import RxTest
import Nimble

@testable import SubwayWhen

//class SearchViewModalTests : XCTestCase{
//    var model : SearchModelProtocol!
//    let bag = DisposeBag()
//    
//    override func setUp() {
//        let mock = MockURLSession((response: urlResponse!, data: stationNameSearchData))
//        self.model = SearchModel(model: TotalLoadModel(loadModel: LoadModel(networkManager: NetworkManager(session: mock))))
//    }
//    
//    func testDefaultCellList(){
//        let scheduler = TestScheduler(initialClock: 0)
//        let defaultData = BehaviorSubject<[String]>(value: ["강남", "광화문", "명동", "광화문", "판교", "수원"])
//        let observer = scheduler.createObserver([String].self)
//        
//        defaultData
//            .subscribe(observer)
//            .disposed(by: self.bag)
//        
//        // WHEN
//        scheduler.createColdObservable([
//            .next(3, searchDeafultList)
//        ])
//        .subscribe(defaultData)
//        .disposed(by: self.bag)
//        
//        scheduler.start()
//        
//        // THEN
//        expect(observer.events).to(
//            equal([
//                .next(0, ["강남", "광화문", "명동", "광화문", "판교", "수원"]),
//                .next(3, ["123", "456", "789"])
//            ])
//        )
//    }
//    
//    func testSearchQuery(){
//        // GIVEN
//        let scheduler = TestScheduler(initialClock: 0)
//        let nowData = BehaviorSubject<[ResultVCSection]>(value: [ResultVCSection(section: "", items: [])])
//        
//        let observer = scheduler.createObserver([ResultVCSection].self)
//        
//        nowData
//            .subscribe(observer)
//            .disposed(by: self.bag)
//        
//        // WHEN
//        // 검색 창에 검색
//        let searchEvent = scheduler.createHotObservable([
//            .next(3, "교대")
//        ])
//        let search = PublishSubject<String>()
//        searchEvent
//            .subscribe(search)
//            .disposed(by: self.bag)
//        
//        search
//            .withUnretained(self)
//            .flatMap{ viewModel, data in
//                viewModel.model.stationNameSearchRequest(data)
//            }
//            .withUnretained(self)
//            .map{ viewModel, data in
//                viewModel.model.searchStationToResultVCSection(data)
//            }
//            .bind(to: nowData)
//            .disposed(by: self.bag)
//        
//        scheduler.start()
//        
//        // THEN
//        expect(observer.events).to(
//            equal([
//                .next(0, [ResultVCSection(section: "", items: [])]),
//                .next(3, [ResultVCSection(section: "3401003", items: [SubwayWhen.ResultVCCellData(stationName: "교대", lineNumber: "03호선", stationCode: "340", useLine: "3호선", lineCode: "1003")]), ResultVCSection(section: "2231002", items: [SubwayWhen.ResultVCCellData(stationName: "교대", lineNumber: "02호선", stationCode: "223", useLine: "2호선", lineCode: "1002")])])
//            ])
//        )
//    }
//}
