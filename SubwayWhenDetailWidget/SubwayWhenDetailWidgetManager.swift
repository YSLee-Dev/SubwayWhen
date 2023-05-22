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
    
    func start(stationLine : String, saveStation : String, scheduleList : [String], lastUpdate : String){
        let attributes = SubwayWhenDetailWidgetAttributes(line: stationLine, saveStation: saveStation)
        let contentState = SubwayWhenDetailWidgetAttributes.ContentState(scheduleList: scheduleList, lastUpdate: lastUpdate)
        
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
    
    func update(scheduleList : [String], lastUpdate : String){
        Task {
            let updateContentState = SubwayWhenDetailWidgetAttributes.ContentState(scheduleList: scheduleList, lastUpdate: lastUpdate)
            for activity in Activity<SubwayWhenDetailWidgetAttributes>.activities {
                if #available(iOS 16.2, *){
                    await activity.update(ActivityContent(state: updateContentState, staleDate: .now.advanced(by: 120)), alertConfiguration: nil)
                }else{
                    await activity.update(using: updateContentState, alertConfiguration: nil)
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
