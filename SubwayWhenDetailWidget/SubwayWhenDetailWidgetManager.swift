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
    private var live : Activity<SubwayWhenDetailWidgetAttributes>?
    
    static let shared = SubwayWhenDetailWidgetManager()
    
    func start(stationLine : String, saveStation : String, scheduleList : [String], lastUpdate : String){
        guard self.live == nil else {return}
        
        let attributes = SubwayWhenDetailWidgetAttributes(line: stationLine, saveStation: saveStation)
        let contentState = SubwayWhenDetailWidgetAttributes.ContentState(scheduleList: scheduleList, lastUpdate: lastUpdate)
        
        if #available(iOS 16.2, *){
            do {
                let activity = try Activity<SubwayWhenDetailWidgetAttributes>.request(
                    attributes: attributes,
                    content: ActivityContent(state: contentState, staleDate: .now.advanced(by: 120))
                )
                self.live = activity
            } catch {
                AppLogger.liveActivity.log(.error, error.localizedDescription)
            }
        }else{
            do {
                let activity = try Activity<SubwayWhenDetailWidgetAttributes>.request(
                    attributes: attributes,
                    contentState: contentState
                )
                self.live = activity
            } catch {
                AppLogger.liveActivity.log(.error, error.localizedDescription)
            }
        }
    }
    
    func update(scheduleList : [String], lastUpdate : String){
        Task {
            let updateContentState = SubwayWhenDetailWidgetAttributes.ContentState(scheduleList: scheduleList, lastUpdate: lastUpdate)
            if #available(iOS 16.2, *){
                await self.live?.update(ActivityContent(state: updateContentState, staleDate: .now.advanced(by: 120)), alertConfiguration: nil)
            }else{
                await self.live?.update(using: updateContentState, alertConfiguration: nil)
            }
        }
    }
    
    func stop() {
        Task{
            if #available(iOS 16.2, *){
                await self.live?.end(.none, dismissalPolicy: .immediate)
                AppLogger.liveActivity.log(.debug, "liveActivity 정지")
            }else{
                await self.live?.end(dismissalPolicy: .immediate)
                AppLogger.liveActivity.log(.debug, "liveActivity 정지")
            }
            self.live = nil
        }
    }
    
    func allLiveStop(){
        Task{
            for x in Activity<SubwayWhenDetailWidgetAttributes>.activities{
                if #available(iOS 16.2, *){
                    await x.end(.none, dismissalPolicy: .immediate)
                    AppLogger.liveActivity.log(.debug, "liveActivity 정지")
                }else{
                    await x.end(dismissalPolicy: .immediate)
                    AppLogger.liveActivity.log(.debug, "liveActivity 정지")
                }
            }
        }
    }
}
