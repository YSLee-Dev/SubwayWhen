//
//  TagoSchduleStation.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/12.
//

import Foundation

struct TagoSchduleStation : Decodable{
    let response : TagoResponse
}

struct TagoResponse : Decodable{
    let body : Tagobody
}

struct Tagobody : Decodable{
    let items : TagoItems
}

struct TagoItems : Decodable{
    let item : [TagoItem]
}

struct TagoItem : Decodable{
    let arrTime : String
    let endSubwayStationNm : String?
    let endSubwayStationId : String
    let upDownTypeCode : String
    
    enum CodingKeys : String, CodingKey{
        case arrTime
        case endSubwayStationNm
        case upDownTypeCode
        case endSubwayStationId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.upDownTypeCode = try container.decode(String.self, forKey: .upDownTypeCode)
        self.endSubwayStationNm = try container.decodeIfPresent(String.self, forKey: .endSubwayStationNm)
        
        do{
            self.arrTime = try container.decode(String.self, forKey: .arrTime)
        }catch{
            self.arrTime = "\(try container.decode(Int.self, forKey: .arrTime))"
        }
        
        do{
            self.endSubwayStationId = try container.decode(String.self, forKey: .endSubwayStationId)
        }catch{
            self.endSubwayStationId = "\(try container.decode(Int.self, forKey: .endSubwayStationId))"
        }
    }
    
}
