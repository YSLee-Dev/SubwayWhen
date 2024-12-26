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
    
    let detailViewModel : DetailViewModel
    let disappear = PublishSubject<Void>()
    
    init(title: String, viewModel : DetailViewModel) {
        self.detailViewModel = viewModel
        super.init(title: title, titleViewHeight: 30)
        self.bind()
    }
    
    deinit{
        SubwayWhenDetailWidgetManager.shared.stop()
        print("DetailVC DEINIT")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attribute()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.disappear.onNext(Void())
    }
}

extension DetailVC{
    private func attribute(){
        self.tableView.tableHeaderView = nil
        
        self.tableView.register(DetailTableHeaderView.self, forCellReuseIdentifier: "DetailTableHeaderView")
        self.tableView.register(DetailTableArrivalCell.self, forCellReuseIdentifier: "DetailTableArrivalCell")
        self.tableView.register(DetailTableScheduleCell.self, forCellReuseIdentifier: "DetailTableScheduleCell")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 150
    }
    
    private func bind() {
        let input = DetailViewModel.Input(
            popBtnTap: self.topView.backBtn.rx.tap.asObservable(),
            disappear: self.disappear.asObservable()
        )
        let output = self.detailViewModel.transform(input: input)
        
        if output.isDisposable{
            self.topView.backBtn.setImage(UIImage(systemName: "tag.slash"), for: .normal)
        }
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<DetailTableViewSectionData>(animationConfiguration: AnimationConfiguration(reloadAnimation: .fade)){  dataSource, tv, index, data in
            switch index.section{
            case 0:
                guard let cell = tv.dequeueReusableCell(withIdentifier: "DetailTableHeaderView", for: index) as? DetailTableHeaderView else {return UITableViewCell()}
                cell.cellSet(data)
                cell.bind(output.headerViewModel)
                return cell
            case 1:
                guard let cell = tv.dequeueReusableCell(withIdentifier: "DetailTableArrivalCell", for: index) as? DetailTableArrivalCell else {return UITableViewCell()}
                cell.cellSet(data)
                cell.bind(output.arrivalCellModel)
                cell.cellReset()
                return cell
                
            case 2:
                guard let cell = tv.dequeueReusableCell(withIdentifier: "DetailTableScheduleCell", for: index) as? DetailTableScheduleCell else {return UITableViewCell()}
                cell.cellSet(data, isDisposable: output.isDisposable)
                cell.bind(output.scheduleCellModel)
                return cell
            default:
                return UITableViewCell()
            }
        }
        
        dataSource.titleForHeaderInSection = {dataSource, index in
            dataSource[index].sectionName
        }
        
        output.cellData
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.bag)
    }
}
