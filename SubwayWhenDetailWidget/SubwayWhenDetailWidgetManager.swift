//
//  SubwayWhenDetailWidgetManager.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/05/09.
//

import Foundation

import SwiftUI
import ActivityKit

class SubwayWhenDetailWidgetManager{
    private init(){}
    
    static let shared = SubwayWhenDetailWidgetManager()
    
    func start(stationLine : String, saveStation : String, nowStation : String, status : String, statusMSG : String){
        let attributes = SubwayWhenDetailWidgetAttributes(line: stationLine, saveStation: saveStation)
        let contentState = SubwayWhenDetailWidgetAttributes.ContentState(status: status, statusMSG: statusMSG, nowStation: nowStation)
        
        if #available(iOS 16.2, *){
            do {
                let activity = try Activity<SubwayWhenDetailWidgetAttributes>.request(
                    attributes: attributes,
                    content: ActivityContent(state: contentState, staleDate: .now.advanced(by: 120))
                )
                print(activity)
            } catch {
                print(error)
            }
        }else{
            do {
                let activity = try Activity<SubwayWhenDetailWidgetAttributes>.request(
                    attributes: attributes,
                    contentState: contentState
                )
                print(activity)
            } catch {
                print(error)
            }
        }
    }
    
    func update(status : String, statusMSG : String, nowStation : String){
        Task {
            let updateContentState = SubwayWhenDetailWidgetAttributes.ContentState(status: status, statusMSG: statusMSG, nowStation: nowStation)
            for activity in Activity<SubwayWhenDetailWidgetAttributes>.activities {
                if #available(iOS 16.2, *){
                    await activity.update(ActivityContent(state: updateContentState, staleDate: .now.advanced(by: 120)),
                                          alertConfiguration: .init(title: "\(statusMSG)", body: "\(nowStation)", sound: .named(""))
                    )
                }else{
                    await activity.update(using: updateContentState,  alertConfiguration: .init(title: "\(statusMSG)", body: "\(nowStation)", sound: .named("")))
                }
               
            }
        }
    }
    
    func stop() {
      Task {
        for activity in Activity<SubwayWhenDetailWidgetAttributes>.activities {
          await activity.end(dismissalPolicy: .immediate)
        }
      }
    }
}
