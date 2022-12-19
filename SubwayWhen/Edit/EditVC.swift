//
//  EditVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/19.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

class EditVC : UITableViewController{
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attribute()
    }
}

extension EditVC{
    private func attribute(){
        self.navigationItem.title = "편집"
        self.tableView.rowHeight = 90
        self.tableView.separatorStyle = .none
        self.tableView.dataSource = nil
        self.tableView.delegate = nil
        self.tableView.register(EditViewCell.self, forCellReuseIdentifier: "EditViewCell")
        self.view.backgroundColor = UIColor(named: "MainColor")
    }
    
    func bind(_ viewmModel  : EditViewModel){
        viewmModel.cellData
            .drive(self.tableView.rx.items){tv, row, data in
                guard let cell = tv.dequeueReusableCell(withIdentifier: "EditViewCell", for: IndexPath(row: row, section: 0)) as? EditViewCell else {return UITableViewCell()}
                
                cell.cellSet(data: data)
                
                return cell
            }
            .disposed(by: self.bag)
    }
}
