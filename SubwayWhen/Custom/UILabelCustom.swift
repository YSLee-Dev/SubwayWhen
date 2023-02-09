//
//  UILabelCustom.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/10.
//

import UIKit

class UILabelCustom : UILabel{
    private var padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.attribute()
        self.padding = padding
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: self.padding))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + self.padding.left + self.padding.right,
                      height: size.height + self.padding.top +  self.padding.bottom)
    }
    
    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width - (self.padding.left + self.padding.right)
        }
    }
}

extension UILabelCustom{
    private func attribute(){
        self.layer.masksToBounds = true
        self.layer.cornerRadius =  ViewStyle.Layer.shadowRadius
        self.adjustsFontSizeToFitWidth = true
    }
}
