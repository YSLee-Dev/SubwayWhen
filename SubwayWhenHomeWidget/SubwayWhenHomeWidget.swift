//
//  SubwayWhenHomeWidget.swift
//  SubwayWhenHomeWidget
//
//  Created by 이윤수 on 3/28/24.
//

import WidgetKit
import SwiftUI
import RxSwift

struct Preview {
    static let saveStationPlaceHolderData = SaveStation(id: "previewPlaceHolder", stationName: "민실씨", stationCode: "000", updnLine: "상행", line: "00호선", lineCode: "0000", group: .one, exceptionLastStation: "", korailCode: "")
    static let saveStationData = SaveStation(id: "preview", stationName: "강남", stationCode: "222", updnLine: "외선", line: "02호선", lineCode: "1002", group: .one, exceptionLastStation: "", korailCode: "")
    static let scheduleData = [
        ResultSchdule(startTime: "9:00", type: .Seoul, isFast: "", startStation: "시청", lastStation: "성수"),
        ResultSchdule(startTime: "9:02", type: .Seoul, isFast: "", startStation: "성수", lastStation: "신도림"),
        ResultSchdule(startTime: "9:04", type: .Seoul, isFast: "", startStation: "시청", lastStation: "성수"),
        ResultSchdule(startTime: "9:06", type: .Seoul, isFast: "", startStation: "성수", lastStation: "시청")
    ]
}

struct Provider: AppIntentTimelineProvider {
    private let totalLoadModel: TotalLoadProtocol = TotalLoadModel()
    private var saveStation: [SaveStation] {
        guard let data = UserDefaults.shared.data(forKey: "saveStation") ,
              let list = try? PropertyListDecoder().decode([SaveStation].self, from: data) else {return []}
        return  list.filter {$0.allowScheduleLoad}
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), scheduleData: Preview.scheduleData, configuration: ConfigurationAppIntent(), nowWidgetShowStation: Preview.saveStationPlaceHolderData)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        if self.saveStation.isEmpty {
            return SimpleEntry(date: Date(), scheduleData: Preview.scheduleData, configuration: ConfigurationAppIntent(), nowWidgetShowStation: Preview.saveStationData)
        } else {
            let scheduleData = await self.scheduleLoad(saveStation: self.saveStation.first!)
            return SimpleEntry(date: Date(), scheduleData: scheduleData, configuration: ConfigurationAppIntent(), nowWidgetShowStation: self.saveStation.first ?? Preview.saveStationData)
        }
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        // 위젯에서 선택한 항목을 고름
        guard  let nowWidgetShowStation = self.saveStation.filter({$0.widgetUseText ==  configuration.seletedStation}).first
        else {
            // 선택된 지하철이 없는 경우
            entries.append(SimpleEntry(date: Date(), scheduleData: Preview.scheduleData, configuration: ConfigurationAppIntent(), nowWidgetShowStation: .init(id: "NOSTATION", stationName: "-", stationCode: "000", updnLine: "-",  line: "00호선", lineCode: "0000", group: .one, exceptionLastStation: "", korailCode: "")))
            return Timeline(entries: entries, policy: .never)
        }

        let asyncData = await self.scheduleLoad(saveStation: nowWidgetShowStation)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = TimeZone.current
        
        if asyncData.first?.startTime == "-" {
            // 지하철 막차 시간표까지 종료인 경우 12시에 다시 로드하도록
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current
            var tomorrow = calendar.dateComponents([.year, .month, .day], from: .now)
            tomorrow.day! += 1
            tomorrow.hour = 0
            tomorrow.minute = 0
            tomorrow.second = 10 // 여유 시간
            
            let reloadingSecond = calendar.date(from: tomorrow)?.timeIntervalSinceNow ?? 300
            entries = [SimpleEntry(date: .now.addingTimeInterval(reloadingSecond), scheduleData: asyncData, configuration: configuration, nowWidgetShowStation: nowWidgetShowStation)]
        } else if asyncData.count <= 3 {
            // 데이터가 4개 이하인 경우 300초 이후 다시 로드하도록
            entries = [SimpleEntry(date: .now.addingTimeInterval(300), scheduleData: asyncData, configuration: configuration, nowWidgetShowStation: nowWidgetShowStation)]
        } else {
            for index in stride(from: 1, through: asyncData.count - 1, by: 2) {
                let scheduleData = Array(asyncData[index - 1 ... min(index + 2 , asyncData.count - 1)])
                var loadingTime = scheduleData[0].startTime
                var backLoadingTime: String?
                
                if index != 1 {
                    backLoadingTime =  asyncData[ index - 2].startTime
                }
                
                if scheduleData.first?.type == .Korail {
                    loadingTime.insert(":", at: loadingTime.index(loadingTime.startIndex, offsetBy: 2))
                    backLoadingTime?.insert(":", at: loadingTime.index(loadingTime.startIndex, offsetBy: 2))
                    loadingTime = String(loadingTime.dropLast(2))
                } else {
                    loadingTime = String(loadingTime.dropLast(3))
                }
                
                if backLoadingTime != nil {
                    backLoadingTime = String(backLoadingTime!.dropLast(scheduleData.first?.type == .Korail ? 2 : 3))
                }
                
                let currentDateString = dateFormatter.string(from:  Date())
                let combinedDateString = "\(currentDateString.prefix(10)) \(loadingTime)"
                
                if let targetDate = dateFormatter.date(from: combinedDateString) {
                    var loadingDate: Date!
                    if backLoadingTime == nil {
                        loadingDate = targetDate.addingTimeInterval(-300) // 전 시간이 없는 경우
                    } else {
                        let backLoadingDate = dateFormatter.date(from:  "\(currentDateString.prefix(10)) \(backLoadingTime!)")!
                        let reloadingTime =  backLoadingDate.timeIntervalSince(targetDate)
                        loadingDate = targetDate.addingTimeInterval(reloadingTime +  (configuration.nowTimeScheduleIsInsert ? 60.0 : 0.0))
                    }
                    entries.append(SimpleEntry(date: loadingDate, scheduleData: scheduleData, configuration: configuration, nowWidgetShowStation: nowWidgetShowStation))
                }
            }
        }
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    private func scheduleLoad(saveStation: SaveStation) async -> [ResultSchdule] {
        let scheduleRequest = ScheduleSearch(stationCode: saveStation.stationCode, upDown: saveStation.updnLine, exceptionLastStation: saveStation.exceptionLastStation, line: saveStation.line, korailCode: saveStation.korailCode)
        
        var scheduleResult: Observable<[ResultSchdule]>!
        if scheduleRequest.lineScheduleType  == .Korail{
            scheduleResult = self.totalLoadModel.korailSchduleLoad(scheduleSearch: scheduleRequest, isFirst: false, isNow: true, isWidget: true)
        } else if scheduleRequest.lineScheduleType == .Seoul {
            scheduleResult = self.totalLoadModel.seoulScheduleLoad(scheduleRequest, isFirst: false, isNow: true, isWidget: true)
        }
        
        return await self.totalLoadModel.scheduleDataFetchAsyncData(scheduleResult)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let scheduleData: [ResultSchdule]
    let configuration: ConfigurationAppIntent
    var nowWidgetShowStation: SaveStation
}

