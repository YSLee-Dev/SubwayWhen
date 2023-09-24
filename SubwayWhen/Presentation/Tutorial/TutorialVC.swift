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
        title.font = .boldSystemFont(ofSize: ViewStyle.FontSize.largeSize)
        title.textAlignment = .left
        title.adjustsFontSizeToFitWidth = true
        title.numberOfLines = 0
        title.text = "다음 버튼을 누르면, 민실씨의 기능을 확인할 수 있어요."
        
        mainBg.addSubview(title)
        title.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
        return mainBg
    }()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        $0.backgroundColor = .systemBackground
        $0.delegate = nil
        $0.dataSource = nil
    }
    
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
        
        self.collectionView.collectionViewLayout = self.collectionViewLayout()
    }
    
    private func layout() {
        [self.mainTitle, self.subTitle, self.collectionView].forEach {
            self.view.addSubview($0)
        }
        
        self.mainTitle.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(45)
            $0.height.equalTo(45)
        }
        self.subTitle.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.top.equalTo(self.mainTitle.snp.bottom).offset(20)
        }
        self.collectionView.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.subTitle)
            $0.top.equalTo(self.subTitle.snp.bottom).offset(20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    private func collectionViewLayout() -> UICollectionViewLayout{
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutDecorationItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
