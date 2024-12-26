//
//  DetailTableScheduleCellModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/17.
//

import Foundation

import RxSwift
import RxCocoa

class DetailTableScheduleCellModel : DetailTableScheduleCellModelProtocol{
    // INPUT
    let scheduleData = BehaviorRelay<[ResultSchdule]>(value: [])
    let moreBtnClick = PublishRelay<Void>()
    
    // OUTPUT
    let cellData : Driver<[ResultSchdule]>
    
    // NOW
    private let nowData = BehaviorRelay<[ResultSchdule]>(value: [])
    
    let bag = DisposeBag()
    
    init(){
        self.cellData = self.nowData
            .asDriver(onErrorDriveWith: .empty())
        
        self.scheduleData
            .bind(to: self.nowData)
            .disposed(by: self.bag)
    }
}
