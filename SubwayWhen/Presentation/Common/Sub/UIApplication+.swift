//
//  UIWindow+.swift
//  SubwayWhen
//
//  Created by 이윤수 on 4/22/24.
//

import UIKit

extension UIApplication {
    enum SafeAreaPosition {
        case top, bottom, left, right
    }
    
    func safeAreaSize(position: SafeAreaPosition) -> CGFloat {
        guard let windowScene =  UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let safeArea =  windowScene.windows.first?.safeAreaInsets else {return 0}
        
        return switch position {
        case .top: safeArea.top
        case .bottom: safeArea.bottom
        case .left: safeArea.left
        case .right: safeArea.right
        }
    }
}
