//
//  MainModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/21.
//

import Foundation

import RxSwift
import RxCocoa

class MainModel : MainModelProtocol{
    let model : TotalLoadProtocol
    
    init(totalLoadModel : TotalLoadModel = .init()){
        self.model = totalLoadModel
    }
    
    func congestionDataLoad() -> Observable<Int>{
        // 혼잡도 set
        Observable.just(1)
            .map{ _ in
                let nowHour = Calendar.current.component(.hour, from: Date())
                let week =  Calendar.current.component(.weekday, from: Date())
                
                if week == 1 || week == 7{
                    return 5
                }else{
                    if 1...5 ~= nowHour {
                        return 1
                    }else if 6 == nowHour{
                        return 4
                    }else if 7 == nowHour{
                        return 6
                    }else if 8 == nowHour{
                        return 10
                    }else if 9 == nowHour{
                        return 7
                    }else if 10 == nowHour{
                        return 6
                    }else if 11...16 ~= nowHour{
                        return 4
                    }else if 17 == nowHour{
                        return 5
                    }else if 18 == nowHour{
                        return 7
                    }else if 19...22 ~= nowHour{
                        return 5
                    }else if 23 == nowHour{
                        return 3
                    }else {
                        return 1
                    }
                }
            }
    }
    
    func totalDataRemove() -> Observable<[MainTableViewCellData]>{
        Observable<[MainTableViewCellData]>.just([])
    }
    
    func timeGroup(oneTime : Int, twoTime : Int) -> Observable<SaveStationGroup>{
        Observable<SaveStationGroup>.just(.one)
            .map{ _ -> SaveStationGroup? in
                let nowHour = Calendar.current.component(.hour, from: Date())
                
                let groupOne = oneTime
                let groupTwo = twoTime
                
                if oneTime == 0 && twoTime == 0{
                    return nil
                }else if groupOne < groupTwo{
                    if groupTwo <= nowHour{
                        return .two
                    }else if groupOne <= nowHour{
                        return .one
                    }else {
                        return nil
                    }
                }else if groupOne > groupTwo{
                    if groupOne <= nowHour{
                        return .one
                    }else if groupTwo <= nowHour{
                        return .two
                    }else {
                        return nil
                    }
                }else{
                    return nil
                }
            }
            .filterNil()
            .delay(.milliseconds(150), scheduler: MainScheduler.instance)
    }
    
    func arrivalDataLoad(stations : [SaveStation]) -> Observable<MainTableViewCellData>{
        self.model.totalLiveDataLoad(stations: stations)
    }
    
    func mainSectionDataLoad(_ data : [MainTableViewCellData]) -> [MainTableViewSection]{
        let header = MainTableViewSection(id : "header", sectionName: "", items: [.init(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "", subWayId: "", stationName: "header", lastStation: "", lineNumber: "", isFast: "", useLine: "", group: "", id: "header", stationCode: "", exceptionLastStation: "", type: .real, backStationId: "", nextStationId: "",  korailCode: "")])
        let group = MainTableViewSection(id : "group", sectionName: "실시간 현황", items: [.init(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "", subWayId: "", stationName: "group", lastStation: "", lineNumber: "", isFast: "", useLine: "", group: "", id: "group", stationCode: "", exceptionLastStation: "", type: .real, backStationId: "", nextStationId: "", korailCode: "")])
        
        var groupData = MainTableViewSection(id: "live", sectionName: "", items: [])
        
        if data.isEmpty{
            groupData.items = [.init(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "", subWayId: "", stationName: "", lastStation: "", lineNumber: "", isFast: "", useLine: "", group: "", id: "NoData", stationCode: "", exceptionLastStation: "", type: .real, backStationId: "", nextStationId: "", korailCode: "")]
        }else{
            groupData.items = data
        }
        
        return [header,group,groupData]
    }
    
    func mainCellDataToScheduleData(_ item : MainTableViewCellData) -> ScheduleSearch? {
        if item.type == .real{
            if item.stationCode.contains("K"){
                return ScheduleSearch(stationCode: item.stationCode, upDown: item.upDown, exceptionLastStation: item.exceptionLastStation, line: item.lineNumber, type: .Korail, korailCode: item.korailCode)
            }else if item.stationCode.contains("D") || item.stationCode.contains("A"){
                return ScheduleSearch(stationCode: item.stationCode, upDown: item.upDown, exceptionLastStation: item.exceptionLastStation, line: item.lineNumber, type: .Unowned, korailCode: item.korailCode)
            }else{
                return ScheduleSearch(stationCode: item.stationCode, upDown: item.upDown, exceptionLastStation: item.exceptionLastStation, line: item.lineNumber, type: .Seoul, korailCode: item.korailCode)
            }
        }else{
            return nil
        }
    }
    
    func scheduleLoad(_ data : ScheduleSearch) ->  Observable<[ResultSchdule]>{
        if data.type == .Korail{
            return self.model.korailSchduleLoad(scheduleSearch: data, isFirst: true, isNow: true)
        }else if data.type == .Seoul{
            return self.model.seoulScheduleLoad(data, isFirst: true, isNow: true)
        }else {
            return .just([.init(startTime: "정보없음", type: .Unowned, isFast: "정보없음", startStation: "정보없음", lastStation: "정보없음")])
        }
    }
    
    func scheduleDataToMainTableViewCell(data : ResultSchdule, nowData : MainTableViewCellData) -> MainTableViewCellData{
        MainTableViewCellData(upDown: nowData.upDown, arrivalTime: data.useArrTime, previousStation: "", subPrevious: "\(data.useTime)", code: "\(data.useArrTime)", subWayId: nowData.subWayId, stationName: nowData.stationName, lastStation: "\(data.lastStation)행", lineNumber: nowData.lineNumber, isFast: "\(data.isFast)", useLine: nowData.useLine, group: nowData.group, id: nowData.id, stationCode: nowData.stationCode, exceptionLastStation: nowData.exceptionLastStation, type: .schedule, backStationId: nowData.backStationId, nextStationId: nowData.nextStationId, korailCode: nowData.korailCode)
    }
}

