//
//  NotificationManager.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/28.
//

import Foundation

import RxSwift

class NotificationManager: NotificationManagerProtocol {
    func authCheck() -> Observable<Bool> {
        let auth = PublishSubject<Bool>()
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge],
            completionHandler: { (granted, _) in
                auth.onNext(granted)
            }
        )
        
        return auth
    }
    
    func notiScheduleAdd(data: SettingNotiModalData) {
        // 기본 값인 경우 무시
        guard data.id != "" else {return}
        
        let groupTitle = data.group == .one ? "출근" : "퇴근"
        let time = data.group == .one ? FixInfo.saveSetting.mainGroupOneTime : FixInfo.saveSetting.mainGroupTwoTime
        
        let content = UNMutableNotificationContent()
        content.title = "지하철 민실씨 \(groupTitle)시간 알림"
        content.body = "\(data.stationName)역의 도착정보를 빠르게 확인하세요!"
        content.badge = 1
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: self.createDateComponents(hour: time),
            repeats: true
        )
        
        let testTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: data.id,
            content: content,
            trigger: testTrigger
        )
       print(request)
        UNUserNotificationCenter.current().add(request)
    }
}

private extension NotificationManager {
    func createDateComponents(hour: Int) -> DateComponents {
        var components = DateComponents()
        components.calendar = Calendar.current
        
        components.hour = hour
        components.minute = 0
        
        return components
    }
}
