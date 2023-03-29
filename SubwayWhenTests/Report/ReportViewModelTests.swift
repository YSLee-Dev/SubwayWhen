//
//  ReportViewModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/27.
//

import XCTest

import RxSwift
import RxCocoa
import RxTest
import Nimble

@testable import SubwayWhen

final class ReportViewModelTests: XCTestCase {
    var model : ReportModelProtocol!
    let bag = DisposeBag()
    
    override func setUp(){
        self.model = ReportModel()
    }
    
    func testOne_TwoStep(){
        // GIVEN
        let scheduler = TestScheduler(initialClock: 0)
        let nowData = BehaviorRelay<[ReportTableViewCellSection]>(value: [])
        let observer = scheduler.createObserver([ReportTableViewCellSection].self)
        
        nowData
            .subscribe(observer)
            .disposed(by: self.bag)
        
        let oneStep = self.model.oneStepQuestionData()
        let blocking = oneStep.toBlocking()
        let oneStepData = try! blocking.toArray().first
        
        // WHEN
        let oneStepObservable = scheduler.createHotObservable([
            .next(1, oneStepData!)
        ])
        
        oneStepObservable
            .bind(to: nowData)
            .disposed(by: self.bag)
        
        // TAP
        let tapData = PublishSubject<ReportBrandData>()
        let tap = PublishSubject<Void>()
        
        let tapEvnet = scheduler.createColdObservable([
            .next(3, ReportBrandData.one)
        ])
            .share()
        
        tapEvnet
            .subscribe(tapData)
            .disposed(by: self.bag)
        
        tapEvnet
            .map{_ in Void()}
            .subscribe(tap)
            .disposed(by: self.bag)
        
        tap
            .withLatestFrom(tapData)
            .withUnretained(self)
            .map{ cell, data in
                let value = nowData.value
                let first = value.first!
                
                var two = cell.model.twoStepQuestionData()
                
                if let exception = cell.model.twoStepSideException(data) {
                    two.items.append(exception)
                }
                
                return [first, two]
            }
            .debug()
            .bind(to: nowData)
            .disposed(by: self.bag)
        
        scheduler.start()
        
        // THEN
        expect(observer.events).to(
            equal([
                .next(0, []),
                .next(1, [ReportTableViewCellSection(sectionName: "민원 호선", items: [.init(cellTitle: "몇호선 민원을 접수하시겠어요?", cellData: "", type: .Line, focus: false)])]),
                .next(3, [
                    ReportTableViewCellSection(sectionName: "민원 호선", items: [.init(cellTitle: "몇호선 민원을 접수하시겠어요?", cellData: "", type: .Line, focus: false)]),
                    ReportTableViewCellSection(sectionName: "호선 정보", items: [
                        .init(cellTitle: "열차의 행선지를 입력해주세요. (행)", cellData: "", type: .TextField, focus: true),
                        .init(cellTitle: "현재 역을 입력해주세요. (역)", cellData: "", type: .TextField, focus: false),
                        .init(cellTitle: "현재 역이 청량리 ~ 서울역 안에 있나요?", cellData: "", type: .TwoBtn, focus: false)
                    ])
                ])
            ])
        )
    }
    
