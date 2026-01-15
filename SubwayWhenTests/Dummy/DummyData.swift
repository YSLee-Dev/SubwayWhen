//
//  DummyData.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 11/18/25.
//

import Foundation

@testable import SubwayWhen

let dummyLoad = DummyLoad()
let jsonDecoder = JSONDecoder()

let arrivalData = dummyLoad.fileLoad("StationArrivalRequestDummy.json")
let arrivalErrorData = dummyLoad.fileLoad("StationArrivalRequestErrorDummy.json")
let seoulStationSchduleData = dummyLoad.fileLoad("SeoulStationScheduleDummy.json")
let korailStationSchduleData = dummyLoad.fileLoad("KorailStationScheduleDummy.json")
let stationNameSearchData = dummyLoad.fileLoad("StationNameSearchDummy.json")
let vicinityData = dummyLoad.fileLoad("KakaoLocationAPIDummy.json")
let shinbundangSinsaStationData = dummyLoad.fileLoad("ShinbundangSinsaStationScheduleDummy.json")
let subwayNoticeData = dummyLoad.fileLoad("SubwayNoticeDummy.json")
let subwayNoticeInfiniteData = dummyLoad.fileLoad("SubwayNoticeDummyInfiniteDate.json")
let korailTrainNumberData = dummyLoad.fileLoad("KorailTrainNumberDummy.json")

let arrivalDummyData = try! jsonDecoder.decode(LiveStationModel.self, from: arrivalData)
let seoulScheduleDummyData = try! jsonDecoder.decode(ScheduleStationModel.self, from: seoulStationSchduleData)
let korailHeaderDummyData = try! jsonDecoder.decode(KorailHeader.self, from: korailStationSchduleData)
var korailScheduleDummyData : [KorailScdule] = {
    let json = try! jsonDecoder.decode(KorailHeader.self, from: korailStationSchduleData)
    
    let dummySort = json.body.sorted{
        Int($0.time ?? "0") ?? 0 < Int($1.time ?? "1") ?? 1
    }
    return dummySort.filter{
        ((Int(String($0.trainCode.last ?? "9")) ?? 9) % 2) == 1
    }
}()
let shinbundagSinsaStationScheduleDummyData = try! jsonDecoder.decode([ShinbundangScheduleModel].self, from: shinbundangSinsaStationData)
let seoulScheduleToResultScheduleTransformDummyData = seoulScheduleDummyData.SearchSTNTimeTableByFRCodeService.row
    .map {
        ResultSchdule(startTime: $0.startTime , type: .Seoul, isFast: $0.isFast, startStation: $0.startStation, lastStation: $0.lastStation)
    }

let stationNameSearcDummyhData = try! jsonDecoder.decode(SearchStaion.self, from: stationNameSearchData)
let vicinityStationsDummyData = try! jsonDecoder.decode(VicinityStationsData.self, from: vicinityData)

let totalArrivalDummyData = arrivalDummyData.realtimeArrivalList.map {TotalRealtimeStationArrival(realTimeStationArrival: $0, backStationName: "", nextStationName: "", nowStateMSG: $0.useState)}
let subwayLineData = SubwayLineData(rawValue: "03호선")!
let mainCellDummyData =  MainTableViewCellData(upDown: "상행", arrivalTime: "100분뒤", previousStation: "", subPrevious: "", code: "1",  stationName: "교대", lastStation: "",  isFast: "", group: "", id: "-", stationCode: "340", exceptionLastStation: "", type: .real, backStationId: "1003000339", nextStationId: "1003000341", korailCode: "",  stateMSG: "도착", subwayLineData: subwayLineData)

let detailSendModelDummyData = DetailSendModel(upDown: "상행", stationName: "교대", lineNumber: "03호선", stationCode: "340", lineCode: "1003", exceptionLastStation: "", korailCode: "")

let detailArrivalDataRequestDummyModel = DetailArrivalDataRequestModel(upDown: "상행", stationName: "교대", line: SubwayLineData(rawValue: "03호선")!, exceptionLastStation: "")

let subwayNoticeDummyData = try! jsonDecoder.decode(SubwayNoticeResponse.self, from: subwayNoticeData)
let subwayNoticeInfiniteDummyData = try! jsonDecoder.decode(SubwayNoticeResponse.self, from: subwayNoticeInfiniteData)

let url = "Test.url"
let arrivalGyodaeStation3Line = SaveStation(id: "-", stationName: "교대", stationCode: "340", updnLine: "상행", line: "03호선", lineCode: "1003", group: .one, exceptionLastStation: "", korailCode: "")
let scheduleGyodaeStation3Line = ScheduleSearch(stationCode: "340", upDown: "상행", exceptionLastStation: "", line: "03호선", korailCode: "", stationName: "교대")
let scheduleK215K1Line = ScheduleSearch(stationCode: "K215", upDown: "하행", exceptionLastStation: "", line: "", korailCode: "K1", stationName: "선릉")
let scheduleSinsaShinbundagLine = ScheduleSearch(stationCode: "D04", upDown: "하행", exceptionLastStation: "", line: "신분당선", korailCode: "", stationName: "신사")
let searchDeafultList = ["교대", "강남", "서초"]
let locationData = LocationData(lat: 37.49388026940836, lon: 127.01360357128935)
let vicinityTransformData: [VicinityTransformData] =  [
    .init(id: "1", name: "교대", line: "3호선", distance: "1000m"),
    .init(id: "2", name: "강남", line: "2호선", distance: "1500m"),
    .init(id: "3", name: "고속터미널", line: "9호선", distance: "2000m"),
    .init(id: "4", name: "사당", line: "4호선", distance: "3000m")
]
let searchQueryRecommend = [
    SearchQueryRecommendData(queryName: "강남", stationName: "강남구청", line: "7, 수인"),
    SearchQueryRecommendData(queryName: "마포", stationName: "마포구청", line: "6")
]

