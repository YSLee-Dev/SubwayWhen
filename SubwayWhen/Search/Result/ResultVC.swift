//
//  ResultVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import UIKit

import RxSwift
import RxCocoa

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
        viewModel.cellData
            .drive(self.tableView.rx.items){tv, row, data in
                guard let cell = tv.dequeueReusableCell(withIdentifier: "ResultVCCell", for: IndexPath(row: row, section: 0)) as? ResultVCCell else {return UITableViewCell()}
                
                cell.dataSet(line: data)
                
                return cell
            }
            .disposed(by: self.bag)
        
        // VIEW -> VIEWMODEL
        self.tableView.rx.modelSelected(searchStationInfo.self)
            .bind(to: viewModel.cellClick)
            .disposed(by: self.bag)
    }
}
