//
//  ModalViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift
import RxCocoa

protocol ModalViewModelProtocol{
    // OUTPUT
    var modalData : Driver<ResultVCCellData>{get}
    var modalClose : Driver<Void>{get}
    var alertShow : Driver<Void>{get}
    var saveComplete : Driver<Void>{get}
    var disposableDetailMove : Driver<DetailLoadData>{get}
    
    // INPUT
    var overlapOkBtnTap : PublishRelay<Void>{get}
    var clickCellData : PublishRelay<ResultVCCellData>{get}
    var upDownBtnClick : PublishRelay<Bool>{get}
    var notService : PublishRelay<Void>{get}
    var groupClick : BehaviorRelay<SaveStationGroup>{get}
    var exceptionLastStationText: BehaviorRelay<String?>{get}
    var disposableBtnTap : PublishRelay<Bool>{get}
}
