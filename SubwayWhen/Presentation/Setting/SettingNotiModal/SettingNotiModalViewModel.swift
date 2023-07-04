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
    let notiManager: NotificationManagerProtocol
    
    private let auth = PublishSubject<Bool>()
    let oneStationTap = BehaviorSubject<NotificationManagerRequestData>(value: NotificationManagerRequestData(id: "", stationName: "", useLine: "", line: "", group: .one))
    let twoStationTap = BehaviorSubject<NotificationManagerRequestData>(value: NotificationManagerRequestData(id: "", stationName: "", useLine: "", line: "", group: .two))
    
    let bag = DisposeBag()
    
    struct Input {
        let didDisappearAction: PublishSubject<Void>
        let dismissAction: PublishSubject<Void>
        let stationTapAction: PublishSubject<Bool>
        let okBtnTap: Observable<Void>
        let groupTimeGoBtnTap: Observable<Void>
    }
    
    struct Output {
        let authSuccess: Driver<Bool>
        let notiStationList: Driver<[NotificationManagerRequestData]>
        
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
        
        input.groupTimeGoBtnTap
            .withUnretained(self)
            .delay(.milliseconds(250), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.groupTimeGoBtnTap()
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
        
        let okBtnTap = input.okBtnTap
            .withLatestFrom(total)
            .share()
        
        okBtnTap
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
        
        okBtnTap
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                viewModel.notiManager.notiAllRemove()
                
                // 0.5 초 이후 (삭제 이후)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    data.forEach{
                        viewModel.notiManager.notiScheduleAdd(data: $0)
                    }
                }
            })
            .disposed(by: self.bag)
        
        return Output(
            authSuccess: self.auth
                .asDriver(onErrorDriveWith: .empty()),
            notiStationList: total.asDriver(onErrorDriveWith: .empty())
        )
    }
    
    init(
        model: SettingNotiModalModelProtocol,
        notiManager: NotificationManagerProtocol
    ) {
        self.model = model
        self.notiManager = notiManager
    }
    
    deinit {
        print("SettingNotiModalViewModel DEINIT")
    }
}

private extension SettingNotiModalViewModel {
    func authCheck() {
        self.notiManager.authCheck()
            .delay(.microseconds(300), scheduler: MainScheduler.asyncInstance)
            .bind(to: self.auth)
            .disposed(by: self.bag)
    }
    
    func saveListLoad() {
        self.notiManager.alertIDListLoad()
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                let nilData = NotificationManagerRequestData(id: "", stationName: "", useLine: "", line: "", group: .one)
                let nilDataTwo = NotificationManagerRequestData(id: "", stationName: "", useLine: "", line: "", group: .two)
                
                viewModel.oneStationTap.onNext(data.first ?? nilData)
                viewModel.twoStationTap.onNext(data.last ?? nilDataTwo)
            })
            .disposed(by: self.bag)
            
    }
}