    func testTwo_ThreeStep(){
        // GIVEN
        let scheduler = TestScheduler(initialClock: 0)
        let nowData = BehaviorRelay<[ReportTableViewCellSection]>(value: [])
        let observer = scheduler.createObserver([ReportTableViewCellSection].self)
        
        nowData
            .subscribe(observer)
            .disposed(by: self.bag)
        
        let step = scheduler.createHotObservable([
            .next(1, [ReportTableViewCellSection(sectionName: "민원 호선", items: [.init(cellTitle: "몇호선 민원을 접수하시겠어요?", cellData: "", type: .Line, focus: false)])]),
            .next(3, [
                ReportTableViewCellSection(sectionName: "민원 호선", items: [.init(cellTitle: "몇호선 민원을 접수하시겠어요?", cellData: "", type: .Line, focus: false)]),
                ReportTableViewCellSection(sectionName: "호선 정보", items: [
                    .init(cellTitle: "열차의 행선지를 입력해주세요. (행)", cellData: "", type: .TextField, focus: true),
                    .init(cellTitle: "현재 역을 입력해주세요. (역)", cellData: "", type: .TextField, focus: false),
                    .init(cellTitle: "현재 역이 청량리 ~ 서울역 안에 있나요?", cellData: "", type: .TwoBtn, focus: false)
                ])
            ])
        ])
        
        step
            .bind(to: nowData)
            .disposed(by: self.bag)
        
        // WHEN
        // 설명
        let destination = PublishSubject<String>()
        let destinationEvnet = scheduler.createHotObservable([
            .next(5, "인천행")
        ])
        destinationEvnet
            .subscribe(destination)
            .disposed(by: self.bag)
        
        // 역
        let nowStation = PublishSubject<String>()
        let nowStationEvent = scheduler.createHotObservable([
            .next(8, "시청역")
        ])
        nowStationEvent
            .subscribe(nowStation)
            .disposed(by: self.bag)
        
        // 선택
        let brand = PublishSubject<String>()
        let brandEvnet = scheduler.createHotObservable([
            .next(7, "Y")
        ])
        brandEvnet
            .subscribe(brand)
            .disposed(by: self.bag)
        
        destination
            .map{[weak self] data in
                var now = nowData.value
                now = self!.model.cellDataSave(nowData: now , data: data, index: IndexPath(row: 0, section: 1))
                
                if now[1].items[1].cellData == ""{
                    now[1].items[1].focus = true
                }
                
                return now
            }
            .bind(to: nowData)
            .disposed(by: self.bag)
        
        nowStation
            .map{[weak self] data in
                var now = nowData.value
                now = self!.model.cellDataSave(nowData: now , data: data, index: IndexPath(row: 1, section: 1))
                
                return now
            }
            .bind(to: nowData)
            .disposed(by: self.bag)
        
        Observable.combineLatest(destination, nowStation, brand)
            .withUnretained(self)
            .map{cell, value -> [ReportTableViewCellSection] in
                var now = nowData.value
                
                if now[1].items.count == 3 && value.2 == "N/A"{
                    return []
                }else if value.2 != "N/A"{
                    now[1].items[2].cellData = value.2
                }
                
                now.append(cell.model.theeStepQuestion())
                
                return now
                
            }
            .bind(to: nowData)
            .disposed(by: self.bag)
        
        scheduler.start()
        
        // THEN
        expect(observer.events).to(
            equal([
                .next(0, []),
                .next(1, [ReportTableViewCellSection(sectionName: "민원 호선", items: [.init(cellTitle: "몇호선 민원을 접수하시겠어요?", cellData: "", type: .Line, focus: false)])]),
                .next(3, [
                    ReportTableViewCellSection(sectionName: "민원 호선", items: [.init(cellTitle: "몇호선 민원을 접수하시겠어요?", cellData: "", type: .Line, focus: false)]),
                    ReportTableViewCellSection(sectionName: "호선 정보", items: [
                        .init(cellTitle: "열차의 행선지를 입력해주세요. (행)", cellData: "", type: .TextField, focus: true),
                        .init(cellTitle: "현재 역을 입력해주세요. (역)", cellData: "", type: .TextField, focus: false),
                        .init(cellTitle: "현재 역이 청량리 ~ 서울역 안에 있나요?", cellData: "", type: .TwoBtn, focus: false)
                    ])
                ]),
                .next(5,[
                    ReportTableViewCellSection(sectionName: "민원 호선", items: [.init(cellTitle: "몇호선 민원을 접수하시겠어요?", cellData: "", type: .Line, focus: false)]),
                    ReportTableViewCellSection(sectionName: "호선 정보", items: [
                        .init(cellTitle: "열차의 행선지를 입력해주세요. (행)", cellData: "인천행", type: .TextField, focus: false),
                        .init(cellTitle: "현재 역을 입력해주세요. (역)", cellData: "", type: .TextField, focus: true),
                        .init(cellTitle: "현재 역이 청량리 ~ 서울역 안에 있나요?", cellData: "", type: .TwoBtn, focus: false)
                    ])
                ]),
                .next(8,[
                    ReportTableViewCellSection(sectionName: "민원 호선", items: [.init(cellTitle: "몇호선 민원을 접수하시겠어요?", cellData: "", type: .Line, focus: false)]),
                    ReportTableViewCellSection(sectionName: "호선 정보", items: [
                        .init(cellTitle: "열차의 행선지를 입력해주세요. (행)", cellData: "인천행", type: .TextField, focus: false),
                        .init(cellTitle: "현재 역을 입력해주세요. (역)", cellData: "시청역", type: .TextField, focus: false),
                        .init(cellTitle: "현재 역이 청량리 ~ 서울역 안에 있나요?", cellData: "", type: .TwoBtn, focus: false)
                    ])
                ]),
                .next(8,[
                    ReportTableViewCellSection(sectionName: "민원 호선", items: [.init(cellTitle: "몇호선 민원을 접수하시겠어요?", cellData: "", type: .Line, focus: false)]),
                    ReportTableViewCellSection(sectionName: "호선 정보", items: [
                        .init(cellTitle: "열차의 행선지를 입력해주세요. (행)", cellData: "인천행", type: .TextField, focus: false),
                        .init(cellTitle: "현재 역을 입력해주세요. (역)", cellData: "시청역", type: .TextField, focus: false),
                        .init(cellTitle: "현재 역이 청량리 ~ 서울역 안에 있나요?", cellData: "Y", type: .TwoBtn, focus: false)
                    ]),
                    ReportTableViewCellSection(sectionName: "상세 정보", items: [
                        .init(cellTitle: "고유(열차)번호를 입력해주세요.", cellData: "", type: .TextField, focus: true)])
                ])
            ])
        )
    }
    
