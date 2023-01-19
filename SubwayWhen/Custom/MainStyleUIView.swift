//
//  MainStyleUIView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/19.
//

import UIKit

class MainStyleUIView : UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MainStyleUIView{
    private func attribute(){
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 15
        self.backgroundColor = UIColor(named: "MainColor")
    }
}
