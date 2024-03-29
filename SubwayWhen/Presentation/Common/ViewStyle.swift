//
//  ViewStyle.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/26.
//

import UIKit

enum ViewStyle{
    enum FontSize{
        static let superSmallSize : CGFloat = 9
        static let mediumSmallSize : CGFloat = 11
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
    
    enum AnimateView {
        static let speed: CGFloat = 0.25
        static let size: CGFloat = 0.94
    }
}
