//
//  DetailModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/22.
//

import Foundation

protocol DetailModelProtocol{
    func nextAndBackStationSearch(backId : String, nextId : String) -> [String]
}
