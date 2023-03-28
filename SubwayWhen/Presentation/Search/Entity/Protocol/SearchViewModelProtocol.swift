//
//  SearchViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift
import RxCocoa

protocol SearchViewModelProtocol{
    var serachBarViewModel : SearchBarViewModelProtocol{get}
    var resultViewModel : ResultViewModelProtocol{get}
    var defaultViewModel : DefaultViewModelProtocol{get}
    var model : SearchModelProtocol{get}
    
    var modalData : Driver<ResultVCCellData>{get}
    
    var defaultData : BehaviorSubject<[String]>{get}
    var nowData : BehaviorRelay<[ResultVCSection]>{get}
}
