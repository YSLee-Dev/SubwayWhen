//
//  ReportViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift
import RxCocoa

protocol ReportViewModelProtocol{
    var cellData : Driver<[ReportTableViewCellSection]>{get}
    var keyboardClose : Driver<Void>{get}
    var scrollSction : Driver<Int>{get}
    var checkModalViewModel : Driver<ReportContentsModalViewModelProtocol>{get}
    var popVC : Driver<Void>{get}
    
    var nowData : BehaviorRelay<[ReportTableViewCellSection]>{get}
    var nowStep : PublishRelay<Int>{get}
    var msgData : PublishRelay<ReportMSGData>{get}
    var checkModalViewModelData : PublishRelay<ReportContentsModalViewModelProtocol>{get}
    
    var lineCellModel : ReportTableViewLineCellModelProtocol{get}
    var textFieldCellModel : ReportTableViewTextFieldCellModelProtocol{get}
    var twoBtnCellModel : ReportTableViewTwoBtnCellModelProtocol{get}
    var model : ReportModelProtocol{get}
    var contentsModalViewModel : ReportContentsModalViewModelProtocol{get}
}
