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
    deinit{
        print("DetailResultScheduleVC DEINIT")
    }
    
    var bag = DisposeBag()
    let detailTopView = DetailResultScheduleTopView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    let detailResultScheduleViewModel : DetailResultScheduleViewModel
    
    var delegate : DetailResultScheduleDelegate?
    
    init(title: String, titleViewHeight: CGFloat, viewModel : DetailResultScheduleViewModel) {
        self.detailResultScheduleViewModel = viewModel
        super.init(title: title, titleViewHeight: titleViewHeight)
        self.topView = self.detailTopView
        self.bind(self.detailResultScheduleViewModel)
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

extension DetailResultScheduleVC{
    private func attribute(){
        self.tableView.register(DetailResultScheduleViewCell.self, forCellReuseIdentifier: "DetailResultScheduleViewCell")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 50
    }
    
    private func bind(_ viewModel : DetailResultScheduleViewModel){
        self.detailTopView.bind(viewModel.detailResultScheduleTopViewModel)
        
        viewModel.resultDefaultData
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
        
        viewModel.nowHourSectionSelect
            .delay(.milliseconds(500))
            .drive(self.rx.sectionSelect)
            .disposed(by: self.bag)
        
        viewModel.scheduleVCExceptionLastStationBtnClick
            .drive(self.rx.scheduleVCExceptionLastStationRemoveAlert)
            .disposed(by: self.bag)
        
        // VIEW
        self.topView.backBtn.rx.tap
            .bind(to: self.rx.pop)
            .disposed(by: self.bag)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        if scrollView.contentOffset.y > 25{
            self.detailTopView.scrollMoreInfoIsHidden(false)
            self.topView.snp.updateConstraints{
                $0.height.equalTo(89.5)
            }
        }else{
            self.detailTopView.scrollMoreInfoIsHidden(true)
            self.topView.snp.updateConstraints{
                $0.height.equalTo(45)
            }
            
        }
        UIView.animate(withDuration: 0.5, delay: 0){
            self.view.layoutIfNeeded()
        }
    }
}

extension Reactive where Base : DetailResultScheduleVC{
    var titleSet : Binder<MainTableViewCellData>{
        return Binder(base){base, data in
            base.viewTitle = "\(data.stationName) 시간표"
            base.detailTopView.exceptionLastStationBtn.setTitle(data.exceptionLastStation == "" ? "제외 행 없음" : "\(data.exceptionLastStation)행 제외", for: .normal)
            base.detailTopView.upDown.text = data.upDown
            
            base.detailTopView.exceptionLastStationBtn.isEnabled = data.exceptionLastStation != ""
        }
    }
    
    var sectionSelect : Binder<Int>{
        return Binder(base){base, hour in
            base.tableView.scrollToRow(at: IndexPath(row: 0, section: hour), at: .top, animated: true)
        }
    }
    
    var scheduleVCExceptionLastStationRemoveAlert : Binder<Void>{
        return Binder(base){ base, _ in
            base.delegate?.exceptionBtnTap()
        }
    }
    
    var pop : Binder<Void>{
        return Binder(base){ base, _ in
            base.delegate?.pop()
        }
    }
}
