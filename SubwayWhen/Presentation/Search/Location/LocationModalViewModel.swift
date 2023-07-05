//
//  LocationModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/05.
//

import Foundation

import RxSwift
import RxCocoa

class LocationModalViewModel {
    weak var delegate: LocationModalVCActionProtocol?
    
    private let modalDismissAction = PublishSubject<Void>()
    private let bag = DisposeBag()
    
    struct Input {
        let modalCompletion: Observable<Void>
        let okBtnTap: Observable<Void>
        let didDisappear: Observable<Void>
    }
    
    struct Output {
        let modalDismissAnimation: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        self.vcFlow(input: input)
        
        return Output(
            modalDismissAnimation: self.modalDismissAction
                .asDriver(onErrorDriveWith: .empty())
        )
    }
    
    init() {
        
    }
}

extension LocationModalViewModel {
    func vcFlow(input: Input) {
        input.okBtnTap
            .bind(to: self.modalDismissAction)
            .disposed(by: self.bag)
        
        input.modalCompletion
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.dismiss()
            })
            .disposed(by: self.bag)
        
        input.didDisappear
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.didDisappear()
            })
            .disposed(by: self.bag)
    }
}
