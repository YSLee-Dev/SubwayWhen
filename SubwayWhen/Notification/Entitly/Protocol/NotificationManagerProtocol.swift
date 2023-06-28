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
    func notiScheduleAdd(data: SettingNotiModalData)
    func notiTapAction(id: String)
}