    func testThree(){
        // GIVEN
        let scheduler = TestScheduler(initialClock: 0)
        let nowData = BehaviorRelay<[ReportTableViewCellSection]>(value: [])
        let observer = scheduler.createObserver([ReportTableViewCellSection].self)
        
        nowData
            .subscribe(observer)
            .disposed(by: self.bag)
        
        let step = scheduler.createHotObservable([
            .next(3, [
                ReportTableViewCellSection(sectionName: "민원 호선", items: [.init(cellTitle: "몇호선 민원을 접수하시겠어요?", cellData: "", type: .Line, focus: false)]),
                ReportTableViewCellSection(sectionName: "호선 정보", items: [
                    .init(cellTitle: "열차의 행선지를 입력해주세요. (행)", cellData: "인천행", type: .TextField, focus: false),
                    .init(cellTitle: "현재 역을 입력해주세요. (역)", cellData: "시청역", type: .TextField, focus: false),
                    .init(cellTitle: "현재 역이 청량리 ~ 서울역 안에 있나요?", cellData: "Y", type: .TwoBtn, focus: false)
                ]),
                ReportTableViewCellSection(sectionName: "상세 정보", items: [
                    .init(cellTitle: "칸 위치나 열차번호를 입력해주세요.", cellData: "", type: .TextField, focus: true)])
            ])
        ])
        
        step
            .bind(to: nowData)
            .disposed(by: self.bag)
        
        // WHEN
        // 열차정보
        let trainCar = PublishSubject<String>()
        let trainCarEvent = scheduler.createHotObservable([
            .next(7, "1-4")
        ])
        
        trainCarEvent
            .subscribe(trainCar)
            .disposed(by: self.bag)
        
        trainCar
            .map{[weak self] data in
                var now = nowData.value
                now = self!.model.cellDataSave(nowData: now, data: data, index: IndexPath(row: 0, section: 2))
                
                return now
            }
            .bind(to: nowData)
            .disposed(by: self.bag)
        
        scheduler.start()
        
        // THEN
        expect(observer.events).to(
            equal([
                .next(0, []),
                .next(3, [
                    ReportTableViewCellSection(sectionName: "민원 호선", items: [.init(cellTitle: "몇호선 민원을 접수하시겠어요?", cellData: "", type: .Line, focus: false)]),
                    ReportTableViewCellSection(sectionName: "호선 정보", items: [
                        .init(cellTitle: "열차의 행선지를 입력해주세요. (행)", cellData: "인천행", type: .TextField, focus: false),
                        .init(cellTitle: "현재 역을 입력해주세요. (역)", cellData: "시청역", type: .TextField, focus: false),
                        .init(cellTitle: "현재 역이 청량리 ~ 서울역 안에 있나요?", cellData: "Y", type: .TwoBtn, focus: false)
                    ]),
                    ReportTableViewCellSection(sectionName: "상세 정보", items: [
                        .init(cellTitle: "칸 위치나 열차번호를 입력해주세요.", cellData: "", type: .TextField, focus: true)])
                ]),
                .next(7, [
                    ReportTableViewCellSection(sectionName: "민원 호선", items: [.init(cellTitle: "몇호선 민원을 접수하시겠어요?", cellData: "", type: .Line, focus: false)]),
                    ReportTableViewCellSection(sectionName: "호선 정보", items: [
                        .init(cellTitle: "열차의 행선지를 입력해주세요. (행)", cellData: "인천행", type: .TextField, focus: false),
                        .init(cellTitle: "현재 역을 입력해주세요. (역)", cellData: "시청역", type: .TextField, focus: false),
                        .init(cellTitle: "현재 역이 청량리 ~ 서울역 안에 있나요?", cellData: "Y", type: .TwoBtn, focus: false)
                    ]),
                    ReportTableViewCellSection(sectionName: "상세 정보", items: [
                        .init(cellTitle: "칸 위치나 열차번호를 입력해주세요.", cellData: "1-4", type: .TextField, focus: false)])
                ])
            ])
        )
    }
    
