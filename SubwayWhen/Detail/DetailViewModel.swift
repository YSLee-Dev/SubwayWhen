//
//  DetailViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/02.
//

import Foundation

import RxSwift
import RxCocoa

struct DetailViewModel{
    // INPUT
    let detailViewData = PublishRelay<MainTableViewCellData>()
    
    // OUTPUT
    let setTitleText : Driver<String>
    
    let bag = DisposeBag()
    
    init(){
        self.setTitleText = self.detailViewData
            .map{
                "\($0.useLine) \($0.stationName)역"
            }
            .asDriver(onErrorDriveWith: .empty())
    }
}
