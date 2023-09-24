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
    
    private let tutorialData = BehaviorRelay<[TutorialSectionData]>(value: [])
    
    let bag = DisposeBag()
    
    init(
        model: TutorialModelProtocol = TutorialModel()
    ) {
        self.model = model
    }
    
    struct Input {
        let scrollRow: Observable<Int>
        let scrollDone: Observable<Void>
    }
    
    struct Output {
        let tutorialData: Driver<[TutorialSectionData]>
        let title: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        self.viewDataSet(input: input)
        
        return Output(
            tutorialData: self.tutorialData
                .asDriver(onErrorDriveWith: .empty()),
            title: input.scrollDone
                .withLatestFrom(input.scrollRow)
                .withUnretained(self)
                .map { viewModel, row in
                    viewModel.tutorialData.value[0].items[row].title
                }
                .asDriver(onErrorDriveWith: .empty())
        )
    }
}

private extension TutorialViewModel {
    func viewDataSet(input: Input) {
        self.model.createTutorialList()
            .bind(to: self.tutorialData)
            .disposed(by: self.bag)
    }
}
