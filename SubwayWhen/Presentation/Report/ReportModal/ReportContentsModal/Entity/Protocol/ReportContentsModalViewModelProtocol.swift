//
//  ReportContentsModalViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift
import RxCocoa


protocol ReportContentsModalViewModelProtocol{
    var msgData : BehaviorSubject<ReportMSGData>{get}
    var close : PublishRelay<Void>{get}
    var contentsTap : PublishRelay<String>{get}
    

    var cellData : Driver<[ReportContentsModalSection]>{get}
    var nextStep : Driver<ReportCheckModalViewModel>{get}
    var twoStepClose : Driver<Void>{get}
    
    
    var model : ReportContentsModalModelProtocol{get}
    var tfViewModel : ReportContentsModalTFViewModelProtocol{get}
    var checkModel : ReportCheckModalViewModelProtocol{get}
}
