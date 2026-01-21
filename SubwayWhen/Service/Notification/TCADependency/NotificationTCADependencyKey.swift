//
//  NotificationTCADependencyKey.swift
//  SubwayWhen
//
//  Created by 이윤수 on 9/19/25.
//

import Foundation
import ComposableArchitecture

enum NotificationTCADependencyKey: DependencyKey {
    static var liveValue: NotificationManagerProtocol = NotificationManager.shared
    static let testValue: NotificationManagerProtocol = NotificationManager.shared
    /// Notification은 TCA 환경에서 사용이 제한적이여서 (View에 표시되지 않으며, Notification refresh만 요청함) Preview를 만들지 않음
}
