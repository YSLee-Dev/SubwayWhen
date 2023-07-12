//
//  TableViewCellCustom.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/08.
//

import UIKit

import SnapKit
import Then

class TableViewCellCustom : UITableViewCell{
    var mainBG = UIView().then{
        $0.backgroundColor = UIColor(named: "MainColor")
        $0.layer.cornerRadius = ViewStyle.Layer.radius
        $0.layer.masksToBounds = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.attribute()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.tapBgcolorChange(isTap: highlighted)
    }
}

extension TableViewCellCustom{
    private func attribute(){
        self.selectionStyle = .none
    }
    
    private func layout(){
        self.contentView.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.top.bottom.equalToSuperview().inset(ViewStyle.padding.mainStyleViewTB)
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
        }
    }
    
    private func tapBgcolorChange(isTap: Bool) {
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
}
