//
//  ReportContentsModalTFView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/08.
//

import UIKit

import SnapKit
import Then

import RxSwift
import RxCocoa
import RxOptional

class ReportContentsModalTFView : UICollectionReusableView{
    let bag = DisposeBag()
    
    let mainBG = MainStyleUIView()
    
    let textTf = UITextField().then{
        $0.placeholder = "민원 내용을 직접 입력할 수 있어요."
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: ViewStyle.FontSize.smallSize)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ReportContentsModalTFView{
    private func layout(){
        self.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.top.bottom.equalToSuperview().inset(10)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        
        self.mainBG.addSubview(self.textTf)
        self.textTf.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(_ viewModel : ReportContentsModalTFViewModelProtocol){
        self.textTf.rx.controlEvent(.editingDidEnd)
            .withLatestFrom(self.textTf.rx.text)
            .filterNil()
            .bind(to: viewModel.inputText)
            .disposed(by: self.bag)
    }
}
