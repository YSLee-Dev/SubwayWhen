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
    @Environment(\.widgetFamily) private var widgetFamily
    
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
    var nowWidgetShowStation: SaveStation? {
        guard let data = UserDefaults.shared.data(forKey: "saveStation") ,
              let list = try? PropertyListDecoder().decode([SaveStation].self, from: data),
              // 위젯에서 선택한 항목을 고름
              let nowWidgetShowStation = list.filter({$0.widgetUseText ==  configuration.seletedStation}).first
        else {return nil}
        return nowWidgetShowStation
    }
}

struct SubwayWhenHomeWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var widgetFamily

    var body: some View {
        if let seletedStation = entry.nowWidgetShowStation {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Text(seletedStation.useLine)
                        .foregroundColor(.white)
                        .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                        .background {
                            Circle()
                                .fill(Color(seletedStation.useLine))
                                .frame(width: 50, height: 50)
                        }
                        .frame(width: 50, height: 50)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(seletedStation.stationName)
                            .foregroundStyle(Color(uiColor: .white))
                            .font(.system(size: widgetFamily == .systemSmall ?  ViewStyle.FontSize.smallSize : ViewStyle.FontSize.mediumSize, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text(seletedStation.updnLine)
                            .foregroundStyle(Color(uiColor: .white))
                            .font(.system(size: ViewStyle.FontSize.mediumSmallSize, weight: .semibold))
                            
                    }
                }
                .padding(.bottom, 5)
                
                let count = widgetFamily == .systemSmall ? 2 : 4
                let result = entry.scheduleData.count <= count ?  entry.scheduleData :  Array(entry.scheduleData[0...count - 1])
                if result.isEmpty {
                    Text("현재 시간표 데이터가 없어요.")
                        .foregroundStyle(Color(uiColor: .label))
                        .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                } else  if widgetFamily == .systemSmall {
                    VStack(spacing: 10) {
                        ForEach(result, id: \.startTime) {
                            SubwayWhenHomeWidgetSubView(time: $0.useArrTime, lastStation: $0.lastStation, lineColor: seletedStation.useLine)
                                .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                        }
                    }
                } else {
                    HStack {
                        VStack(spacing: 10) {
                            ForEach(result.enumerated().filter {$0.offset % 2 == 0}.map {$0.element}, id: \.startTime) {
                                SubwayWhenHomeWidgetSubView(time: $0.useArrTime, lastStation: $0.lastStation, lineColor: seletedStation.useLine)
                                    .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                            }
                        }
                        .padding(.trailing, 2.5)
                        VStack(spacing: 10) {
                            ForEach(result.enumerated().filter {$0.offset % 2 == 1}.map {$0.element}, id: \.startTime) {
                                SubwayWhenHomeWidgetSubView(time: $0.useArrTime, lastStation: $0.lastStation, lineColor: seletedStation.useLine)
                                    .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                            }
                        }
                        .padding(.leading, 2.5)
                    }
                }
                
            }
        } else {
            Text("현재 선택된 지하철역이 없어요.")
                .foregroundStyle(Color(uiColor: .label))
                .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
        }
    }
}

struct SubwayWhenHomeWidgetSubView : View {
    let time: String
    let lastStation: String
    let lineColor: String
    
    var body: some View {
        HStack {
            Text("⏱️ " + lastStation + "행 " + time)
                .foregroundStyle(Color(uiColor: .label))
                .padding(.leading, 5)
                .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
            
            Spacer()
        }
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("MainColor"))
        }
    }
}

struct SubwayWhenHomeWidget: Widget {
    let kind: String = "SubwayWhenHomeWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            SubwayWhenHomeWidgetEntryView(entry: entry)
                .containerBackground(Color("AppIconColor"), for: .widget)
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
