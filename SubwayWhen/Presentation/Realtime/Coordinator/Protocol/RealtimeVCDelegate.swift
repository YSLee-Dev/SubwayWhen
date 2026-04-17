//
//  RealtimeVCDelegate.swift
//  SubwayWhen
//
//  Created by 이윤수 on 4/9/26
//

protocol RealtimeVCDelegate: AnyObject {
    func showBundleErrorPopupAndDismiss()
    func pop()
    func disappear()
}
