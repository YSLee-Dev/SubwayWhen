//
//  ReportContentsModalVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/07.
//

import UIKit

import RxSwift
import RxCocoa

class ReportContentsModalVC : ModalVCCustom{
    let bag = DisposeBag()
    
    var reportContentsModalViewModel : ReportContentsModalViewModel
    
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then{
        $0.register(ReportContentsModalColletionViewCell.self, forCellWithReuseIdentifier: "ReportContentsModalColletionViewCell")
        $0.dataSource = nil
        $0.delegate = nil
    }
    
    init(modalHeight: CGFloat, viewModel : ReportContentsModalViewModel) {
        self.reportContentsModalViewModel = viewModel
        super.init(modalHeight: modalHeight, btnTitle: "다음", mainTitle: "지하철 민원", subTitle: "민원내용을 선택하거나 입력해주세요.")
        self.bind(self.reportContentsModalViewModel)
    }
    
    deinit{
        print("ReportCheckModalVC DEINIT")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attribute()
        self.layout()
    }
}

extension ReportContentsModalVC {
    private func attribute(){
        self.okBtn.removeFromSuperview()
        self.collectionView.collectionViewLayout = self.collectionViewLayout()
    }
    
    private func layout(){
        self.mainBG.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints{
            $0.top.equalTo(self.subTitle.snp.bottom).offset(10)
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
        }
    }
    
    func bind(_ viewModel : ReportContentsModalViewModel){
        viewModel.cellData
            .drive(self.collectionView.rx.items){ collectionView, row, data in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReportContentsModalColletionViewCell", for: IndexPath(row: row, section: 0)) as? ReportContentsModalColletionViewCell else {return UICollectionViewCell()}
                cell.cellSet(text: data.title, iconImg: UIImage(systemName: data.iconName) ?? .actions)
                return cell
            }
            .disposed(by: self.bag)
        
        self.collectionView.rx.modelSelected(ReportContentsModalCellData.self)
            .map{
                $0.contents
            }
            .bind(to: viewModel.contentsTap)
            .disposed(by: self.bag)
        
        viewModel.nextStep
            .drive(self.rx.pushCheckModal)
            .disposed(by: self.bag)
    }
    
    
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 3)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    override func modalDismiss() {
        self.reportContentsModalViewModel.close
            .accept(Void())
        super.modalDismiss()
    }
}

extension Reactive where Base : ReportContentsModalVC{
    var pushCheckModal : Binder<ReportMSGData>{
        return Binder(base){base, data in
            let model = ReportCheckModalViewModel()
            let check = ReportCheckModalVC(modalHeight: base.mainBG.frame.height, viewModel: model)
            
            model.msgData.onNext(data)
            
            base.navigationController?.pushViewController(check, animated: false)
        }
    }
}
