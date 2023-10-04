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
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        $0.isScrollEnabled = false
        $0.register(TutorialCollectionFirstCell.self, forCellWithReuseIdentifier: TutorialCollectionFirstCell.id)
        $0.register(TutorialCollectionLastCell.self, forCellWithReuseIdentifier: TutorialCollectionLastCell.id)
        $0.register(TutorialCollectionCell.self, forCellWithReuseIdentifier: TutorialCollectionCell.id)
        $0.backgroundColor = .systemBackground
    }
    
    let viewModel: TutorialViewModel
    let collectionViewRow = PublishSubject<Int>()
    let disappear = PublishSubject<Void>()
    let bag = DisposeBag()
    
    init(
        viewModel: TutorialViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.attribute()
        self.layout()
        self.bind()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.disappear.onNext(Void())
    }
    
}

extension TutorialVC {
    private func attribute() {
        self.view.backgroundColor = .systemBackground
        self.mainTitle.mainTitleLabel.text = "지하철 민실씨를 \n설치해주셔서 감사합니다."
        
        self.collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: self.collectionViewLayout())
    }
    
    private func layout() {
        [self.mainTitle, self.collectionView].forEach {
            self.view.addSubview($0)
        }
        
        self.mainTitle.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(48)
            $0.height.equalTo(45)
        }
        self.collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.mainTitle.snp.bottom).offset(20)
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
        section.orthogonalScrollingBehavior = .paging
        section.visibleItemsInvalidationHandler = { [weak self] _, contentOffset, environment in
            let value = contentOffset.x / environment.container.contentSize.width
            if value == floor(value) {
                self?.collectionViewRow.onNext(Int(value))
            }
        }
        
        return section
    }
    
    private func bind() {
        let input = TutorialViewModel.Input(
            scrollRow: self.collectionViewRow
                .asObservable(),
            disappear: self.disappear
                .asObservable()
        )
    
        let output = self.viewModel.transform(input: input)
        
        let dataSources = RxCollectionViewSectionedAnimatedDataSource<TutorialSectionData>(
            animationConfiguration: .init(insertAnimation: .fade),
            configureCell: {_, collectionView, index, data in
                switch index.row {
                case 0 :
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TutorialCollectionFirstCell.id, for: index) as? TutorialCollectionFirstCell else {
                        return UICollectionViewCell()
                    }
                    cell.bind(output.cellModel)
                    cell.okBtn.setTitle(data.btnTitle, for: .normal)
                    return cell
                case 6:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TutorialCollectionLastCell.id, for: index) as? TutorialCollectionLastCell else {
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
        
        output.nextRow
            .drive(self.rx.nextRow)
            .disposed(by: self.bag)
        
        output.lastRow
            .drive(self.rx.lastRow)
            .disposed(by: self.bag)
    }
}

extension Reactive where Base: TutorialVC {
    var nextRow: Binder<Int> {
        return Binder(base) { base, row in
            base.collectionView.scrollToItem(at: IndexPath(row: row, section: 0), at: .right, animated: true)
        }
    }
    
    var lastRow: Binder<Bool> {
        return Binder(base) { base, isLast in
            UIView.animate(withDuration: 0.3, animations: {
                if isLast {
                    base.view.backgroundColor = UIColor(named: "AppIconColor")
                    base.collectionView.backgroundColor = UIColor(named: "AppIconColor")
                    base.mainTitle.backgroundColor = UIColor(named: "AppIconColor")
                    base.mainTitle.mainTitleLabel.textColor = .white
                } else {
                    if base.view.backgroundColor != .systemBackground {
                        base.view.backgroundColor = .systemBackground
                        base.collectionView.backgroundColor = .systemBackground
                        base.mainTitle.backgroundColor = .systemBackground
                        base.mainTitle.mainTitleLabel.textColor = .label
                    }
                }
            })
        }
    }
}
