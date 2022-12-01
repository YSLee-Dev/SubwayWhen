//
//  GroupCustomButton.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/01.
//

import UIKit

class GroupCustomButton : UIButton{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GroupCustomButton {
    private func attribute(){
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        self.titleLabel?.font = .systemFont(ofSize: 16)
    }
    
    func seleted(){
        self.backgroundColor = .systemGray
        self.setTitleColor(.white, for: .normal)
    }
    
    func unSeleted(){
        self.layer.borderColor = UIColor.systemGray.cgColor
        self.layer.borderWidth = 0.5
        self.layer.masksToBounds = true
        self.backgroundColor = .clear
        self.setTitleColor(.systemGray, for: .normal)
    }
}
