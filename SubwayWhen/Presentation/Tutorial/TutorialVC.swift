//
//  TutorialVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/09/22.
//

import UIKit

import SnapKit
import Then

import RxSwift
import RxCocoa
import RxDataSources

class TutorialVC: UIViewController {
    let mainTitle = TitleView()
    lazy var subTitle = MainStyleLabelView()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        $0.isScrollEnabled = false
        $0.register(TutorialCollectionFirstCell.self, forCellWithReuseIdentifier: TutorialCollectionFirstCell.id)
        $0.register(TutorialCollectionCell.self, forCellWithReuseIdentifier: TutorialCollectionCell.id)
        $0.backgroundColor = .systemBackground
        $0.delegate = nil
        $0.dataSource = nil
    }
    
    let viewModel: TutorialViewModel
    let bag = DisposeBag()
    
    init(
        viewModel: TutorialViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        self.attribute()
        self.layout()
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TutorialVC {
    private func attribute() {
        self.view.backgroundColor = .systemBackground
        self.mainTitle.mainTitleLabel.text = "지하철 민실씨를 \n설치해주셔서 감사합니다."
        
        self.collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: self.collectionViewLayout())
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
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.subTitle.snp.bottom).offset(20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    private func collectionViewLayout() -> NSCollectionLayoutSection{
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: ViewStyle.padding.mainStyleViewTB,
                                   leading: ViewStyle.padding.mainStyleViewLR,
                                   bottom: ViewStyle.padding.mainStyleViewTB, 
                                   trailing: ViewStyle.padding.mainStyleViewLR
        )
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        return section
    }
    
    private func bind() {
        let input = TutorialViewModel.Input(
            scrollRow: self.collectionView.rx.willDisplayCell
                .map {$0.at.row}
                .startWith(0)
                .asObservable(),
            scrollDone: self.collectionView.rx.didEndDisplayingCell
                .map {_ in Void()}
                .startWith(Void())
                .asObservable()
        )
        
        let output = self.viewModel.transform(input: input)
        
        let dataSources = RxCollectionViewSectionedAnimatedDataSource<TutorialSectionData>(
            animationConfiguration: .init(insertAnimation: .left),
            configureCell: {_, collectionView, index, data in
                switch index.row {
                case 0 :
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TutorialCollectionFirstCell.id, for: index) as? TutorialCollectionFirstCell else {
                        return UICollectionViewCell()
                    }
                    cell.bind(output.cellModel)
                    cell.okBtn.setTitle(data.btnTitle, for: .normal)
                    return cell
                default:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TutorialCollectionCell.id, for: index) as? TutorialCollectionCell else {
                        return UICollectionViewCell()
                    }
                    cell.bind(output.cellModel)
                    cell.cellSet(data)
                    return cell
                }
        })
        output.tutorialData
            .drive(self.collectionView.rx.items(dataSource: dataSources))
            .disposed(by: self.bag)
        
        output.title
            .drive(self.subTitle.titleLabel.rx.text)
            .disposed(by: self.bag)
        
        output.nextRow
            .drive(self.rx.nextRow)
            .disposed(by: self.bag)
    }
}

extension Reactive where Base: TutorialVC {
    var nextRow: Binder<Int> {
        return Binder(base) { base, row in
            base.collectionView.scrollToItem(at: IndexPath(row: row, section: 0), at: .right, animated: true)
        }
    }
}
