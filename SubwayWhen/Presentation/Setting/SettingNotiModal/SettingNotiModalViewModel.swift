//
//  SettingNotiModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/20.
//

import Foundation

import RxSwift
import RxCocoa
import RxOptional

import UserNotifications

class SettingNotiModalViewModel {
    weak var delegate: SettingNotiModalVCAction?
    let model: SettingNotiModalModelProtocol
    
    private let auth = PublishSubject<Bool>()
    let oneStationTap = BehaviorSubject<SettingNotiModalData>(value: SettingNotiModalData(id: "", stationName: "", useLine: "", line: "", group: .one))
    let twoStationTap = BehaviorSubject<SettingNotiModalData>(value: SettingNotiModalData(id: "", stationName: "", useLine: "", line: "", group: .two))
    
    let bag = DisposeBag()
    
    struct Input {
        let didDisappearAction: PublishSubject<Void>
        let dismissAction: PublishSubject<Void>
        let stationTapAction: PublishSubject<Bool>
    }
    
    struct Output {
        let authSuccess: Driver<Bool>
        let notiStationList: Driver<[SettingNotiModalData]>
        
    }
    
    func transform(input: Input) -> Output {
        self.model.alertIDListLoad()
            .map {
                $0.first
            }
            .filterNil()
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                viewModel.oneStationTap.onNext(data)
            })
            .disposed(by: self.bag)
        
        self.model.alertIDListLoad()
            .map {
                $0.last
            }
            .filterNil()
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                viewModel.twoStationTap.onNext(data)
            })
            .disposed(by: self.bag)
            
            
        input.didDisappearAction
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.didDisappear()
            })
            .disposed(by: self.bag)
        
        input.dismissAction
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.dismiss()
            })
            .disposed(by: self.bag)
        
        input.stationTapAction
            .withUnretained(self)
            .subscribe(onNext: { viewModel, type in
                viewModel.delegate?.stationTap(type: type)
            })
            .disposed(by: self.bag)
        
        let total = Observable.combineLatest(self.oneStationTap, self.twoStationTap) {
            [$0, $1]
        }
        
        input.dismissAction
            .withLatestFrom(total)
            .map {
                $0.map {
                    $0.id
                }
            }
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                viewModel.model.alertIDListSave(data: data)
            })
            .disposed(by: self.bag)
    
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge],
            completionHandler: { [weak self] (granted, _) in
                self?.auth.onNext(granted)
            }
        )
        
        return Output(
            authSuccess: self.auth
                .asDriver(onErrorDriveWith: .empty()),
            notiStationList: total.asDriver(onErrorDriveWith: .empty())
        )
    }
    
    init(
        model: SettingNotiModalModelProtocol
    ) {
        self.model = model
    }
    
    deinit {
        print("SettingNotiModalViewModel DEINIT")
    }
}
