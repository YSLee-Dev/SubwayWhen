//
//  DetailResultScheduleVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/25.
//

import UIKit

import RxSwift
import RxCocoa

class DetailResultScheduleVC : TableVCCustom{
    let bag = DisposeBag()
    
    let headerView = DetailResultScheduleHeader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attribute()
    }
}

extension DetailResultScheduleVC{
    private func attribute(){
        self.tableView.tableHeaderView = self.headerView
    }
    
    func bind(_ viewModel : DetailResultScheduleViewModel){
        viewModel.cellData
            .bind(to: self.rx.headerViewDataSet)
            .disposed(by: self.bag)
        
        viewModel.cellData
            .map{
                "\($0.useLine) \($0.upDown) \($0.stationName) 시간표"
            }
            .bind(to: self.rx.titleSet)
            .disposed(by: self.bag)
    }
}

extension Reactive where Base : DetailResultScheduleVC{
    var headerViewDataSet : Binder<MainTableViewCellData>{
        return Binder(base){ base, data in
            base.headerView.viewSet(excptionLastStation: data.exceptionLastStation, updown: data.upDown)
        }
    }
    
    var titleSet : Binder<String>{
        return Binder(base){base, title in
            base.viewTitle = title
        }
    }
}
