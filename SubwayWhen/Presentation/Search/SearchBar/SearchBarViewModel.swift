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
    
    // OUTPUT
    let searchStart : Driver<String>
    
    init(){
        self.searchStart = self.defaultViewClick
            .asDriver(onErrorDriveWith: .empty())
    }
}
