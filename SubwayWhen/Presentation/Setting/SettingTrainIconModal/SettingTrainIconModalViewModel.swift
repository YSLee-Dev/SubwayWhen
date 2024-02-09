//
//  SettingTrainIconModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2/9/24.
//

import Foundation

import RxSwift
import RxCocoa

enum SettingTrainIconModalAction {
    case closeBtnTap
    case viewDidDisappear
}

class SettingTrainIconModalViewModel {
    weak var delegate: SettingTrainIconModalVCAction?
    let bag = DisposeBag()
    
    struct Input {
        let actionList: Observable<SettingTrainIconModalAction>
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        input.actionList
            .bind(onNext: actionProcess)
            .disposed(by: self.bag)
        return Output()
    }
}

private extension SettingTrainIconModalViewModel {
    func actionProcess(type: SettingTrainIconModalAction) {
        switch type {
        case .closeBtnTap:
            self.delegate?.dismiss()
            
        case .viewDidDisappear:
            self.delegate?.didDisappear()
        }
    }
}
