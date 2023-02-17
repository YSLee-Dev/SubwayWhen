//
//  SettingGroupModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/17.
//

import Foundation

import RxSwift
import RxCocoa

class SettingGroupModalViewModel{
    // INPUT
    let groupOneHourValue = BehaviorRelay<Double>(value: 0.0)
    let groupTwoHourValue = BehaviorRelay<Double>(value: 0.0)
    let saveBtnClick = PublishRelay<Void>()
    
    // OUTPUT
    let groupOneDefaultValue : Driver<Double>
    let groupTwoDefaultValue : Driver<Double>
    let modalClose : Driver<Void>
    
    let bag = DisposeBag()
    
    init(){
        self.groupOneDefaultValue = Observable<Double>.create{
            $0.onNext(Double(FixInfo.saveSetting.mainGroupOneTime))
            $0.onCompleted()
            return Disposables.create()
        }
        .asDriver(onErrorDriveWith: .empty())
        
        self.groupTwoDefaultValue = Observable<Double>.create{
            $0.onNext(Double(FixInfo.saveSetting.mainGroupTwoTime))
            $0.onCompleted()
            return Disposables.create()
        }
        .asDriver(onErrorDriveWith: .empty())
        
        let saveClick = self.saveBtnClick
            .share()
        
        self.modalClose = saveClick
            .asDriver(onErrorDriveWith: .empty())
        
        saveClick
            .withLatestFrom(self.groupOneHourValue){
                return $1
            }
            .subscribe(onNext: {
                FixInfo.saveSetting.mainGroupOneTime = Int($0)
            })
            .disposed(by: self.bag)
        
        saveClick
            .withLatestFrom(self.groupTwoHourValue){
                return $1
            }
            .subscribe(onNext: {
                FixInfo.saveSetting.mainGroupTwoTime = Int($0)
            })
            .disposed(by: self.bag)
    }
}
