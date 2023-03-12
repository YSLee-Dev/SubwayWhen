//
//  TotalStationSearch.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/11.
//

import Foundation

struct TotalStationSearch : Decodable{
    let response : Response
}

struct Response : Decodable {
    let body : Body
}

struct Body : Decodable{
    let items : StationItems
}

struct StationItems : Decodable{
    let item : [StationItem]
   
    private enum CodingKeys : String, CodingKey{
        case item
    }
    
    init(from decoder : Decoder) throws {
        let con = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.item = try con.decode([StationItem].self, forKey: .item)
        }catch{
            self.item = try [con.decode(StationItem.self, forKey: .item)]
        }
    }
}

struct StationItem : Decodable{
    let subwayRouteName : String
    let subwayStationId : String
    let subwayStationName : String
}
