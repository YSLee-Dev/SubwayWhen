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
    let defaultListData = BehaviorRelay<[String]>(value: [""])
    
    // OUTPUT
    let listData : Driver<[String]>
    
    init(){
        self.listData = self.defaultListData
            .asDriver()
    }
}
