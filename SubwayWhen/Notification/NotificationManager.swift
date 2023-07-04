//
//  NotificationManager.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/28.
//

import Foundation

import RxSwift

class NotificationManager: NotificationManagerProtocol {
    static let shared: NotificationManagerProtocol = NotificationManager()
    private init() {}
    
    let bag = DisposeBag()
    
    let notiOpen = BehaviorSubject<SaveStation?>(value: nil)
    
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
    
    func notiScheduleAdd(data: NotificationManagerRequestData) {
        // 기본 값인 경우 무시
        guard data.id != "" else {return}
        
        let groupTitle = data.group == .one ? "출근" : "퇴근"
        let time = data.group == .one ? FixInfo.saveSetting.mainGroupOneTime : FixInfo.saveSetting.mainGroupTwoTime
        
        // 0시인 경우 무시
        guard time != 0 else {return}
        
        let content = UNMutableNotificationContent()
        content.title = "\(groupTitle)시간 알림"
        content.body = "\(data.useLine) \(data.stationName)역의 도착정보를 빠르게 확인하세요!"
        content.badge = 1
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: self.createDateComponents(hour: time),
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: data.id,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func notiTapAction(id: String) {
        for item in FixInfo.saveStation where item.id == id {
            self.notiOpen.onNext(item)
            break
        }
    }
    
    func notiRemove(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func notiAllRemove() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func notiTimeChange() {
        self.notiAllRemove()
        
        self.alertIDListLoad()
            .withUnretained(self)
            .subscribe(onNext: { manager, data in
                let nilData = NotificationManagerRequestData(id: "", stationName: "", useLine: "", line: "", group: .one)
                let nilDataTwo = NotificationManagerRequestData(id: "", stationName: "", useLine: "", line: "", group: .two)
                
                manager.notiScheduleAdd(data: data.first ?? nilData)
                manager.notiScheduleAdd(data: data.last ?? nilDataTwo)
            })
            .disposed(by: self.bag)
    }
    
    func alertIDListLoad() -> Observable<[NotificationManagerRequestData]> {
        let oneID = FixInfo.saveSetting.alertGroupOneID
        let one = self.idMatching(id: oneID, group: .one)
        let oneData = self.saveStationToSettingNotiModalData(data: one, group: .one)
        
        let twoID = FixInfo.saveSetting.alertGroupTwoID
        let two = self.idMatching(id: twoID, group: .two)
        let twoData = self.saveStationToSettingNotiModalData(data: two, group: .two)
        
        return Observable.just([oneData, twoData])
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
    
    func idMatching(id: String, group: SaveStationGroup) -> SaveStation? {
        FixInfo.saveStation.filter {
            $0.id == id && $0.group == group
        }
        .first
    }
    
    func saveStationToSettingNotiModalData(data: SaveStation?, group: SaveStationGroup) -> NotificationManagerRequestData {
        if let data = data {
            return NotificationManagerRequestData(
                id: data.id, stationName: data.stationName, useLine: data.useLine, line: data.line, group: data.group
            )
        } else {
            return NotificationManagerRequestData(id: "", stationName: "", useLine: "", line: "", group: group)
        }
        
    }
}