struct SubwayWhenHomeWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var widgetFamily

    var body: some View {
        let seletedStation = entry.nowWidgetShowStation
        
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Text(entry.nowWidgetShowStation.id == "NOSTATION" ? "" : seletedStation.useLine)
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
                if result.first?.startTime == "-" || entry.nowWidgetShowStation.id == "NOSTATION" {
                    Text(result.first?.startTime == "-"  ? "금일 지하철 운행 종료" : "지하철역을 추가해주세요.")
                        .foregroundStyle(Color(uiColor: .label))
                        .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("MainColor"))
                        }
                    
                } else  if widgetFamily == .systemSmall {
                    VStack(spacing: 10) {
                        ForEach(result, id: \.startTime) {
                            SubwayWhenHomeWidgetSubView(time: $0.useArrTime, lastStation: $0.lastStation, lineColor: seletedStation.useLine, isFast: $0.isFast)
                                .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                        }
                    }
                    
                } else {
                    HStack {
                        VStack(spacing: 10) {
                            ForEach(result.enumerated().filter {$0.offset % 2 == 0}.map {$0.element}, id: \.startTime) {
                                SubwayWhenHomeWidgetSubView(time: $0.useArrTime, lastStation: $0.lastStation, lineColor: seletedStation.useLine, isFast: $0.isFast)
                                    .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                            }
                        }
                        .padding(.trailing, 2.5)
                        VStack(spacing: 10) {
                            ForEach(result.enumerated().filter {$0.offset % 2 == 1}.map {$0.element}, id: \.startTime) {
                                SubwayWhenHomeWidgetSubView(time: $0.useArrTime, lastStation: $0.lastStation, lineColor: seletedStation.useLine, isFast: $0.isFast)
                                    .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                            }
                        }
                        .padding(.leading, 2.5)
                    }
                }
        }
            .widgetURL(URL(string: "widget://deeplink?text=\(entry.configuration.seletedStation?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"))
    }
}

struct SubwayWhenHomeWidgetSubView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    let time: String
    let lastStation: String
    let lineColor: String
    let isFast: String
    
    var body: some View {
        HStack(spacing: 2) {
            Text("⏱️ " + "\((widgetFamily != .systemSmall && isFast == "급행") ? "(급)" : "" )" + lastStation + "행" )
                .foregroundStyle((widgetFamily == .systemSmall && isFast == "급행") ? Color(uiColor: .systemRed) : Color(uiColor: .label))
                .padding(.leading, 5)
                .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(time)
                .foregroundStyle(Color(uiColor: .label))
                .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
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
        .configurationDisplayName("시간표 확인하기")
        .description("원하는 지하철역의 시간표를 빠르게 확인할 수 있어요.")
        .supportedFamilies([.systemSmall, .systemMedium])
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
    SimpleEntry(date: .now, scheduleData: Preview.scheduleData, configuration: .smiley, nowWidgetShowStation: Preview.saveStationData)
}
