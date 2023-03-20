//
//  ViewStyle.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/26.
//

import UIKit

import Toast_Swift

enum ViewStyle{
    enum FontSize{
        static let superSmallSize : CGFloat = 9
        static let smallSize : CGFloat = 13
        static let mediumSize : CGFloat = 15
        static let largeSize : CGFloat = 17
        static let mainTitleMediumSize : CGFloat = 21
        static let mainTitleSize : CGFloat = 23
    }
    
    enum Layer{
        static let radius : CGFloat = 15
    }
    
    enum padding{
        static let mainStyleViewLR : CGFloat = 20
        static let mainStyleViewTB : CGFloat = 7.5
    }
    
    static var toastStyle : ToastStyle{
        var style = ToastStyle()
        style.cornerRadius = ViewStyle.Layer.radius
        style.messageFont = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        style.backgroundColor = UIColor(named: "AppIconColor")?.withAlphaComponent(0.8) ?? .systemBackground
        
        return style
    }
}
