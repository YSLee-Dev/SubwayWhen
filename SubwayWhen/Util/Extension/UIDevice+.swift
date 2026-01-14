//
//  UIDevice+.swift
//  SubwayWhen
//
//  Created by 이윤수 on 9/29/25.
//

import UIKit

extension UIDevice {
    static var isiOS26OrLater: Bool {
        if #available(iOS 26, *) {
            return true
        }
        return false
    }
}
