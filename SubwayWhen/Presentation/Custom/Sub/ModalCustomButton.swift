//
//  CButton.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import UIKit

class ModalCustomButton : UIButton{
    var bgColor: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        self.layer.cornerRadius = ViewStyle.Layer.radius
        self.layer.masksToBounds = true
        self.titleLabel?.font = .systemFont(ofSize: ViewStyle.FontSize.mediumSize)
    }
    
    private func tapBgcolorChange(isTap: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            if isTap {
                if self.bgColor == nil {
                    self.bgColor = self.backgroundColor
                }
                
                self.subviews.forEach{
                    $0.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
                }
                
                self.backgroundColor = UIColor(named: "ButtonTappedColor")
            }else {
                self.backgroundColor = self.bgColor
                
                self.subviews.forEach{
                    $0.transform = .identity
                }
            }
        })
    }
}
