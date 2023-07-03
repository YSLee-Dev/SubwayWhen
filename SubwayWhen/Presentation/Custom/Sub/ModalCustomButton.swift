//
//  CButton.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import UIKit

class ModalCustomButton : UIButton{
    var bgColor: UIColor
    var customTappedBG: String?
    
    init(bgColor: UIColor, customTappedBG: String?) {
        self.bgColor = bgColor
        self.customTappedBG = customTappedBG
        
        super.init(frame: .zero)
        self.attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.tapBgcolorChange(isTap: self.isHighlighted)
        }
    }
}

extension ModalCustomButton {
    private func attribute(){
        self.backgroundColor = self.bgColor
        self.layer.cornerRadius = ViewStyle.Layer.radius
        self.layer.masksToBounds = true
        self.titleLabel?.font = .systemFont(ofSize: ViewStyle.FontSize.mediumSize)
    }
    
    private func tapBgcolorChange(isTap: Bool) {
        if isTap {
            UIView.animate(withDuration: ViewStyle.AnimateView.speed, delay: 0, options: [.curveEaseOut],  animations: {
                self.transform = CGAffineTransform(scaleX: ViewStyle.AnimateView.size, y: ViewStyle.AnimateView.size)
                
                if self.customTappedBG == nil {
                    self.backgroundColor = UIColor(named: "ButtonTappedColor")
                } else {
                    self.backgroundColor = UIColor(named: "\(self.customTappedBG ?? "")TappedColor")
                }
                
            })
        }else {
            UIView.animate(withDuration: ViewStyle.AnimateView.speed, delay: 0.1, options: [.curveEaseOut],  animations: {
                self.backgroundColor = self.bgColor
                self.transform = .identity
                
            })
        }
    }
}
