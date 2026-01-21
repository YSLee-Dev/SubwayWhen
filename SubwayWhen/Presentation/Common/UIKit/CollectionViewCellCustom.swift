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
        if isTap {
            UIView.animate(withDuration: ViewStyle.AnimateView.speed, delay: 0, options: [.curveEaseOut],  animations: {
                self.mainBG.transform = CGAffineTransform(scaleX: ViewStyle.AnimateView.size, y: ViewStyle.AnimateView.size)
                self.mainBG.backgroundColor = UIColor(named: "ButtonTappedColor")
            })
        }else {
            UIView.animate(withDuration: ViewStyle.AnimateView.speed, delay: 0.1, options: [.curveEaseOut],  animations: {
                self.mainBG.backgroundColor = UIColor(named: "MainColor")
                self.mainBG.transform = .identity
            })
        }
    }
    
    func layout() {
        self.contentView.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
    }
}