    func testTotalStep(){
        // GIVEN
        let scheduler = TestScheduler(initialClock: 0)
        let nowData = PublishRelay<ReportMSGData>()
        let observer = scheduler.createObserver(ReportMSGData.self)
        
        nowData
            .subscribe(observer)
            .disposed(by: self.bag)
        
        // WHEN
        // line
        let line = PublishSubject<ReportBrandData>()
        let lineEvnet = scheduler.createHotObservable([
            .next(1, ReportBrandData.one)
        ])
        
        lineEvnet
            .subscribe(line)
            .disposed(by: self.bag)
        
        // nowStation
        let nowStation = PublishSubject<String>()
        let nowStationEvent = scheduler.createHotObservable([
            .next(3, "시청역")
        ])
        
        nowStationEvent
            .subscribe(nowStation)
            .disposed(by: self.bag)
        
        // destination
        let destination = PublishSubject<String>()
        let destinationEvent = scheduler.createHotObservable([
            .next(5, "인천행")
        ])
        
        destinationEvent
            .subscribe(destination)
            .disposed(by: self.bag)
        
        // brand
        let brand = PublishSubject<String>()
        let brandEvent = scheduler.createHotObservable([
            .next(8, "Y")
        ])
        
        brandEvent
            .subscribe(brand)
            .disposed(by: self.bag)
        
        // trainCar
        let trainCar = PublishSubject<String>()
        let trainCarEvent = scheduler.createHotObservable([
            .next(10, "1-4")
        ])
        
        trainCarEvent
            .subscribe(trainCar)
            .disposed(by: self.bag)
        
        Observable.combineLatest(line, nowStation, destination, trainCar, brand){ line, station, de, train, subwayBrand in
            var brand = subwayBrand
            
            if line != .one || line != .three || line != .four{
                if subwayBrand == "N/A"{
                    brand = "N"
                }
            }
           
            return ReportMSGData(line: line, nowStation: station, destination: de, trainCar: train, contants: "", brand: brand)
        }
        .bind(to: nowData)
        .disposed(by: self.bag)
        
        scheduler.start()
        
        // THEN
        expect(observer.events).to(
            equal([
                .next(10, ReportMSGData(line: .one, nowStation: "시청역", destination: "인천행", trainCar: "1-4", contants: "", brand: "Y"))
            ])
        )
    }
}
