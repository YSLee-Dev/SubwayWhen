//
//  VicinityDocumentData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/05.
//

import Foundation

struct VicinityDocumentData: Decodable, Equatable {
    let name: String
    let distance: String
    let category: String
    
    enum CodingKeys: String, CodingKey {
        case name = "place_name"
        case distance = "distance"
        case category = "category_group_code"
    }
    
}
