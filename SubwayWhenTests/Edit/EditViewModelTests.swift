//
//  EditViewModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/26.
//

import XCTest

import RxSwift
import RxCocoa
import RxTest
import Nimble

@testable import SubwayWhen

final class EditViewModelTests: XCTestCase {
    var model : EditModelProtocol!
    var saveStation : [SaveStation] = []
    let bag = DisposeBag()
    
    override func setUp(){
        self.model = EditModel()
        self.saveStation.append(contentsOf: [
            .init(id: "1", stationName: "1", stationCode: "1", updnLine: "상행", line: "1", lineCode: "1", group: .one, exceptionLastStation: "1", korailCode: "1"),
            .init(id: "2", stationName: "2", stationCode: "2", updnLine: "상행", line: "2", lineCode: "2", group: .one, exceptionLastStation: "2", korailCode: "2"),
            .init(id: "3", stationName: "3", stationCode: "3", updnLine: "상행", line: "3", lineCode: "3", group: .two, exceptionLastStation: "3", korailCode: "3")
        ])
    }
    
    func testDeleteCell(){
        // GIVEN
        let scheduler = TestScheduler(initialClock: 0)
        let saveStations = BehaviorSubject<[SaveStation]>(value: [])
        saveStations
            .onNext(self.saveStation)
        
        // WHEN
        let deleteEvent = scheduler.createHotObservable([
            .next(1, "1"), // 1번 삭제
            .next(3, "3"), // 3번 삭제
            .next(4, "5") // 없는 번호 삭제
        ])
        
        let delete = PublishSubject<String>()
        deleteEvent
            .subscribe(delete)
            .disposed(by: self.bag)
        
        delete
            .withLatestFrom(saveStations){ delete, data in
                var old = data
                for x in data.enumerated(){
                    if x.element.id == delete{
                        old.remove(at: x.offset)
                        break
                    }
                }
                return old
            }
            .bind(to: saveStations)
            .disposed(by: self.bag)
        
        let observer = scheduler.createObserver([SaveStation].self)
        saveStations
            .subscribe(observer)
            .disposed(by: self.bag)
        
        scheduler.start()
        
        // THEN
        expect(observer.events).to(
            equal([
                .next(0, self.saveStation),
                .next(1, [
                    .init(id: "2", stationName: "2", stationCode: "2", updnLine: "상행", line: "2", lineCode: "2", group: .one, exceptionLastStation: "2", korailCode: "2"),
                    .init(id: "3", stationName: "3", stationCode: "3", updnLine: "상행", line: "3", lineCode: "3", group: .two, exceptionLastStation: "3", korailCode: "3")]),
                .next(3, [ .init(id: "2", stationName: "2", stationCode: "2", updnLine: "상행", line: "2", lineCode: "2", group: .one, exceptionLastStation: "2", korailCode: "2")]),
                .next(4, [ .init(id: "2", stationName: "2", stationCode: "2", updnLine: "상행", line: "2", lineCode: "2", group: .one, exceptionLastStation: "2", korailCode: "2")])
            ])
        )
    }
    
    func testMoveCell(){
        // GIVEN
        let scheduler = TestScheduler(initialClock: 0)
        let editData = BehaviorSubject<[EditViewCellSection]>(value: [])
        editData
            .onNext([
                .init(sectionName: "출근", items: [
                    .init(id: "1", stationName: "1", stationCode: "1", updnLine: "1", line: "1", lineCode: "1", group: .one, exceptionLastStation: "1", korailCode: "1"),
                    .init(id: "2", stationName: "2", stationCode: "2", updnLine: "2", line: "2", lineCode: "2", group: .one, exceptionLastStation: "2", korailCode: "2")
                ]),
                .init(sectionName: "퇴근", items: [
                    .init(id: "1", stationName: "1", stationCode: "1", updnLine: "1", line: "1", lineCode: "1", group: .one, exceptionLastStation: "1", korailCode: "1")
                ])
            ])
        let saveStations = BehaviorSubject<[SaveStation]>(value: [])
        
        // WHEN
        let observer = scheduler.createObserver([SaveStation].self)
        saveStations
            .subscribe(observer)
            .disposed(by: self.bag)
        
        let moveEvnet = scheduler.createHotObservable([
            .next(1, ItemMovedEvent(
                sourceIndex: IndexPath(row: 0, section: 0),
                destinationIndex: IndexPath(row: 1, section: 0)
            ))
        ])
        
        let move = PublishSubject<ItemMovedEvent>()
        moveEvnet
            .subscribe(move)
            .disposed(by: self.bag)
        
        move
            .map{ index -> [SaveStation] in
                do{
                    var saveStation = self.saveStation
                    let nowValue = try editData.value()
                    
                    let old = index.sourceIndex
                    let now = index.destinationIndex
                    
                    let oldData = nowValue[old[0]].items[old[1]]
                    var nowData = SaveStation(id: "1", stationName: "1", stationCode: "1", updnLine: "1", line: "1", lineCode: "1", group: .one, exceptionLastStation: "1", korailCode: "1")
                    
                    if now[1] != nowValue[now[0]].items.count{
                        nowData = nowValue[now[0]].items[now[1]]
                    }
                    
                    var oldIndex = 0
                    var nowIndex = 0
                    
                    for x in saveStation.enumerated(){
                        if x.element.id == oldData.id{
                            oldIndex = x.offset
                        }
                        
                        if x.element.id == nowData.id{
                            nowIndex = x.offset
                        }
                    }
                    
                    if old[0] != now[0]{
                        saveStation[oldIndex].group = saveStation[oldIndex].group == .one ? .two : .one
                    }
                    
                    if now[1] == nowValue[now[0]].items.count{
                        let fixData = saveStation[oldIndex]
                        saveStation.remove(at: oldIndex)
                        saveStation.append(fixData)
                    }else if now[1] == 0{
                        let fixData = saveStation[oldIndex]
                        saveStation.remove(at: oldIndex)
                        saveStation.insert(fixData, at: 0)
                    }else if old[0] == now[0]{
                        saveStation.swapAt(oldIndex, nowIndex)
                    }else{
                        let fixData = saveStation[oldIndex]
                        saveStation.remove(at: oldIndex)
                        saveStation.insert(fixData, at: nowIndex)
                    }
                    return saveStation
                }catch{
                    return []
                }
            }
            .bind(to: saveStations)
            .disposed(by: self.bag)
        
        scheduler.start()
        
        // THEN
        expect(observer.events).to(
            equal([
                .next(0, []),
                .next(1, [
                    .init(id: "2", stationName: "2", stationCode: "2", updnLine: "상행", line: "2", lineCode: "2", group: .one, exceptionLastStation: "2", korailCode: "2"),
                    .init(id: "1", stationName: "1", stationCode: "1", updnLine: "상행", line: "1", lineCode: "1", group: .one, exceptionLastStation: "1", korailCode: "1"),
                    .init(id: "3", stationName: "3", stationCode: "3", updnLine: "상행", line: "3", lineCode: "3", group: .two, exceptionLastStation: "3", korailCode: "3")
                ])
            ])
        )
    }
}
