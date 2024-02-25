//
//  SettingTrainIconModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2/9/24.
//

import Foundation

import RxSwift
import RxCocoa

import Combine

enum SettingTrainIconModalAction {
    case closeBtnTap
    case viewDidDisappear
    case okBtnTap
}

class SettingTrainIconModalViewModel {
    private let subViewModel: SettingTrainIconModalSubViewModel
    
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
        
        self.subViewModel.isTappedIndex = self.trainIconToIndex(iconString: FixInfo.saveSetting.detailVCTrainIcon)
        
        return Output()
    }
    
    init(
        subViewModel: SettingTrainIconModalSubViewModel
    ) {
        self.subViewModel = subViewModel
    }
}

private extension SettingTrainIconModalViewModel {
    func actionProcess(type: SettingTrainIconModalAction) {
        switch type {
        case .closeBtnTap:
            self.delegate?.dismiss()
            
        case .viewDidDisappear:
            self.delegate?.didDisappear()
            
        case .okBtnTap:
            FixInfo.saveSetting.detailVCTrainIcon = self.indexToTrainIcon(index: self.subViewModel.isTappedIndex)
        }
    }
    
    func trainIconToIndex(iconString: String) -> Int {
        switch iconString {
        case "🚂": 1
        case "🚈": 2
        case "🚅": 3
        default: 0
        }
    }
    
    func indexToTrainIcon(index: Int) -> String {
        switch index {
        case 1: "🚂"
        case 2: "🚈"
        case 3: "🚅"
        default: "🚃"
        }
    }
}
