//
//  NotificationManagerProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/28.
//

import Foundation

import RxSwift

protocol NotificationManagerProtocol {
    var notiOpen : BehaviorSubject<SaveStation?>{get}
    
    func authCheck() -> Observable<Bool>
    func notiScheduleAdd(data: NotificationManagerRequestData)
    func notiTapAction(id: String)
    func notiRemove(id: String)
    func alertIDListLoad() -> Observable<[NotificationManagerRequestData]>
    func notiTimeChange()
    func notiAllRemove() 
}
