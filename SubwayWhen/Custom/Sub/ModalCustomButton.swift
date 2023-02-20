//
//  CButton.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import UIKit

class ModalCustomButton : UIButton{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ModalCustomButton {
    private func attribute(){
        self.layer.cornerRadius = ViewStyle.Layer.shadowRadius
        self.layer.masksToBounds = true
        self.titleLabel?.font = .systemFont(ofSize: ViewStyle.FontSize.mediumSize)
    }
}
