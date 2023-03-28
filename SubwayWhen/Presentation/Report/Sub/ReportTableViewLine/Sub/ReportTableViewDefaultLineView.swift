//
//  ReportTableViewDefaultLineView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/06.
//

import UIKit

import RxSwift
import RxCocoa

import Then
import SnapKit

class ReportTableViewDefaultLineView : UIView{
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then{
        $0.backgroundColor = UIColor(named: "MainColor")
        $0.register(ReportTableViewDefaultLineCell.self, forCellWithReuseIdentifier: "ReportTableViewDefaultLineCell")
        $0.dataSource = nil
        $0.delegate = nil
        $0.layer.cornerRadius = ViewStyle.Layer.radius
        $0.contentInset = .init(top: 0, left: 10, bottom: 0, right: 0)
    }
    
    lazy var noListLabel = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.smallSize)
        $0.textColor = .gray
        $0.textAlignment = .center
        $0.text = "저장된 지하철 역이 없어요."
    }
    
    let bag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.attirbute()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ReportTableViewDefaultLineView{
    private func attirbute(){
        self.collectionView.collectionViewLayout = self.collectionViewLayout()
    }
    
    private func layout(){
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(_ viewModel : ReportTableViewDefaultLineViewModelProtocol){
        viewModel.cellData
            .drive(self.collectionView.rx.items){ collectionView, row, data in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReportTableViewDefaultLineCell", for: IndexPath(row: row, section: 0)) as? ReportTableViewDefaultLineCell else {return UICollectionViewCell()}
                cell.lineName.text = data
                cell.viewColorSet(UIColor(named: data) ?? .systemBackground)
                return cell
            }
            .disposed(by: self.bag)
        
        viewModel.cellData
            .map{
                $0.isEmpty
            }
            .filter{$0}
            .drive(onNext: {[weak self] _ in
                self?.noListLabelShow()
            })
            .disposed(by: self.bag)
        
        self.collectionView.rx.modelSelected(String.self)
            .map{
                ReportBrandData(rawValue: $0) ?? .not
            }
            .bind(to: viewModel.cellClick)
            .disposed(by: self.bag)
    }
    
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .absolute(50))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 10, leading: 5, bottom: 10, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 4)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func noListLabelShow(){
        self.addSubview(self.noListLabel)
        self.noListLabel.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
    }
}
