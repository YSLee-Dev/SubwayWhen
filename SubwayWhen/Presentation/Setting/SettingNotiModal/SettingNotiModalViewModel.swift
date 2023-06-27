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
        let okBtnTap: Observable<Void>
    }
    
    struct Output {
        let authSuccess: Driver<Bool>
        let notiStationList: Driver<[SettingNotiModalData]>
        
    }
    
    func transform(input: Input) -> Output {
        self.saveListLoad()
        self.authCheck()
        
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
        
        let oneTap = input.stationTapAction
            .filter {$0}
            .withLatestFrom(self.oneStationTap)
        
        let twoTap = input.stationTapAction
            .filter {!$0}
            .withLatestFrom(self.twoStationTap)
        
         Observable.merge(oneTap, twoTap)
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                viewModel.delegate?.stationTap(type: data.group, id: data.id)
            })
            .disposed(by: self.bag)
        
        let total = Observable.combineLatest(self.oneStationTap, self.twoStationTap) {
            [$0, $1]
        }
        
        input.okBtnTap
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

private extension SettingNotiModalViewModel {
    func authCheck() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge],
            completionHandler: { [weak self] (granted, _) in
                self?.auth.onNext(granted)
            }
        )
    }
    
    func saveListLoad() {
        self.model.alertIDListLoad()
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                let nilData = SettingNotiModalData(id: "", stationName: "", useLine: "", line: "", group: .one)
                let nilDataTwo = SettingNotiModalData(id: "", stationName: "", useLine: "", line: "", group: .two)
                
                viewModel.oneStationTap.onNext(data.first ?? nilData)
                viewModel.twoStationTap.onNext(data.last ?? nilDataTwo)
            })
            .disposed(by: self.bag)
            
    }
}
