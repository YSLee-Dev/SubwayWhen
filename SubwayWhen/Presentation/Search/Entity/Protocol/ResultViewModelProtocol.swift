//
//  ResultViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift
import RxCocoa

protocol ResultViewModelProtocol{
    var cellData : Driver<[ResultVCSection]>{get}
    var cellClick : PublishRelay<IndexPath>{get}
    var resultData : PublishRelay<[ResultVCSection]>{get}
}
