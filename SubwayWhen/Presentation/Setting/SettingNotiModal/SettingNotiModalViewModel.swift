//
//  SettingNotiModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/20.
//

import Foundation

import RxSwift
import RxCocoa

import UserNotifications

class SettingNotiModalViewModel {
    private let auth = PublishSubject<Bool>()
    let bag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        let authSuccess: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        
        return Output(
            authSuccess: self.auth
                .asDriver(onErrorDriveWith: .empty())
        )
    }
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge],
            completionHandler: { [weak self] (granted, _) in
                self?.auth.onNext(granted)
            }
        )
    }
}