let subwayNotice = SubwayNotice(title: "4호선 혜화역 하선 열차 무정차 통과 종료", content: "4호선 혜화역 특정장애인단체 불법시위로 인한 하선 열차 무정차 통과는 09:30분부로 종료되어 열차 정상운행 중입니다. 11-12 09:13:09 11-17 09:33:01", occurredAt: "2025-11-17T09:33:01", lineNames: "4호선", createdDate: "20251117", isNonstop: "Y", direction: "하행", exceptionEndedAt: "2025-11-17T09:30:00")
let subwayNoticeInfiniteDate = SubwayNotice(title: "4호선 혜화역 하선 열차 무정차 통과 종료", content: "4호선 혜화역 특정장애인단체 불법시위로 인한 하선 열차 무정차 통과는 09:30분부로 종료되어 열차 정상운행 중입니다. 11-12 09:13:09 11-17 09:33:01", occurredAt: "2099-11-17T09:33:01", lineNames: "4호선", createdDate: "20991117", isNonstop: "Y", direction: "하행", exceptionEndedAt: "2099-11-17T09:30:00")
let importantData = ImportantData(title: "4호선 혜화역 하선 열차 무정차 통과 종료", contents: "4호선 혜화역 특정장애인단체 불법시위로 인한 하선 열차 무정차 통과는 09:30분부로 종료되어 열차 정상운행 중입니다. 11-12 09:13:09 11-17 09:33:01호선: 4호선무정차 통과: O상하행: 하행")
let korailTrainNumber = try! jsonDecoder.decode(DummyKorailTrainValue.self, from: korailTrainNumberData).value

let urlResponse = HTTPURLResponse(
    url: URL(string: url)!,
    statusCode: 200,
    httpVersion: nil,
    headerFields: nil
)

let congestionStations = ["강남", "시청"]
let weakDayCongestionData: [String: CongestionLevel] = [
    "0": CongestionLevel(percent: 20, level: 2),
    "1": CongestionLevel(percent: 0, level: 0),
    "2": CongestionLevel(percent: 0, level: 0),
    "3": CongestionLevel(percent: 0, level: 0),
    "4": CongestionLevel(percent: 0, level: 0),
    "5": CongestionLevel(percent: 30, level: 3),
    "6": CongestionLevel(percent: 60, level: 6),
    "7": CongestionLevel(percent: 90, level: 9),
    "8": CongestionLevel(percent: 100, level: 10),
    "9": CongestionLevel(percent: 85, level: 9),
    "10": CongestionLevel(percent: 65, level: 7),
    "11": CongestionLevel(percent: 70, level: 7),
    "12": CongestionLevel(percent: 80, level: 8),
    "13": CongestionLevel(percent: 75, level: 8),
    "14": CongestionLevel(percent: 60, level: 6),
    "15": CongestionLevel(percent: 65, level: 7),
    "16": CongestionLevel(percent: 70, level: 7),
    "17": CongestionLevel(percent: 85, level: 9),
    "18": CongestionLevel(percent: 100, level: 10),
    "19": CongestionLevel(percent: 95, level: 10),
    "20": CongestionLevel(percent: 80, level: 8),
    "21": CongestionLevel(percent: 65, level: 7),
    "22": CongestionLevel(percent: 50, level: 5),
    "23": CongestionLevel(percent: 35, level: 4)
]

let weekendCongestionData: [String: CongestionLevel] = [
    "0": CongestionLevel(percent: 20, level: 2),
    "1": CongestionLevel(percent: 0, level: 0),
    "2": CongestionLevel(percent: 0, level: 0),
    "3": CongestionLevel(percent: 0, level: 0),
    "4": CongestionLevel(percent: 0, level: 0),
    "5": CongestionLevel(percent: 15, level: 2),
    "6": CongestionLevel(percent: 20, level: 2),
    "7": CongestionLevel(percent: 25, level: 3),
    "8": CongestionLevel(percent: 30, level: 3),
    "9": CongestionLevel(percent: 35, level: 4),
    "10": CongestionLevel(percent: 45, level: 5),
    "11": CongestionLevel(percent: 55, level: 6),
    "12": CongestionLevel(percent: 60, level: 6),
    "13": CongestionLevel(percent: 65, level: 7),
    "14": CongestionLevel(percent: 70, level: 7),
    "15": CongestionLevel(percent: 70, level: 7),
    "16": CongestionLevel(percent: 65, level: 7),
    "17": CongestionLevel(percent: 65, level: 7),
    "18": CongestionLevel(percent: 70, level: 7),
    "19": CongestionLevel(percent: 65, level: 7),
    "20": CongestionLevel(percent: 60, level: 6),
    "21": CongestionLevel(percent: 50, level: 5),
    "22": CongestionLevel(percent: 40, level: 4),
    "23": CongestionLevel(percent: 30, level: 3)
]

let congestionData = CongestionDataSet(stations: [
    "강남" : .init(hourlyCongestion: .init(
        weekday: weakDayCongestionData,
        saturday: weekendCongestionData,
        sunday: weekendCongestionData
    )),
    "시청" : .init(hourlyCongestion: .init(
        weekday: [:],
        saturday: [:],
        sunday: [:]
    ))
])
