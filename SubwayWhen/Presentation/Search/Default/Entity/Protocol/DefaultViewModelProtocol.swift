//
//  DefaultViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift
import RxCocoa

protocol DefaultViewModelProtocol{
    var defaultListClick : PublishRelay<String>{get}
    var defaultListData : BehaviorRelay<[DefaultSectionData]>{get}
    var listData : Driver<[DefaultSectionData]>{get}
    var locationBtnTap: PublishSubject<Void>{get}
}
