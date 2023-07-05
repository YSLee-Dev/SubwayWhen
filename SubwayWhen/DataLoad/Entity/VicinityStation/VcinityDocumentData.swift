//
//  VcinityDocumentData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/05.
//

import Foundation

struct VcinityDocumentData: Decodable {
    let name: String
    let distance: String
    
    enum CodingKeys: String, CodingKey {
        case name = "place_name"
        case distance = "distance"
    }
    
}
