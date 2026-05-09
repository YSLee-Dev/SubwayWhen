//
//  MockRealtimeVCDelegate.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 4/20/26.
//

@testable import SubwayWhen

final class MockRealtimeVCDelegate: RealtimeVCDelegate {
    var calledPop: Bool = false
    var calledDisappear: Bool = false
    var calledShowBundleError: Bool = false
    var calledExceptionRemove: Bool = false

    func pop() {
        self.calledPop = true
    }

    func disappear() {
        self.calledDisappear = true
    }

    func showBundleErrorPopupAndDismiss() {
        self.calledShowBundleError = true
    }

    func exceptionRemove() {
        self.calledExceptionRemove = true
    }
}
