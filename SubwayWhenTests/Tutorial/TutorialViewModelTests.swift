//
//  TutorialViewModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 10/6/23.
//

import UIKit

import XCTest
import RxSwift
import RxCocoa
import RxTest
import Nimble

@testable import SubwayWhen

class TutorialViewModelTests: XCTestCase {
    var model: TutorialModelProtocol!
    var viewModel: TutorialViewModel!
    var celLModel: TutorialCollectionViewCellModelProtocol!
    
    let bag = DisposeBag()
    
    override func setUp() {
        self.model = TutorialModel()
        self.celLModel = TutorialCollectionViewCellModel()
        self.viewModel = TutorialViewModel(
            model: self.model,
            cellModel: self.celLModel
        )
    }
    
    func testCellScrollORBtnTap() {
        // GIVEN
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Int.self)
        let scrollRow = PublishSubject<Int>()
        
        let input = TutorialViewModel.Input (
            scrollRow: scrollRow.asObservable(),
            disappear: Observable.empty()
            )
        let output = self.viewModel.transform(input: input)
        output
            .nextRow
            .asObservable()
            .subscribe(observer)
            .disposed(by: self.bag)
        
        // WHEN
        scheduler.createColdObservable([
            .next(2, Void()),
            .next(4, Void()),
            .next(6, Void()),
            .next(8, Void()),
            .next(10, Void())
        ])
        .bind(to: self.celLModel.nextBtnTap)
        .disposed(by: self.bag)
        
        scheduler.createColdObservable([
            .next(0, 1),
            .next(1, 2),
            .next(2, 3),
            .next(3, 2),
            .next(4, 3),
            .next(5, 4),
            .next(5, 5),
            .next(6, 4),
            .next(7, 3),
            .next(8, 4),
            .next(9, 5),
            .next(9, 6),
            .next(9, 7)
        ])
        .bind(to: scrollRow)
        .disposed(by: self.bag)
        
        scheduler.start()
        
        // THEN
        // 이벤트는 버튼을 눌렀을 때만 나옴
        expect(observer.events).to(
            equal([
                .next(2, 3),
                .next(4, 3),
                .next(6, 6),
                .next(8, 4)
            ])
        )
    }
}
