//
//  DetailTableScheduleCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/17.
//

import UIKit

import RxSwift
import RxCocoa
import RxOptional
import SnapKit
import Then

class DetailTableScheduleCell : TableViewCellCustom{
    var mainTitle = UILabel().then{
        $0.textColor = .label
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.adjustsFontSizeToFitWidth = true
        $0.textAlignment = .left
        $0.text = "시간표를 불러오고 있습니다."
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then{
        $0.backgroundColor = UIColor(named: "MainColor")
        $0.register(DetailTableScheduleCellSubCell.self, forCellWithReuseIdentifier: "DetailTableScheduleCellSubCell")
        $0.collectionViewLayout = self.collectionViewLayout()
        $0.delegate = nil
        $0.dataSource = nil
    }
    
    var moreBtn = UIButton().then{
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.tintColor = .label
    }
    
    let refreshIcon = UIRefreshControl()
    
    var cellData : DetailTableViewCellData?
    
    var bag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layout()
        self.attribute()
    }
    
    override func prepareForReuse() {
        self.bag = DisposeBag()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DetailTableScheduleCell{
    private func layout(){
        self.mainBG.addSubview(self.mainTitle)
        self.mainTitle.snp.makeConstraints{
            $0.leading.top.trailing.equalToSuperview().inset(15)
        }
        
        self.mainBG.addSubview(self.moreBtn)
        self.moreBtn.snp.makeConstraints{
            $0.size.equalTo(25)
            $0.trailing.equalToSuperview().inset(15)
            $0.centerY.equalTo(self.mainTitle)
        }
        
        self.mainBG.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints{
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(self.mainTitle.snp.bottom).offset(15)
            $0.height.equalTo(200)
        }
        
        self.collectionView.addSubview(self.refreshIcon)
        self.refreshIcon.snp.makeConstraints{
            $0.center.equalTo(self.mainBG)
        }
    }
    
    private func attribute(){
        self.refreshIcon.beginRefreshing()
    }
    
    func bind(_ viewModel : DetailTableScheduleCellModel){
        viewModel.cellData
            .drive(self.collectionView.rx.items){[weak self] cv, row, data in
                guard let cell = cv.dequeueReusableCell(withReuseIdentifier: "DetailTableScheduleCellSubCell", for: IndexPath(row: row, section: 0)) as? DetailTableScheduleCellSubCell else {return UICollectionViewCell()}
                
                guard let cellData = self?.cellData else {return UICollectionViewCell()}
                
                if data.startTime == "정보없음"{
                    cell.cellSet(data, color: .gray)
                }else{
                    cell.cellSet(data, color: UIColor(named: cellData.lineNumber) ?? .systemBackground)
                }
                
                self?.refreshIcon.endRefreshing()
                
                return cell
            }
            .disposed(by: self.bag)
        
        viewModel.cellData
            .map{ data -> String? in
                guard let first = data.first else {return nil}
                
                if first.startTime == "정보없음"{
                    return "시간표를 불러올 수 없어요."
                }else{
                    if FixInfo.saveSetting.detailScheduleAutoTime{
                        return "\(first.lastStation)행 \(first.useArrTime) : \(first.useTime)남음"
                    }else{
                        return ""
                    }
                }
            }
            .filterNil()
            .drive(self.mainTitle.rx.text)
            .disposed(by: self.bag)
        
        self.moreBtn.rx.tap
            .bind(to: viewModel.moreBtnClick)
            .disposed(by: self.bag)
    }
    
    func cellSet(_ data : DetailTableViewCellData){
        self.cellData = data
    }
    
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension:.fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
