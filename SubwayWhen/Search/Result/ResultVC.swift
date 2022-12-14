//
//  ResultVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class ResultVC : UITableViewController{
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        self.attribute()
    }
}

extension ResultVC{
    private func attribute(){
        self.tableView.dataSource = nil
        self.tableView.register(ResultVCCell.self, forCellReuseIdentifier: "ResultVCCell")
        self.tableView.rowHeight = 90
        self.tableView.separatorStyle = .none
    }
    
    func bind(_ viewModel : ResultViewModel){
        // VIEWMODEL -> VIEW
        var dataSource = RxTableViewSectionedAnimatedDataSource<ResultVCSection>(animationConfiguration: AnimationConfiguration(insertAnimation: .left, reloadAnimation: .fade, deleteAnimation: .right) ,configureCell: { _, tv, index, data in
            guard let cell = tv.dequeueReusableCell(withIdentifier: "ResultVCCell", for: index) as? ResultVCCell else {return UITableViewCell()}
            
            cell.dataSet(line: data)
            
            return cell
        })
        
        viewModel.cellData
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.bag)
        
        // VIEW -> VIEWMODEL
        self.tableView.rx.itemSelected
            .bind(to: viewModel.cellClick)
            .disposed(by: self.bag)
    }
}
