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
    var scheduleData : PublishRelay<[ResultSchdule]>{get}
    var moreBtnClick : PublishRelay<Void>{get}
    
    // OUTPUT
    var cellData : Driver<[ResultSchdule]>{get}
}
