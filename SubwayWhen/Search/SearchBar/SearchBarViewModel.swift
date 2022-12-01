//
//  SearchBarViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import Foundation

import RxSwift
import RxCocoa

struct SearchBarViewModel{
    // INPUT
    let searchText = PublishRelay<String?>()
    let defaultViewClick = PublishRelay<String>()
    let updnLineClick = PublishRelay<Void>()
    
    // OUTPUT
    let searchStart : Driver<String>
    let searchEnd : Driver<Void>
    
    init(){
        self.searchStart = self.defaultViewClick
            .asDriver(onErrorDriveWith: .empty())
        
        self.searchEnd = self.updnLineClick
            .asDriver(onErrorDriveWith: .empty())
    }
}
