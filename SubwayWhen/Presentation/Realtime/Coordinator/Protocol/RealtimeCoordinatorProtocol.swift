//
//  RealtimeCoordinatorProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 4/9/26
//

protocol RealtimeCoordinatorProtocol: AnyObject {
    func showBundleErrorPopupAndDismiss()
    func pop()
    func disappear(reportCoordinator : RealtimeCoordinator)
}
