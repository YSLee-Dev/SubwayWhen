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
    
    func mainTitleLoad() -> Observable<String> {
        Observable<String>.create{
            let data = Calendar.current.component(.weekday, from: Date())
            if data == 1 || data == 7{
                // 주말
                let weekend = ["행복하고 즐거운 주말\n좋은 하루 보내세요!",
                               "행복한 일만 가득한 주말\n행복한 주말 보내세요!",
                ]
                $0.onNext(weekend.randomElement() ?? "행복하고 즐거운 주말이에요!\n좋은 하루 보내세요!")
            }else if data == 2{
                // 월요일
                $0.onNext("월요일,\n한 주도 화이팅해봐요!")
            }else if data == 3{
                // 화요일
                $0.onNext("화요일,\n평범하지만 행복한 날로 만들어봐요!")
            }else if data == 4{
                // 수요일
                $0.onNext("수요일, \n수많은 즐거움이 가득할거에요!")
            }else if data == 5{
                // 목요일
                $0.onNext("목요일,\n주말까지 단 2일 남았어요!")
            }else if data == 6{
                // 금요일
                $0.onNext("금요일,\n행복한 하루 보내세요!")
            }
            $0.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func congestionDataLoad() -> Observable<Int>{
        // 혼잡도 set
        Observable.just(1)
            .map{ _ in
                let nowHour = Calendar.current.component(.hour, from: Date())
                let week =  Calendar.current.component(.weekday, from: Date())
                
                if week == 1 || week == 7{
                    if 1...4 ~= nowHour{
                        return 0
                    }else{
                        return 5
                    }
                }else{
                    if 1...4 ~= nowHour {
                        return 0
                    }else if 5 == nowHour{
                        return 3
                    }else if 6 == nowHour{
                        return 2
                    }else if 7 == nowHour{
                        return 4
                    }else if 8...9 ~= nowHour{
                        return 9
                    }else if 10...11 ~= nowHour{
                        return 4
                    }else if 12...14 ~= nowHour{
                        return 5
                    }else if 15...16 ~= nowHour{
                        return 6
                    }else if 17...18 ~= nowHour{
                        return 10
                    }else if 19 == nowHour{
                        return 7
                    }else if 20...22 ~= nowHour{
                        return 5
                    }else if 23 == nowHour{
                        return 4
                    }else {
                        return 2
                    }
                }
            }
    }
    
    func timeGroup(oneTime : Int, twoTime : Int, nowHour : Int) -> Observable<SaveStationGroup>{
        Observable<SaveStationGroup>.just(.one)
            .map{ _ -> SaveStationGroup? in
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
    }
    
    func arrivalDataLoad(stations: [SaveStation]) -> Observable<(MainTableViewCellData, Int)>{
        self.model.totalLiveDataLoad(stations: stations)
    }
    
    func createMainTableViewSection(_ data: [MainTableViewCellData]) -> [MainTableViewSection]{
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
    
    func mainCellDataToScheduleData(_ item: MainTableViewCellData) -> ScheduleSearch? {
        if item.type == .real{
            if item.korailCode == "K4" || item.korailCode == "K1" || item.korailCode == "K2"{
                return ScheduleSearch(stationCode: item.stationCode, upDown: item.upDown, exceptionLastStation: item.exceptionLastStation, line: item.lineNumber, type: .Korail, korailCode: item.korailCode)
            }else if item.korailCode == "UI" || item.korailCode == "D1" || item.korailCode == "A1"{
                return ScheduleSearch(stationCode: item.stationCode, upDown: item.upDown, exceptionLastStation: item.exceptionLastStation, line: item.lineNumber, type: .Unowned, korailCode: item.korailCode)
            }else{
                return ScheduleSearch(stationCode: item.stationCode, upDown: item.upDown, exceptionLastStation: item.exceptionLastStation, line: item.lineNumber, type: .Seoul, korailCode: item.korailCode)
            }
        }else{
            return nil
        }
    }
    
    func scheduleLoad(_ data: ScheduleSearch) ->  Observable<[ResultSchdule]>{
        if data.type == .Korail{
            return self.model.korailSchduleLoad(scheduleSearch: data, isFirst: true, isNow: true)
        }else if data.type == .Seoul{
            return self.model.seoulScheduleLoad(data, isFirst: true, isNow: true)
        }else {
            return .just([.init(startTime: "정보없음", type: .Unowned, isFast: "", startStation: "정보없음", lastStation: "정보없음")])
        }
    }
    
    func scheduleDataToMainTableViewCell(data: ResultSchdule, nowData: MainTableViewCellData) -> MainTableViewCellData{
        MainTableViewCellData(upDown: nowData.upDown, arrivalTime: data.useArrTime, previousStation: "", subPrevious: "\(data.useTime)", code: "\(data.useArrTime)", subWayId: nowData.subWayId, stationName: nowData.stationName, lastStation: "\(data.lastStation)행", lineNumber: nowData.lineNumber, isFast: "\(data.isFast)", useLine: nowData.useLine, group: nowData.group, id: nowData.id, stationCode: nowData.stationCode, exceptionLastStation: nowData.exceptionLastStation, type: .schedule, backStationId: nowData.backStationId, nextStationId: nowData.nextStationId, korailCode: nowData.korailCode)
    }
    
    func headerImportantDataLoad() -> Observable<ImportantData> {
        self.model.importantDataLoad()
    }
    
    func emptyLiveData(stations: [SaveStation]) -> Observable<[MainTableViewCellData]> {
        Observable<[MainTableViewCellData]>.create {
            $0.onNext(
                stations.map { station -> MainTableViewCellData in
                        .init(upDown: station.updnLine, arrivalTime: "", previousStation: "", subPrevious: "", code: "데이터를 로드하고 있어요.", subWayId: station.lineCode, stationName: station.stationName, lastStation: "", lineNumber: station.line, isFast: "", useLine: station.useLine, group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation, type: .loading, backStationId: "", nextStationId: "",  korailCode: station.korailCode)
                }
            )
            
            return Disposables.create()
        }
    }
}

