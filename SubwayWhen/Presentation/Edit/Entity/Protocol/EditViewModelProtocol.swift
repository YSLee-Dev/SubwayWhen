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
    var editModel : EditModelProtocol{get}
    
    // INPUT
    var deleteCell : PublishRelay<String>{get}
    var refreshOn : PublishRelay<Void>{get}
    var moveCell : PublishRelay<ItemMovedEvent>{get}
    
    // OUTPUT
    var cellData : Driver<[EditViewCellSection]>{get}
    
    // VALUE
    var nowData : BehaviorSubject<[EditViewCellSection]>{get}
}
