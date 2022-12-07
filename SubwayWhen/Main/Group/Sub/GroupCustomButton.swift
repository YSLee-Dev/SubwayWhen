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
        self.layer.borderColor = UIColor.gray.cgColor
        self.backgroundColor = UIColor(named: "MainColor")
    }
    
    func seleted(){
        self.setTitleColor(.label, for: .normal)
        self.layer.borderWidth = 1.0
    }
    
    func unSeleted(){
        self.setTitleColor(.systemGray, for: .normal)
        self.layer.borderWidth = 0.0
    }
}
