//
//  DummyLoad.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/01.
//

import Foundation

@testable import SubwayWhen

let arrivalData = DummyLoad().fileLoad("StationArrivalRequestDummy.json")
let seoulStationSchdulData = DummyLoad().fileLoad("SeoulStationScheduleLoadDummy.json")

class DummyLoad{
    func fileLoad(_ fileName : String) -> Data{
        let data : Data
        let bundle = Bundle(for: type(of: self))
        
        guard let file = bundle.url(forResource: fileName, withExtension: nil) else {
            fatalError("Error File을 불러올 수 없음")
        }
        
        do{
            data = try Data(contentsOf: file)
        }catch{
            fatalError("Error File을 불러올 수 없음")
        }
        
        return data
    }
}
