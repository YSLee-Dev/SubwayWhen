//
//  SaveStation+.swift
//  SubwayWhen
//
//  Created by 이윤수 on 3/29/24.
//

import Foundation

import RxDataSources

extension SaveStation: IdentifiableType {
    typealias Identity = String
    
    var identity: String {
        self.id
    }
}
