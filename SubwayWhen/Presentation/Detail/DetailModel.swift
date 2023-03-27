//
//  DetailModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/04.
//

import Foundation

import RxSwift

class DetailModel : DetailModelProtocol{
    
    let model: TotalLoadProtocol
    
    init(totalLoadModel : TotalLoadModel = .init()){
        self.model = totalLoadModel
    }
    
    func nextAndBackStationSearch(backId : String, nextId : String) -> [String]{
        var backStation : String = ""
        var nextStation : String = ""
        
        guard let fileUrl = Bundle.main.url(forResource: "DetailStationIdList", withExtension: "plist") else {return  [backStation, nextStation]}
        guard let data = try? Data(contentsOf: fileUrl) else {return  [backStation, nextStation]}
        guard let decodingData = try? PropertyListDecoder().decode([DetailStationId].self, from: data) else {return  [backStation, nextStation]}
        
        for x in decodingData{
            if x.stationId == backId{
                backStation = x.stationName
            }
            
            if x.stationId == nextId{
                nextStation = x.stationName
            }
            
            if backStation != "" && nextStation != ""{
                break
            }
        }
        return  [backStation, nextStation]
    }
    
    func mainCellDataToDetailSection(_ data: DetailLoadData) -> [DetailTableViewSectionData] {
        let backNext = self.nextAndBackStationSearch(backId: data.backStationId, nextId: data.nextStationId)
        
        var stationNameCut = ""
        
        if data.stationName.count >= 6{
            stationNameCut = "\(String(data.stationName[data.stationName.startIndex ... data.stationName.index(data.stationName.startIndex, offsetBy: 5)])).."
        }else{
            stationNameCut = data.stationName
        }
        
        return [
           DetailTableViewSectionData(sectionName: "", items: [DetailTableViewCellData(id: "Header", stationCode: data.stationCode, exceptionLastStation: data.exceptionLastStation, subWayId: data.subWayId, upDown: data.upDown, lineNumber: data.lineNumber, useLine: data.useLine, stationName: stationNameCut, backStationName: backNext[0], nextStationName: backNext[1])]),
           DetailTableViewSectionData(sectionName: "실시간 현황", items:  [DetailTableViewCellData(id:  "Live", stationCode: data.stationCode, exceptionLastStation: data.exceptionLastStation, subWayId: data.subWayId, upDown: data.upDown, lineNumber: data.lineNumber, useLine: data.useLine, stationName: stationNameCut, backStationName: backNext[0], nextStationName: backNext[1])]),
           DetailTableViewSectionData(sectionName: "시간표", items:  [DetailTableViewCellData(id:  "Schedule", stationCode: data.stationCode, exceptionLastStation: data.exceptionLastStation, subWayId: data.subWayId, upDown: data.upDown, lineNumber: data.lineNumber, useLine: data.useLine, stationName: stationNameCut, backStationName: backNext[0], nextStationName: backNext[1])])
       ]
    }
    
    func mainCellDataToScheduleSearch(_ item : DetailLoadData) -> ScheduleSearch{
        var searchData = ScheduleSearch(stationCode: item.stationCode, upDown: item.upDown, exceptionLastStation: item.exceptionLastStation, line: item.lineNumber, type: .Seoul, korailCode: item.korailCode)
        
        if item.stationCode.contains("K"){
            searchData.type = .Korail
            
            return searchData
        }else if item.stationCode.contains("D") || item.stationCode.contains("A") || item.stationCode == ""{
            searchData.type = .Unowned
            
            return searchData
        }else{
            return searchData
        }
    }
    
    func scheduleLoad(_ data : ScheduleSearch) -> Observable<[ResultSchdule]>{
        if data.type == .Korail{
            return self.model.korailSchduleLoad(scheduleSearch: data, isFirst: false, isNow: false)
        }else if data.type == .Seoul{
            return self.model.seoulScheduleLoad(data, isFirst: false, isNow: false)
        }else {
            return .just([.init(startTime: "정보없음", type: .Unowned, isFast: "정보없음", startStation: "정보없음", lastStation: "정보없음")])
        }
    }
    
    func arrvialDataLoad(_ station : String) -> Observable<[RealtimeStationArrival]>{
        self.model.singleLiveDataLoad(station: station)
            .map{$0.realtimeArrivalList}
    }
    
    func arrivalDataMatching(station : DetailLoadData, arrivalData : [RealtimeStationArrival]) -> [RealtimeStationArrival]{
        var list = [RealtimeStationArrival(upDown: station.upDown, arrivalTime: "", previousStation: "현재 실시간 열차 데이터가 없어요.", subPrevious: "", code: "", subWayId: station.subWayId, stationName: station.stationName, lastStation: "\(station.exceptionLastStation)행 제외", lineNumber: station.lineNumber, isFast: "", backStationId: station.backStationId, nextStationId: station.nextStationId, trainCode: "")]
        
        for x in arrivalData{
            if station.upDown == x.upDown && station.subWayId == x.subWayId && !(station.exceptionLastStation.contains(x.lastStation)){
                if list.count == 1{
                    list.insert(x, at: 0)
                }else if list.count == 2{
                    list.insert(x, at: 1)
                    list.removeLast()
                    return list
                }
            }
        }
        return list
    }
}
