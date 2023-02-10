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
        self.backgroundColor = UIColor(named: "MainColor")
        self.layer.cornerRadius = ViewStyle.Layer.shadowRadius
        self.layer.masksToBounds = true
    }
}
