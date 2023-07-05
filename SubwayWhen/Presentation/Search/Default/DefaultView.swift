//
//  DefaultView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/29.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

import SnapKit
import Then

class DefaultView : UIView{
    let bag = DisposeBag()
    
    var listCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then{
        $0.backgroundColor = .systemBackground
        $0.register(DefaultViewCell.self, forCellWithReuseIdentifier: "DefaultViewCell")
        $0.register(LocationView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "LocationView")
        $0.dataSource = nil
        $0.delegate = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layout()
        self.attibute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DefaultView{
    private func layout(){
        self.addSubview(self.listCollectionView)
        self.listCollectionView.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
    }
    
    private func attibute(){
        self.listCollectionView.collectionViewLayout = self.collectionViewLayout()
        self.backgroundColor = .systemBackground
    }
    
    func bind(_ viewModel : DefaultViewModelProtocol){
        // VIEWMODEL -> VIEW
        let dataSources = RxCollectionViewSectionedAnimatedDataSource<DefaultSectionData>(
            animationConfiguration: .init(insertAnimation: .fade),
            configureCell: { _, cv, index, data in
                guard let cell = cv.dequeueReusableCell(withReuseIdentifier: "DefaultViewCell", for: index) as? DefaultViewCell else {return UICollectionViewCell()}
                cell.stationName.text = data.title
                return cell
        })
        
        dataSources.configureSupplementaryView = {_, cv, kind, index in
            guard let header = cv.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LocationView", for: index) as? LocationView else {return UICollectionReusableView()}
            header.animationPlay()
            
            header.okBtn.rx.tap
                .bind(to: viewModel.locationBtnTap)
                .disposed(by: self.bag)
            
            return header
        }
        
        viewModel.listData
            .drive(self.listCollectionView.rx.items(dataSource: dataSources))
            .disposed(by: self.bag)
        
        // VIEW -> VIEWMODEL
        self.listCollectionView.rx.modelSelected(DefaultCellData.self)
            .map {$0.title}
            .bind(to: viewModel.defaultListClick)
            .disposed(by: self.bag)
    }
    
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let grouptSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(65))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: grouptSize, repeatingSubitem: item, count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(290))
        
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        ]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
