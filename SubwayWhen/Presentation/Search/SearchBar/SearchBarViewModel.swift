//
//  SearchBarViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import Foundation

import RxSwift
import RxCocoa

class SearchBarViewModel : SearchBarViewModelProtocol{
    // INPUT
    let searchText = PublishRelay<String?>()
    let defaultViewClick = PublishRelay<String>()
    let dataTapAction = PublishSubject<Void>()
    
    // OUTPUT
    let searchStart : Driver<String>
    let keyboardClose: Driver<Void>
    
    init(){
        self.searchStart = self.defaultViewClick
            .asDriver(onErrorDriveWith: .empty())
        
        self.keyboardClose = self.dataTapAction
            .asDriver(onErrorDriveWith: .empty())
    }
}
