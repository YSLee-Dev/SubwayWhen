//
//  CollectionViewCellCustom.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/03.
//

import UIKit

class CollectionViewCellCustom: UICollectionViewCell {
    var mainBG = UIView().then{
        $0.backgroundColor = UIColor(named: "MainColor")
        $0.layer.cornerRadius = ViewStyle.Layer.radius
        $0.layer.masksToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layout()
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

private extension CollectionViewCellCustom {
    func tapBgcolorChange(isTap: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            if isTap {
                self.mainBG.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
                self.mainBG.backgroundColor = UIColor(named: "ButtonTappedColor")
            }else {
                self.mainBG.backgroundColor = UIColor(named: "MainColor")
                self.mainBG.transform = .identity
            }
        })
    }
    
    func layout() {
        self.contentView.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
    }
}
