//
//  ReportCheckModalViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/27.
//

import Foundation

import RxSwift
import RxCocoa

protocol ReportCheckModalViewModelProtocol{
    var msgData : BehaviorSubject<ReportMSGData>{get}
    var okBtnClick : PublishRelay<Void>{get}
    var msgSeedDismiss : PublishRelay<Void>{get}
    
    // OUTPUT
    var msg : Driver<String>{get}
    var number : Driver<String>{get}
}
 
