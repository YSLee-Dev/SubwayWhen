//
//  EditViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift
import RxCocoa

protocol EditViewModelProtocol{
    // INPUT
    var deleteCell : PublishRelay<String>{get}
    var refreshOn : PublishRelay<Void>{get}
    var moveCell : PublishRelay<ItemMovedEvent>{get}
    
    // OUTPUT
    var cellData : Driver<[EditViewCellSection]>{get}
}
