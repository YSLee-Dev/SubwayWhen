//
//  Dummy.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/01.
//

import Foundation

@testable import SubwayWhen

var stationArrivalRequestList : LiveStationModel = Dummy().fileLoad("StationArrivalRequestDummy.json")
var saveStation = "교대"

class Dummy{
    func fileLoad<T:Decodable>(_ fileName : String) -> T{
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
        
        do{
            return try JSONDecoder().decode(T.self, from: data)
        }catch{
            fatalError("Error File 디코딩 할 수 없음")
        }
    }
}
