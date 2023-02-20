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
    let groupOneHourValue = BehaviorRelay<Int>(value: 0)
    let groupTwoHourValue = BehaviorRelay<Int>(value: 0)
    let saveBtnClick = PublishRelay<Void>()
    
    // OUTPUT
    let groupOneDefaultValue : Driver<Int>
    let groupTwoDefaultValue : Driver<Int>
    let modalClose : Driver<Void>
    
    let bag = DisposeBag()
    
    init(){
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
        
        saveClick
            .withLatestFrom(self.groupOneHourValue){
                return $1
            }
            .subscribe(onNext: {
                FixInfo.saveSetting.mainGroupOneTime = $0
            })
            .disposed(by: self.bag)
        
        saveClick
            .withLatestFrom(self.groupTwoHourValue){
                return $1
            }
            .subscribe(onNext: {
                FixInfo.saveSetting.mainGroupTwoTime = $0
            })
            .disposed(by: self.bag)
    }
}
