//
//  ReportMSGData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/21.
//

import Foundation

struct ReportMSGData : Equatable{
    var line : ReportBrandData
    var nowStation : String
    var destination : String
    var trainCar : String
    var contants : String
    var brand : String
}
