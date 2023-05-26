//
//  SubwayWhenDetailWidgetLiveActivity.swift
//  SubwayWhenDetailWidget
//
//  Created by 이윤수 on 2023/05/09.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SubwayWhenDetailWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var scheduleList : [String]
        var lastUpdate : String
    }
    
    var line: String
    var saveStation : String
}

struct SubwayWhenDetailWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SubwayWhenDetailWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack{
                HStack{
                    Text(context.attributes.line)
                        .font(.system(size: ViewStyle.FontSize.mediumSize))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                        .frame(
                            width: 60,
                            height: 60
                        )
                        .background{
                            Circle()
                                .fill(Color(context.attributes.line))
                        }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing){
                        Text(context.attributes.saveStation)
                            .font(.system(size: ViewStyle.FontSize.largeSize))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(uiColor: .label))
                        
                        Text(context.state.lastUpdate)
                            .font(.system(size: ViewStyle.FontSize.smallSize))
                            .foregroundColor(Color.secondary)
                    }
                    
                }
                .padding(.bottom, 5)
                
                HStack(alignment: .center, spacing: 5){
                    ForEach(Array(context.state.scheduleList.enumerated()), id: \.offset){ offset, data  in
                        Text(data)
                            .font(.system(size: ViewStyle.FontSize.mediumSmallSize))
                            .lineLimit(1)
                            .padding(5)
                            .foregroundColor(Color.white)
                            .background{
                                Capsule()
                                    .fill(Color(context.attributes.line))
                            }
                            .layoutPriority(Double(-(offset) + 10))
                    }
                }
            }
            .frame(height: 95)
            .padding(15)
            .activityBackgroundTint(nil)
            .activitySystemActionForegroundColor(Color.black)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.line)
                        .font(.system(size: ViewStyle.FontSize.mediumSize))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                        .frame(
                            width: 60,
                            height: 60
                        )
                        .background{
                            Circle()
                                .fill(Color(context.attributes.line))
                        }
                        .padding(.bottom, 5)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing){
                        Spacer()
                        Text(context.attributes.saveStation)
                            .font(.system(size: ViewStyle.FontSize.largeSize))
                            .foregroundColor(Color(uiColor: .label))
                        Text(context.state.lastUpdate)
                            .font(.system(size: ViewStyle.FontSize.smallSize))
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(alignment: .center, spacing: 5){
                        ForEach(Array(context.state.scheduleList.enumerated()), id: \.offset){ offset, data  in
                            Text(data)
                                .font(.system(size: ViewStyle.FontSize.mediumSmallSize))
                                .lineLimit(1)
                                .padding(5)
                                .foregroundColor(Color.white)
                                .background{
                                    Capsule()
                                        .fill(Color(context.attributes.line))
                                }
                                .layoutPriority(Double(-(offset) + 10))
                        }
                    }
                }
            } compactLeading: {
                Text(context.attributes.line)
                    .font(.system(size: ViewStyle.FontSize.smallSize))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(context.attributes.line))
            } compactTrailing: {
                Text(context.attributes.saveStation)
                    .font(.system(size: ViewStyle.FontSize.smallSize))
            } minimal: {
                Text(context.attributes.saveStation)
                    .font(.system(size:  ViewStyle.FontSize.smallSize))
                    .foregroundColor(Color(context.attributes.line))
            }
            .keylineTint(Color(context.attributes.line))
        }
    }
    
}
