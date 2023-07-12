//
//  DefaultViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/29.
//

import Foundation

import RxSwift
import RxCocoa

class DefaultViewModel : DefaultViewModelProtocol{
    // INPUT
    let defaultListClick = PublishRelay<String>()
    let defaultListData = BehaviorRelay<[DefaultSectionData]>(value: [])
    let locationBtnTap = PublishSubject<Void>()
    
    // OUTPUT
    let listData : Driver<[DefaultSectionData]>
    
    init(){
        self.listData = self.defaultListData
            .asDriver()
    }
}
