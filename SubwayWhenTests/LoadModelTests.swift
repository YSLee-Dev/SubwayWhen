//
//  LoadModelTests.swift
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

class LoadModelTests : XCTestCase{
    let bag = DisposeBag()
    
    let loadModelStub = LoadModelStub()
    var liveList : LiveStationModel!
    var model : LoadModel!
    
    override func setUp() {
        self.liveList = stationArrivalRequestList
        self.model = LoadModel()
    }
    
    func testStationArrivalRequest(){
        // 더미데이터의 JSON
        let dummyData = self.loadModelStub.stationArrivalRequest(stationName: saveStation)
        let dummyValue = dummyData.map{ data -> LiveStationModel? in
            guard case let .success(value) = data else {return nil}
            return value
        }
            .asObservable()
            .filterNil()
        
        let dummy = try! dummyValue.toBlocking().toArray()
        
        // 실제 데이터
        let liveData = self.model.stationArrivalRequest(stationName: saveStation)
        let liveValue = liveData.map{ data -> LiveStationModel? in
            guard case let .success(value) = data else {return nil}
            return value
        }
            .asObservable()
            .filterNil()
        
        let live = try! liveValue.toBlocking().toArray()
        
        // subPrevious의 값이 Nil로 반환되는 경우가 종종 있음
        expect(dummy.first?.realtimeArrivalList.first?.subPrevious != "").to(equal(live.first?.realtimeArrivalList.first?.subPrevious != ""))
    }
}
