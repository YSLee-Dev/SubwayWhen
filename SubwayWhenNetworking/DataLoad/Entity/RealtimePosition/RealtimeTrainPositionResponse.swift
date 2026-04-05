//
//  RealtimeTrainPositionResponse.swift
//  SubwayWhenNetworking
//
//  Created by 이윤수 on 2026/04/05.
//

import Foundation

struct RealtimeTrainPositionResponse: Decodable {
    let errorMessage: ErrorMessage
    let realtimePositionList: [RealtimeTrainPosition]

    struct ErrorMessage: Decodable {
        let status: Int
        let code: String
        let message: String
        let total: Int
    }
}
