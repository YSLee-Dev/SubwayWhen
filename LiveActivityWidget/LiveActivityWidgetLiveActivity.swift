//
//  LiveActivityWidgetLiveActivity.swift
//  LiveActivityWidget
//
//  Created by 이윤수 on 2023/05/08.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LiveActivityWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var status : Int
        var statusMSG : String
        var nowStation : String
    }

    // Fixed non-changing properties about your activity go here!
    var line: String
    var saveStation : String
}

struct LiveActivityWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            HStack{
                Text(context.attributes.line)
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                    .frame(
                        width: 65,
                        height: 65
                    )
                    .background{
                        Circle()
                            .fill(Color(context.attributes.line))
                    }
                
                Spacer()
                
                VStack{
                    Text(context.state.nowStation)
                        .font(.system(size: 17))
                        .foregroundColor(Color(uiColor: .label))
                    Text(context.state.statusMSG)
                        .font(.system(size: 17))
                        .foregroundColor(Color(uiColor: .label))
                }
               
            }
            .padding(15)
            .activityBackgroundTint(nil)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.line)
                        .font(.system(size: 17))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                        .frame(
                            width: 65,
                            height: 65
                        )
                        .background{
                            Circle()
                                .fill(Color(context.attributes.line))
                        }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.nowStation)
                        .font(.system(size: 17))
                        .foregroundColor(Color(uiColor: .label))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.statusMSG)
                        .font(.system(size: 17))
                        .foregroundColor(Color(uiColor: .label))
                }
            } compactLeading: {
                Text(context.attributes.line)
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(context.attributes.line))
            } compactTrailing: {
                Text(context.state.statusMSG)
            } minimal: {
                Text(context.state.statusMSG)
                    .foregroundColor(Color(context.attributes.line))
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

struct LiveActivityWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = LiveActivityWidgetAttributes(line: "08호선", saveStation: "단대오거리")
    static let contentState = LiveActivityWidgetAttributes.ContentState(status: 1, statusMSG: "곧 도착", nowStation: "단대오거리")

    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Island Compact")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Island Expanded")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
    }
}
