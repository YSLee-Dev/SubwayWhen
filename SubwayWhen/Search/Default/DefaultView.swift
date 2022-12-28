//
//  DefaultView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/29.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

class DefaultView : UIView{
    let bag = DisposeBag()
    
    let markLabel = UILabel().then{
        $0.text = " 💡 많은 사람들이 이용하는 지하철역을 골라봤어요."
        $0.font = .systemFont(ofSize: 14)
        $0.backgroundColor = UIColor(named: "MainColor")
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
    }
    
    var listCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then{
        $0.backgroundColor = .systemBackground
        $0.register(DefaultViewCell.self, forCellWithReuseIdentifier: "DefaultViewCell")
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
        self.addSubview(self.markLabel)
        self.markLabel.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        self.addSubview(self.listCollectionView)
        self.listCollectionView.snp.makeConstraints{
            $0.top.equalTo(self.markLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func attibute(){
        self.listCollectionView.collectionViewLayout = self.collectionViewLayout()
        self.backgroundColor = .systemBackground
    }
    
    func bind(_ viewModel : DefaultViewModel){
        // VIEWMODEL -> VIEW
        viewModel.listData
            .drive(self.listCollectionView.rx.items){cv, row, data in
                guard let cell = cv.dequeueReusableCell(withReuseIdentifier: "DefaultViewCell", for: IndexPath(row: row, section: 0)) as? DefaultViewCell else {return UICollectionViewCell()}
                cell.stationName.text = data
                return cell
            }
            .disposed(by: self.bag)
        
        // VIEW -> VIEWMODEL
        self.listCollectionView.rx.modelSelected(String.self)
            .bind(to: viewModel.defaultListClick)
            .disposed(by: self.bag)
    }
    
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let grouptSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: grouptSize, repeatingSubitem: item, count: 2)
    
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
