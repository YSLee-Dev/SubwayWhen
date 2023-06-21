//
//  SettingNotiSelectModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/21.
//

import Foundation

import RxSwift
import RxCocoa

class SettingNotiSelectModalViewModel {
    weak var delegate: SettingNotiSelectModalVCAction?
    let bag = DisposeBag()
    
    struct Input {
        let didDisappearAction: PublishSubject<Void>
        let popAction: PublishSubject<Void>
    }
    
    struct Output {
    
    }
    
    func transform(input: Input) -> Output {
        input.didDisappearAction
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.didDisappear()
            })
            .disposed(by: self.bag)
        
        input.popAction
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.pop()
            })
            .disposed(by: self.bag)
        
        return Output()
    }
    
    init (
    
    ) {
        
    }
}
