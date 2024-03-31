//
//  SubwayWhenHomeWidget.swift
//  SubwayWhenHomeWidget
//
//  Created by 이윤수 on 3/28/24.
//

import WidgetKit
import SwiftUI
import RxSwift

struct Provider: AppIntentTimelineProvider {
    let totalLoadModel: TotalLoadProtocol = TotalLoadModel()
    let bag = DisposeBag()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), scheduleData:[ .init(startTime: "9:00", type: .Seoul, isFast: "", startStation: "강남", lastStation: "성수")], configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), scheduleData:[ .init(startTime: "9:00", type: .Seoul, isFast: "", startStation: "강남", lastStation: "성수")], configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        guard let data = UserDefaults.shared.data(forKey: "saveStation") ,
              let list = try? PropertyListDecoder().decode([SaveStation].self, from: data),
              // 위젯에서 선택한 항목을 고름
              let nowWidgetShowStation = list.filter({$0.widgetUseText ==  configuration.seletedStation}).first
        else {return Timeline(entries: entries, policy: .atEnd)}
        
        let scheduleRequest = ScheduleSearch(stationCode: nowWidgetShowStation.stationCode, upDown: nowWidgetShowStation.updnLine, exceptionLastStation: nowWidgetShowStation.exceptionLastStation, line: nowWidgetShowStation.line, korailCode: nowWidgetShowStation.korailCode)
        
        var scheduleResult: Observable<[ResultSchdule]>!
        if scheduleRequest.allowScheduleLoad  == .Korail{
            scheduleResult = self.totalLoadModel.korailSchduleLoad(scheduleSearch: scheduleRequest, isFirst: false, isNow: true)
        } else if scheduleRequest.allowScheduleLoad == .Seoul {
            scheduleResult = self.totalLoadModel.seoulScheduleLoad(scheduleRequest, isFirst: false, isNow: true)
        } else {
            return  Timeline(entries: entries, policy: .after(.now.addingTimeInterval(600)))
        }
        
        let asyncData = await self.totalLoadModel.scheduleDataFetchAsyncData(scheduleResult)
        entries = [SimpleEntry(date: .now.addingTimeInterval(600), scheduleData: asyncData, configuration: configuration)]
        return Timeline(entries: entries, policy: .after(.now.addingTimeInterval(600)))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let scheduleData: [ResultSchdule]
    let configuration: ConfigurationAppIntent
}

struct SubwayWhenHomeWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)
            
            Text("선택한 지하철")
            Text(entry.configuration.seletedStation ?? "없음")
            
            Text("TEST")
            Text(entry.scheduleData.first?.useArrTime ?? "오류")
            Text(entry.scheduleData.first?.startTime ?? "오류")
        }
    }
}

struct SubwayWhenHomeWidget: Widget {
    let kind: String = "SubwayWhenHomeWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            SubwayWhenHomeWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.seletedStation = "강남"
        return intent
    }
}

#Preview(as: .systemSmall) {
    SubwayWhenHomeWidget()
} timeline: {
    SimpleEntry(date: .now, scheduleData: [.init(startTime: "9:00", type: .Seoul, isFast: "", startStation: "강남", lastStation: "성수")], configuration: .smiley)
}
