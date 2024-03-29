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
    private let nextRow = BehaviorRelay<Int>(value: 0)
    
    weak var delegate: TutorialVCAction?
    let bag = DisposeBag()
    
    init(
        model: TutorialModelProtocol = TutorialModel(),
        cellModel: TutorialCollectionViewCellModelProtocol = TutorialCollectionViewCellModel()
    ) {
        self.model = model
        self.cellModel = cellModel
    }
    
    deinit {
        print("TutorialViewModel DEINIT")
    }
    
    struct Input {
        let scrollRow: Observable<Int>
        let disappear: Observable<Void>
    }
    
    struct Output {
        let cellModel: TutorialCollectionViewCellModelProtocol
        let tutorialData: Driver<[TutorialSectionData]>
        let nextRow: Driver<Int>
        let lastRow: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        self.viewDataSet(input: input)
        self.flowLogic(input: input)
        
        return Output(
            cellModel: self.cellModel,
            tutorialData: self.tutorialData
                .asDriver(onErrorDriveWith: .empty()),
            nextRow: self.cellModel.nextBtnTap
                .withLatestFrom(self.nextRow)
                .filter {$0 != -1}
                .asDriver(onErrorDriveWith: .empty()),
            lastRow: self.nextRow
                .map {$0 == -1}
                .asDriver(onErrorDriveWith: .empty())
        )
    }
}

private extension TutorialViewModel {
    func viewDataSet(input: Input) {
        self.model.createTutorialList()
            .bind(to: self.tutorialData)
            .disposed(by: self.bag)
        
        input.scrollRow
            .withUnretained(self)
            .map { viewModel, row in
                if viewModel.tutorialData.value[0].items.count <= row + 1{
                    return -1
                } else {
                    return row + 1
                }
            }
            .bind(to: self.nextRow)
            .disposed(by: self.bag)
    }
    
    func flowLogic(input: Input) {
        input.disappear
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.didDisappear()
            })
            .disposed(by: self.bag)
        
        self.cellModel.nextBtnTap
            .withLatestFrom(self.nextRow)
            .filter {$0 == -1}
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.lastBtnTap()
            })
            .disposed(by: self.bag)
    }
}
