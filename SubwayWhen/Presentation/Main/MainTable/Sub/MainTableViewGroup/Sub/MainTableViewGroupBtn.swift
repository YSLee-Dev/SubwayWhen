//
//  GroupCustomButton.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/01.
//

import UIKit

class MainTableViewGroupBtn : UIButton{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainTableViewGroupBtn {
    private func attribute(){
        self.layer.cornerRadius = ViewStyle.Layer.radius
        self.layer.masksToBounds = true
        self.titleLabel?.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
    }
    
    func seleted(){
        self.setTitleColor(.label, for: .normal)
        self.layer.borderWidth = 1.2
        self.backgroundColor = .systemBackground
        self.layer.borderColor = UIColor(named: "AppIconColor")?.cgColor
    }
    
    func unSeleted(){
        self.setTitleColor(.systemGray, for: .normal)
        self.layer.borderWidth = 0.0
        self.backgroundColor = UIColor(named: "MainColor")
        self.layer.borderColor = UIColor.gray.cgColor
    }
}
