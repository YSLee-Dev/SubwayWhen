//
//  SearchBarViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift
import RxCocoa

protocol SearchBarViewModelProtocol{
    var searchText : PublishRelay<String?>{get}
    var defaultViewClick : PublishRelay<String>{get}
    var searchStart : Driver<String>{get}
}
