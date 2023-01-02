//
//  DetailVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/02.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class DetailVC : TableVCCustom{
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

extension DetailVC{
    
    func bind(_ viewModel : DetailViewModel){
        // VIEWMODEL -> VIEW
        viewModel.setTitleText
            .drive(self.rx.titleViewSet)
            .disposed(by: self.bag)
        
    }
}

extension Reactive where Base : DetailVC{
    var titleViewSet : Binder<String>{
        return Binder(base){ base, text in
            base.titleView.titleLabel.text = text
        }
    }
}
