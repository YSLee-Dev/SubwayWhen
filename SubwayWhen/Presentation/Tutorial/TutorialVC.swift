//
//  TutorialVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/09/22.
//

import UIKit

import SnapKit
import Then

class TutorialVC: UIViewController {
    let mainTitle = TitleView()
    lazy var subTitle: MainStyleUIView = {
        let mainBg = MainStyleUIView()
        
        let title = UILabel()
        title.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mainTitleSize)
        title.textAlignment = .left
        title.adjustsFontSizeToFitWidth = true
        title.text = "다음 버튼을 누르면, 민실씨의 기능을 확인할 수 있어요."
        
        mainBg.addSubview(title)
        title.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        return mainBg
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        self.attribute()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TutorialVC {
    private func attribute() {
        self.view.backgroundColor = .systemBackground
        self.mainTitle.mainTitleLabel.text = "지하철 민실씨를 \n설치해주셔서감사합니다."
    }
    
    private func layout() {
        [self.mainTitle, self.subTitle].forEach {
            self.view.addSubview($0)
        }
        
        self.mainTitle.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(45)
        }
        self.subTitle.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.mainTitle.snp.bottom)
            $0.height.equalTo(30)
        }
    }
}
