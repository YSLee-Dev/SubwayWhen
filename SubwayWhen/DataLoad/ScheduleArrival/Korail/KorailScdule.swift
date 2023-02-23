//
//  KorailBody.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/22.
//

import Foundation

struct KorailScdule : Decodable{
    let time : String
    let trainCode : String
    let lineCode : String
    
    enum CodingKeys : String, CodingKey {
        case time = "dptTm"
        case trainCode = "trnNo"
        case lineCode = "lnCd"
    }
}
