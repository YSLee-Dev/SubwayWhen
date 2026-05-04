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
    let congestionManager: CongestionManagerProtocol
    
    init(
        totalLoadModel : TotalLoadModel = .init(),
        congestionManager: CongestionManagerProtocol = CongestionManager.shared
    ){
        self.model = totalLoadModel
        self.congestionManager = congestionManager
    }
    
    func mainTitleLoad() -> Observable<String> {
        return Observable<String>.create{
            let data = Calendar.current.component(.weekday, from: Date())
            let weekMessages = [
                Strings.Main.weekendMessages,
                Strings.Main.mondayMessages,
                Strings.Main.tuesdayMessages,
                Strings.Main.wednesdayMessages,
                Strings.Main.thursdayMessages,
                Strings.Main.fridayMessages,
                Strings.Main.weekendMessages
            ]
            
            let index = data - 1
            guard weekMessages.indices.contains(index),
                  let message = weekMessages[index].randomElement()
            else {
                $0.onNext(Strings.Main.defaultMessage)
                $0.onCompleted()
                return Disposables.create()
            }
            
            $0.onNext(message)
            $0.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func congestionDataLoad() -> Observable<Int>{
        // 혼잡도 set
        return Observable<Int>.create { [weak self] observer in
            let congestion = self?.congestionManager.getLevel(
                station: FixInfo.saveSetting.mainCongestionBaseStaton, hour: Calendar.current.component(.hour, from: Date())
            ) ?? 0
            
            observer.onNext(congestion)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func timeGroup(oneTime : Int, twoTime : Int, nowHour : Int) -> Observable<SaveStationGroup>{
        return Observable<SaveStationGroup>.create { observer in
            guard !(oneTime == 0 && twoTime == 0) else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            let oneValid = oneTime > 0 && oneTime <= nowHour
            let twoValid = twoTime > 0 && twoTime <= nowHour
            
            if (oneValid && twoValid) {
                observer.onNext(oneTime >= twoTime ? .one : .two)
            } else if oneValid {
                observer.onNext(.one)
            } else if twoValid {
                observer.onNext(.two)
            }
            
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func arrivalDataLoad(stations: [SaveStation]) -> Observable<(MainTableViewCellData, Int)>{
        return self.model.totalLiveDataLoad(stations: stations)
    }
    
    func createMainTableViewSection(_ data: [MainTableViewCellData]) -> [MainTableViewSection]{
        var groupData = MainTableViewSection(id: "live", sectionName: "", items: [])
        
        if data.isEmpty{
            groupData.items = [.init(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "", stationName: "", lastStation: "", isFast: "", group: "", id: "NoData", stationCode: "", exceptionLastStation: "", type: .real, backStationId: "", nextStationId: "", korailCode: "", stateMSG: "", subwayLineData: .not)]
        }else{
            groupData.items = data
        }
        
        return [groupData]
    }
    
    func mainCellDataToScheduleData(_ item: MainTableViewCellData) -> ScheduleSearch? {
        guard item.type == .real else { return nil }
        
        return ScheduleSearch(
            stationCode: item.stationCode,
            upDown: item.upDown,
            exceptionLastStation: item.exceptionLastStation,
            line: item.subwayLineData.rawValue,
            korailCode: item.korailCode,
            stationName: item.stationName
        )
    }
    
    func scheduleLoad(_ data: ScheduleSearch, requestDate: Date) ->  Observable<[ResultSchdule]>{
        if data.lineScheduleType == .Korail{
            return self.model.korailSchduleLoad(scheduleSearch: data, isFirst: true, isNow: true, isWidget: false, requestDate: requestDate)
        } else if data.lineScheduleType == .Seoul {
            return self.model.seoulScheduleLoad(data, isFirst: true, isNow: true, isWidget: false, requestDate: requestDate)
        } else if data.lineScheduleType == .Shinbundang {
            return self.model.shinbundangScheduleLoad(scheduleSearch: data, isFirst: true, isNow: true, isWidget: false, requestDate: requestDate)
        } else {
            return .just([.init(startTime: Strings.Main.notAvailable, type: .Unowned, isFast: "", startStation: Strings.Main.notAvailable, lastStation: Strings.Main.notAvailable)])
        }
    }
    
    func scheduleDataToMainTableViewCell(data: ResultSchdule, nowData: MainTableViewCellData) -> MainTableViewCellData{
        return MainTableViewCellData(upDown: nowData.upDown, arrivalTime: data.useArrTime, previousStation: "", subPrevious: "\(data.useTime)", code: "\(data.useArrTime)", stationName: nowData.stationName, lastStation: "\(data.lastStation)\(Strings.Main.bound)", isFast: "\(data.isFast)", group: nowData.group, id: nowData.id, stationCode: nowData.stationCode, exceptionLastStation: nowData.exceptionLastStation, type: .schedule, backStationId: nowData.backStationId, nextStationId: nowData.nextStationId, korailCode: nowData.korailCode, stateMSG: data.useArrTime, subwayLineData: nowData.subwayLineData)
    }
    
    func headerImportantDataLoad() -> Observable<ImportantData> {
        return self.model.importantDataLoad()
            .filter {$0.title != ""}
    }
    
    func emptyLiveData(stations: [SaveStation]) -> Observable<[MainTableViewCellData]> {
        return Observable<[MainTableViewCellData]>.create {
            $0.onNext(
                stations.map { station -> MainTableViewCellData in
                        .init(upDown: station.updnLine, arrivalTime: "", previousStation: "", subPrevious: "", code: Strings.Main.dataLoading, stationName: station.stationName, lastStation: "", isFast: "", group: station.group.rawValue, id: station.id, stationCode: station.stationCode, exceptionLastStation: station.exceptionLastStation, type: .loading, backStationId: "", nextStationId: "",  korailCode: station.korailCode, stateMSG: Strings.Main.dataLoading, subwayLineData: .init(subwayId: station.lineCode))
                }
            )
            
            return Disposables.create()
        }
    }
}

