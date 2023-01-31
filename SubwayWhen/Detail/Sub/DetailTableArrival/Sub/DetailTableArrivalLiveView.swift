//
//  DetailTableArrivalLiveView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/31.
//

import UIKit

import SnapKit
import Then

class DetailTableArrivalLiveView : MainStyleUIView{
    var border = UIView()
    
    var nowStationCirecle = UIView().then{
        $0.layer.cornerRadius = 7.5
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1
    }
    
    var nowStationTitle = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.smallSize)
        $0.textAlignment = .left
    }
    
    var beforeStationCirecle = UIView().then{
        $0.layer.cornerRadius = 7.5
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1
    }
    
    var beforeStationTitle = UILabel().then{
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize)
        $0.textAlignment = .right
    }
    
    var trainIcon = UILabel().then{
        $0.text = "🚃"
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.mainTitleSize)
        $0.alpha = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DetailTableArrivalLiveView{
    private func layout(){
        [self.border, self.nowStationCirecle, self.beforeStationCirecle, self.nowStationTitle, self.beforeStationTitle, self.trainIcon]
            .forEach{
                self.addSubview($0)
            }
        
        self.border.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(5)
            $0.centerY.equalToSuperview().offset(-6.5)
        }
        
        self.nowStationCirecle.snp.makeConstraints{
            $0.size.equalTo(15)
            $0.centerY.equalTo(self.border)
            $0.centerX.equalTo(self.border.snp.leading)
        }
        
        self.nowStationTitle.snp.makeConstraints{
            $0.leading.equalTo(self.nowStationCirecle)
            $0.top.equalTo(self.nowStationCirecle.snp.bottom).offset(5)
        }
        
        self.beforeStationCirecle.snp.makeConstraints{
            $0.size.equalTo(15)
            $0.centerY.equalTo(self.border)
            $0.centerX.equalTo(self.border.snp.trailing)
        }
        
        self.beforeStationTitle.snp.makeConstraints{
            $0.trailing.equalTo(self.beforeStationCirecle)
            $0.top.equalTo(self.beforeStationCirecle.snp.bottom).offset(5)
        }
        
        self.trainIcon.snp.makeConstraints{
            $0.bottom.equalTo(self.border.snp.top).offset(5)
            $0.centerX.equalTo(self.beforeStationCirecle.snp.centerX)
        }
    }
    
    func viewSet(_ data : DetailTableViewCellData){
        self.border.backgroundColor = UIColor(named: data.lineNumber)
        self.nowStationCirecle.layer.borderColor = UIColor(named: data.lineNumber)?.cgColor
        self.beforeStationCirecle.layer.borderColor = UIColor(named: data.lineNumber)?.cgColor
        
        self.nowStationTitle.text = data.stationName
        self.beforeStationTitle.text = data.backStationName
    }
    
    func trainIconSet(_ code : String){
        guard let intCode = Int(code) else {return}
        
        self.trainIcon.alpha = 0...5 ~= intCode ? 1 : 0
        
        self.trainIcon.snp.remakeConstraints{
            $0.bottom.equalTo(self.border.snp.top).offset(5)
            
            switch intCode{
            case 0:
                $0.centerX.equalTo(self.nowStationCirecle.snp.trailing).offset(10)
            case 1:
                $0.centerX.equalTo(self.nowStationCirecle.snp.centerX)
            case 2:
                $0.centerX.equalTo(self.nowStationCirecle.snp.trailing).inset(10)
            case 3:
                $0.centerX.equalToSuperview()
            case 4:
                $0.centerX.equalTo(self.beforeStationCirecle.snp.trailing).offset(10)
            case 5:
                $0.centerX.equalTo(self.beforeStationCirecle.snp.centerX)
            default:
                break
            }
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [.allowUserInteraction]){
            self.layoutIfNeeded()
        }
    }
}
