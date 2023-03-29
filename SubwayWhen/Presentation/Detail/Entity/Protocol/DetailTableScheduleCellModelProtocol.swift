//
//  DetailTableScheduleCellModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/22.
//

import Foundation

import RxSwift
import RxCocoa

protocol DetailTableScheduleCellModelProtocol{
    var scheduleData : BehaviorRelay<[ResultSchdule]>{get}
    var moreBtnClick : PublishRelay<Void>{get}
    
    var cellData : Driver<[ResultSchdule]>{get}
    
    var nowData : BehaviorRelay<[ResultSchdule]>{get}
}
