//
//  TutorialViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/09/24.
//

import Foundation

import RxSwift
import RxCocoa

class TutorialViewModel {
    private let model: TutorialModelProtocol
    private let cellModel: TutorialCollectionViewCellModelProtocol
    
    private let tutorialData = BehaviorRelay<[TutorialSectionData]>(value: [])
    private let nowRow = BehaviorRelay<Int>(value: 0)
    
    let bag = DisposeBag()
    
    init(
        model: TutorialModelProtocol = TutorialModel(),
        cellModel: TutorialCollectionViewCellModelProtocol = TutorialCollectionViewCellModel()
    ) {
        self.model = model
        self.cellModel = cellModel
    }
    
    struct Input {
        let scrollRow: Observable<Int>
        let scrollDone: Observable<Void>
    }
    
    struct Output {
        let cellModel: TutorialCollectionViewCellModelProtocol
        let tutorialData: Driver<[TutorialSectionData]>
        let title: Driver<String>
        let nextRow: Driver<Int>
    }
    
    func transform(input: Input) -> Output {
        self.viewDataSet(input: input)
        
        return Output(
            cellModel: self.cellModel,
            tutorialData: self.tutorialData
                .asDriver(onErrorDriveWith: .empty()),
            title: self.nowRow
                .withUnretained(self)
                .map { viewModel, row in
                    viewModel.tutorialData.value[0].items[row].title
                }
                .asDriver(onErrorDriveWith: .empty()),
            nextRow: self.nowRow
                .asDriver(onErrorDriveWith: .empty())
        )
    }
}

private extension TutorialViewModel {
    func viewDataSet(input: Input) {
        self.model.createTutorialList()
            .bind(to: self.tutorialData)
            .disposed(by: self.bag)
        
        input.scrollDone
            .withLatestFrom(input.scrollRow)
            .bind(to: self.nowRow)
            .disposed(by: self.bag)
        
        self.cellModel.nextBtnTap
            .withUnretained(self)
            .map { viewModel, _ in
                let value = viewModel.nowRow.value + 1
                if viewModel.tutorialData.value[0].items.count <= value {
                    return value - 1
                } else {
                    return value
                }
            }
            .bind(to: self.nowRow)
            .disposed(by: self.bag)
    }
}
