//
//  ReportContentsModalTFViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/27.
//

import Foundation

import RxSwift

protocol ReportContentsModalTFViewModelProtocol {
    var inputText : PublishSubject<String> {get}
    
}
