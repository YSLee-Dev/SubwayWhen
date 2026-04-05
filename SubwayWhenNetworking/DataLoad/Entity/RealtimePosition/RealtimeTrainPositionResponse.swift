//
//  RealtimeTrainPositionResponse.swift
//  SubwayWhenNetworking
//
//  Created by 이윤수 on 2026/04/05.
//

import Foundation

struct RealtimeTrainPositionResponse: Decodable {
    let realtimePositionList: [RealtimeTrainPosition]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.realtimePositionList = (try? container.decode([RealtimeTrainPosition].self, forKey: .realtimePositionList)) ?? []
    }

    enum CodingKeys: String, CodingKey {
        case realtimePositionList
    }
}
