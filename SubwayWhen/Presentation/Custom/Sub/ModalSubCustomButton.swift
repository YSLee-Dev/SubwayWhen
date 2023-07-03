//
//  ModalSubCustomButton.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/03.
//

import UIKit

class ModalSubCustomButton : UIButton{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ModalSubCustomButton {
    private func attribute(){
        self.layer.cornerRadius = ViewStyle.Layer.radius
        self.layer.masksToBounds = true
        self.titleLabel?.font = .systemFont(ofSize: ViewStyle.FontSize.mediumSize)
    }
}
