//
//  ReportContentsModalModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/27.
//

import Foundation

import RxSwift

protocol ReportContentsModalModelProtocol{
    func reportList() -> Observable<[ReportContentsModalSection]>
}
