//
//  DummyLoad.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/01.
//

import Foundation

@testable import SubwayWhen

let arrivalData = DummyLoad().fileLoad("StationArrivalRequestDummy.json")
let arrivalErrorData = DummyLoad().fileLoad("StationArrivalRequestErrorDummy.json")
let seoulStationSchduleData = DummyLoad().fileLoad("SeoulStationScheduleDummy.json")
let korailStationSchduleData = DummyLoad().fileLoad("KorailStationScheduleDummy.json")
let stationNameSearchData = DummyLoad().fileLoad("StationNameSearchDummy.json")
let vicinityData = DummyLoad().fileLoad("KakaoLocationAPIDummy.json")

let arrivalDummyData = try! JSONDecoder().decode(LiveStationModel.self, from: arrivalData)
let seoulScheduleDummyData = try! JSONDecoder().decode(ScheduleStationModel.self, from: seoulStationSchduleData)
var korailScheduleDummyData : [KorailScdule] = {
    let json = try! JSONDecoder().decode(KorailHeader.self, from: korailStationSchduleData)
    
    let dummySort = json.body.sorted{
        Int($0.time ?? "0") ?? 0 < Int($1.time ?? "1") ?? 1
    }
    return dummySort.filter{
        ((Int(String($0.trainCode.last ?? "9")) ?? 9) % 2) == 1
    }
}()
let stationNameSearcDummyhData = try! JSONDecoder().decode(SearchStaion.self, from: stationNameSearchData)
let vicinityStationsDummyData = try! JSONDecoder().decode(VicinityStationsData.self, from: vicinityData)

let mainCellDummyData = MainTableViewCellData(upDown: "상행", arrivalTime: "100분뒤", previousStation: "", subPrevious: "", code: "1", subWayId: "1003", stationName: "교대", lastStation: "", lineNumber: "1003", isFast: "", useLine: "", group: "", id: "-", stationCode: "340", exceptionLastStation: "", type: .real, backStationId: "1003000339", nextStationId: "1003000341", korailCode: "")


let detailLoadDummyData = DetailLoadData(upDown: "상행", stationName: "교대", lineNumber: "03호선", lineCode: "1003", useLine: "", stationCode: "340", exceptionLastStation: "", backStationId: "1003000339", nextStationId: "1003000341", korailCode: "")

let url = "Test.url"
let arrivalGyodaeStation3Line = SaveStation(id: "-", stationName: "교대", stationCode: "340", updnLine: "상행", line: "03호선", lineCode: "1003", group: .one, exceptionLastStation: "", korailCode: "")
let scheduleGyodaeStation3Line = ScheduleSearch(stationCode: "340", upDown: "상행", exceptionLastStation: "", line: "03호선", type: .Seoul, korailCode: "")
let scheduleK215K1Line = ScheduleSearch(stationCode: "K215", upDown: "하행", exceptionLastStation: "", line: "", type: .Korail, korailCode: "K1")
let searchDeafultList = ["123", "456", "789"]

let urlResponse = HTTPURLResponse(url: URL(string: url)!,
                                  statusCode: 200,
                                  httpVersion: nil,
                                  headerFields: nil)


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
