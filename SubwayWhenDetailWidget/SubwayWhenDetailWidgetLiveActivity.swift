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
        // Dynamic stateful properties about your activity go here!
        var status : String
        var statusMSG : String
        var nowStation : String
    }
    
    // Fixed non-changing properties about your activity go here!
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
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                        .frame(
                            width: 50,
                            height: 50
                        )
                        .background{
                            Circle()
                                .fill(Color(context.attributes.line))
                        }
                    
                    Spacer()
                    
                    Text(context.state.statusMSG)
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(uiColor: .label))
                    
                }
                
                HStack(alignment: .center, spacing: 0){
                    Text(context.attributes.saveStation)
                        .font(.system(size: 14))
                        .foregroundColor(Color(uiColor: .label))
                        .padding(.leading, 5)
                    
                    Spacer()
                    
                    VStack{
                        Divider()
                            .frame(height: 3)
                            .background(Color(context.attributes.line))
                            .overlay{
                                HStack{
                                    Circle()
                                        .fill(Color.white)
                                        .overlay{
                                            Circle()
                                                .strokeBorder(Color(context.attributes.line))
                                        }
                                        .frame(
                                            width: 12,
                                            height: 12
                                        )
                                    Spacer()
                                    
                                    Circle()
                                        .fill(Color.white)
                                        .overlay{
                                            Circle()
                                                .strokeBorder(Color(context.attributes.line))
                                        }
                                        .frame(
                                            width: 12,
                                            height: 12
                                        )
                                }
                                
                                GeometryReader{ geometry in
                                    if context.state.status == "0"{
                                        Text("🚃")
                                            .position(x: 25, y: -5)
                                    }else if context.state.status == "1"{
                                        Text("🚃")
                                            .position(x: 5, y: -5)
                                    }else if context.state.status == "2"{
                                        Text("🚃")
                                            .position(x: -5, y: -5)
                                    }else if context.state.status == "3"{
                                        Text("🚃")
                                            .position(x: (geometry.size.width / 2), y: -5)
                                    }else{
                                        Text("🚃")
                                            .position(x: geometry.size.width - 5, y: -5)
                                    }
                                }
                                
                            }
                    }
                    
                    Spacer()
                    
                    Text(context.state.nowStation)
                        .font(.system(size: 14))
                        .foregroundColor(Color(uiColor: .label))
                }
            }
            .frame(height: 85)
            .padding(15)
            .activityBackgroundTint(nil)
            .activitySystemActionForegroundColor(Color.black)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.line)
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                        .frame(
                            width: 50,
                            height: 50
                        )
                        .background{
                            Circle()
                                .fill(Color(context.attributes.line))
                        }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack{
                        Spacer()
                        Text(context.state.statusMSG)
                            .font(.system(size: 17))
                            .foregroundColor(Color(uiColor: .label))
                        Spacer()
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(alignment: .center, spacing: 0){
                        Text(context.attributes.saveStation)
                            .font(.system(size: 14))
                            .foregroundColor(Color(uiColor: .label))
                            .padding(.leading, 5)
                        
                        Spacer()
                        
                        VStack{
                            Divider()
                                .frame(height: 3)
                                .background(Color(context.attributes.line))
                                .overlay{
                                    HStack{
                                        Circle()
                                            .fill(Color.white)
                                            .overlay{
                                                Circle()
                                                    .strokeBorder(Color(context.attributes.line))
                                            }
                                            .frame(
                                                width: 12,
                                                height: 12
                                            )
                                        Spacer()
                                        
                                        Circle()
                                            .fill(Color.white)
                                            .overlay{
                                                Circle()
                                                    .strokeBorder(Color(context.attributes.line))
                                            }
                                            .frame(
                                                width: 12,
                                                height: 12
                                            )
                                    }
                                    
                                    GeometryReader{ geometry in
                                        if context.state.status == "0"{
                                            Text("🚃")
                                                .position(x: 25, y: -5)
                                        }else if context.state.status == "1"{
                                            Text("🚃")
                                                .position(x: 5, y: -5)
                                        }else if context.state.status == "2"{
                                            Text("🚃")
                                                .position(x: -5, y: -5)
                                        }else if context.state.status == "3"{
                                            Text("🚃")
                                                .position(x: (geometry.size.width / 2), y: -5)
                                        }else{
                                            Text("🚃")
                                                .position(x: geometry.size.width - 5, y: -5)
                                        }
                                    }
                                    
                                }
                        }
                        
                        Spacer()
                        
                        Text(context.state.nowStation)
                            .font(.system(size: 14))
                            .foregroundColor(Color(uiColor: .label))
                    }
                    .padding(5)
                }
            } compactLeading: {
                Text(context.attributes.line)
                    .font(.system(size: 13))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(context.attributes.line))
            } compactTrailing: {
                Text(context.state.statusMSG)
                    .font(.system(size: 13))
            } minimal: {
                Text(context.state.statusMSG)
                    .font(.system(size: 13))
                    .foregroundColor(Color(context.attributes.line))
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color(context.attributes.line))
        }
    }
    
}
