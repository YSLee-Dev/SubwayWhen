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
    let model: LocationModalModelProtocol
    
    private let modalDismissAction = PublishSubject<Void>()
    private let auth = PublishSubject<Bool>()
    private let bag = DisposeBag()
    
    struct Input {
        let modalCompletion: Observable<Void>
        let okBtnTap: Observable<Void>
        let didDisappear: Observable<Void>
    }
    
    struct Output {
        let modalDismissAnimation: Driver<Void>
        let locationAuthStatus: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        self.vcFlow(input: input)
        self.authCheck()
        
        return Output(
            modalDismissAnimation: self.modalDismissAction
                .asDriver(onErrorDriveWith: .empty()),
            locationAuthStatus: self.auth
                .asDriver(onErrorDriveWith: .empty())
        )
    }
    
    init(
        model: LocationModalModelProtocol = LocationModalModel()
    ) {
        self.model = model
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
    
    func authCheck() {
        self.model.locationAuthCheck()
            .delay(.microseconds(300), scheduler: MainScheduler.asyncInstance)
            .debug()
            .bind(to: self.auth)
            .disposed(by: self.bag)
    }
}
