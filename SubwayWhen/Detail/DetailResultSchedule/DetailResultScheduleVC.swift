//
//  DetailResultScheduleVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/25.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class DetailResultScheduleVC : TableVCCustom{
    let bag = DisposeBag()
    let headerView = DetailResultScheduleHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 45))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attribute()
    }
}

extension DetailResultScheduleVC{
    private func attribute(){
        //self.tableView.tableHeaderView = self.headerView
        self.tableView.register(DetailResultScheduleViewCell.self, forCellReuseIdentifier: "DetailResultScheduleViewCell")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 50
    }
    
    func bind(_ viewModel : DetailResultScheduleViewModel){
        viewModel.resultDefaultData
            .drive(self.rx.headerViewDataSet)
            .disposed(by: self.bag)
        
        viewModel.resultDefaultData
            .map{
                "\($0.stationName)(\($0.upDown)) 시간표"
            }
            .drive(self.rx.titleSet)
            .disposed(by: self.bag)
        
        
        let dataSources = RxTableViewSectionedAnimatedDataSource<DetailResultScheduleViewSectionData>(animationConfiguration: AnimationConfiguration(reloadAnimation: .automatic)){ dataSource, tv, index, data in
            guard let cell = tv.dequeueReusableCell(withIdentifier: "DetailResultScheduleViewCell", for: index) as? DetailResultScheduleViewCell else {return UITableViewCell()}
            cell.cellSet(data)
            return cell
        }
        
        dataSources.titleForHeaderInSection = {data,index in
            return dataSources[index].sectionName
        }
        
        viewModel.groupScheduleData
            .drive(self.tableView.rx.items(dataSource: dataSources))
            .disposed(by: self.bag)
    }
}

extension Reactive where Base : DetailResultScheduleVC{
    var headerViewDataSet : Binder<MainTableViewCellData>{
        return Binder(base){ base, data in
            base.headerView.viewSet(station: data.stationName, updown: data.upDown)
        }
    }
    
    var titleSet : Binder<String>{
        return Binder(base){base, title in
            base.viewTitle = title
        }
    }
}
