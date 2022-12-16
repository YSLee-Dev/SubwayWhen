//
//  TabBarCustomButton.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/16.
//

import UIKit

class TabBarCustomButton : UIButton{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TabBarCustomButton{
    private func attribute(){
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.size.width / 2
        
    }
    
    func seleted(title : String){
        self.setTitleColor(.label, for: .normal)
        self.layer.borderWidth = 1.0
        self.setTitle(title, for: .normal)
    }
    
    func unSeleted(){
        self.setTitleColor(.systemGray, for: .normal)
        self.layer.borderWidth = 0
    }
}
