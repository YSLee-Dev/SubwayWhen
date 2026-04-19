//
//  String+.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2026/04/19.
//

import Foundation

extension String {
    /// 노선명(self) 기준으로 방향 텍스트 반환 — 2호선·02호선은 내선/외선, 그 외는 상행/하행
    func upDownText(isUp: Bool) -> String {
        let isCircleLine = self == "2호선" || self == "02호선"
        if isCircleLine {
            return isUp ? Strings.Common.inner : Strings.Common.outer
        }
        return isUp ? Strings.Common.up : Strings.Common.down
    }

    /// 방향 텍스트(self)가 상행/내선 방향인지 여부
    var isUpDirection: Bool {
        self == Strings.Common.up || self == Strings.Common.inner
    }
}
