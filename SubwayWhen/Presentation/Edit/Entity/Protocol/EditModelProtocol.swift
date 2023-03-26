//
//  EditModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/26.
//

import Foundation

import RxSwift

protocol EditModelProtocol{
    func fixDataToGroupData(_ data : [SaveStation]) -> Single<[EditViewCellSection]>
}
