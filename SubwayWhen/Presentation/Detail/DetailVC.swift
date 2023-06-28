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
    var disposable : Bool = false
    var liveActivity : Bool = false
    
    let detailViewModel : DetailViewModelProtocol
    
    var delegate : DetailVCDelegate?
    
    init(title: String, viewModel : DetailViewModelProtocol) {
        self.detailViewModel = viewModel
        super.init(title: title, titleViewHeight: 30)
        self.bind(self.detailViewModel)
        
        // 임시 역 backBtn 분기
        if title.contains("(저장안됨)"){
            self.disposable = true
        }
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
        self.delegate?.disappear()
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
        
        if self.disposable{
            self.topView.backBtn.setImage(UIImage(systemName: "tag.slash"), for: .normal)
        }
    }
    
    private func bind(_ viewModel : DetailViewModelProtocol){
        let dataSource = RxTableViewSectionedAnimatedDataSource<DetailTableViewSectionData>(animationConfiguration: AnimationConfiguration(reloadAnimation: .fade)){ [weak self] dataSource, tv, index, data in
            switch index.section{
            case 0:
                guard let cell = tv.dequeueReusableCell(withIdentifier: "DetailTableHeaderView", for: index) as? DetailTableHeaderView else {return UITableViewCell()}
                cell.cellSet(data)
                cell.bind(viewModel.headerViewModel)
                return cell
            case 1:
                guard let cell = tv.dequeueReusableCell(withIdentifier: "DetailTableArrivalCell", for: index) as? DetailTableArrivalCell else {return UITableViewCell()}
                cell.cellSet(data)
                cell.bind(viewModel.arrivalCellModel)
                cell.cellReset()
                return cell
                
            case 2:
                guard let cell = tv.dequeueReusableCell(withIdentifier: "DetailTableScheduleCell", for: index) as? DetailTableScheduleCell else {return UITableViewCell()}
                cell.cellSet(data, isDisposable: self?.disposable ?? false)
                cell.bind(viewModel.scheduleCellModel)
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
        
        viewModel.moreBtnClickData
            .drive(self.rx.detailResultPresent)
            .disposed(by: self.bag)
        
        viewModel.exceptionLastStationRemoveBtnClick
            .drive(self.rx.exceptionLastStationRemoveAlert)
            .disposed(by: self.bag)
        
        viewModel.liveActivityArrivalData
            .drive(self.rx.liveActivity)
            .disposed(by: self.bag)
        
        // VIEW
        self.topView.backBtn.rx.tap
            .bind(to: self.rx.pop)
            .disposed(by: self.bag)
    }
}

extension Reactive where Base : DetailVC{
    var detailResultPresent : Binder<schduleResultData>{
        return Binder(base){ base, data in
            base.delegate?.scheduleTap(schduleResultData: data)
        }
    }
    
    var exceptionLastStationRemoveAlert : Binder<DetailLoadData>{
        return Binder(base){ base, data in
            let alert = UIAlertController(title: "\(data.exceptionLastStation)행을 포함해서 재로딩 하시겠어요?\n재로딩은 일회성으로, 저장하지 않아요.", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "재로딩", style: .default){ _ in
                Observable.just(Void())
                    .bind(to: base.detailViewModel.exceptionLastStationRemoveReload)
                    .disposed(by: base.bag)
            })
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            
            base.present(alert, animated: true)
        }
    }
    
    var pop : Binder<Void>{
        return Binder(base){base , _ in
            base.delegate?.pop()
        }
    }
    
    var liveActivity : Binder<DetailActivityLoadData>{
        return Binder(base){base , data in
            guard !base.disposable else {return}
            
            if !base.liveActivity{
                SubwayWhenDetailWidgetManager.shared.start(stationLine: data.saveLine, saveStation: data.saveStation, scheduleList: data.scheduleList, lastUpdate: data.lastUpdate)
                base.liveActivity = !base.liveActivity
            }else{
                SubwayWhenDetailWidgetManager.shared.update(scheduleList: data.scheduleList, lastUpdate: data.lastUpdate)
            }
        }
    }
}
