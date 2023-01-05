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
import RxDataSources

class DetailVC : TableVCCustom{
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attribute()
    }
}

extension DetailVC{
    private func attribute(){
        self.tableView.tableHeaderView = nil
        
        self.tableView.register(DetailTableHeaderView.self, forCellReuseIdentifier: "DetailTableHeaderView")
        self.tableView.register(DetailTableArrivalCell.self, forCellReuseIdentifier: "DetailTableArrivalCell")
        self.tableView.rowHeight = 100
    }
    
    func bind(_ viewModel : DetailViewModel){
        let dataSource = RxTableViewSectionedAnimatedDataSource<DetailTableViewSectionData>(animationConfiguration: AnimationConfiguration(insertAnimation: .fade)){ dataSource, tv, index, data in
            
            switch index.section{
            case 0:
                guard let cell = tv.dequeueReusableCell(withIdentifier: "DetailTableHeaderView", for: index) as? DetailTableHeaderView else {return UITableViewCell()}
                cell.cellSet(data)
                
                return cell
            case 1:
                guard let cell = tv.dequeueReusableCell(withIdentifier: "DetailTableArrivalCell", for: index) as? DetailTableArrivalCell else {return UITableViewCell()}
                cell.bind(viewModel.arrivalCellModel)
                return cell
            default:
                return UITableViewCell()
            }
        }
        
        dataSource.titleForHeaderInSection = {dataSource, index in
            dataSource[index].sectionName
        }
        
        viewModel.cellData
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.bag)
    }
}
