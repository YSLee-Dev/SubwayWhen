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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TabBarCustomButton{
    func seleted(){
        self.tintColor = .label
    }
    
    func unSeleted(){
        self.tintColor = .systemGray
    }
}
