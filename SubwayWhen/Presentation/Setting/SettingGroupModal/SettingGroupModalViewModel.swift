//
//  SettingGroupModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/17.
//

import Foundation

import RxSwift
import RxCocoa

import FirebaseAnalytics

class SettingGroupModalViewModel : SettingGroupModalViewModelProtocol{
    
    deinit{
        print("SettingGroupModalViewModel DEINIT")
    }
    
    // INPUT
    let groupOneHourValue = BehaviorRelay<Int>(value: 0)
    let groupTwoHourValue = BehaviorRelay<Int>(value: 0)
    let saveBtnClick = PublishRelay<Void>()
    
    // OUTPUT
    let groupOneDefaultValue : Driver<Int>
    let groupTwoDefaultValue : Driver<Int>
    let modalClose : Driver<Void>
    
    let bag = DisposeBag()
    
    let notiManager: NotificationManagerProtocol
    
    init(
        noti: NotificationManagerProtocol = NotificationManager.shared
    ){
        self.notiManager = noti
    
        self.groupOneDefaultValue = Observable<Int>.create{
            $0.onNext(FixInfo.saveSetting.mainGroupOneTime)
            $0.onCompleted()
            return Disposables.create()
        }
        .asDriver(onErrorDriveWith: .empty())
        
        self.groupTwoDefaultValue = Observable<Int>.create{
            $0.onNext(FixInfo.saveSetting.mainGroupTwoTime)
            $0.onCompleted()
            return Disposables.create()
        }
        .asDriver(onErrorDriveWith: .empty())
        
        let saveClick = self.saveBtnClick
            .share()
        
        self.modalClose = saveClick
            .asDriver(onErrorDriveWith: .empty())
        
        let hourValue = Observable.combineLatest(self.groupOneHourValue, self.groupTwoHourValue)
        
        saveClick
            .withLatestFrom(hourValue)
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                FixInfo.saveSetting.mainGroupOneTime = data.0
                FixInfo.saveSetting.mainGroupTwoTime = data.1
                viewModel.notiManager.notiTimeChange()
            })
            .disposed(by: self.bag)
        
        // 구글 애널리틱스
        saveClick
            .subscribe(onNext: {[weak self] _ in
                let one = self?.groupOneHourValue.value ?? 0
                let two = self?.groupTwoHourValue.value ?? 0
                Analytics.logEvent("SettingVC_Group_Save", parameters: [
                    "Group_One" : one,
                    "Group_Two" : two
                ])
            })
            .disposed(by: self.bag)
    }
}
