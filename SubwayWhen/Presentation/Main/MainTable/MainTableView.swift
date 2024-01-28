//
//  MainTableView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/30.
//

import Foundation

import Then
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

class MainTableView : UITableView{
    private let bag = DisposeBag()
    private let mainTableViewAction = PublishRelay<MainViewAction>()
    
    private lazy var refresh = UIRefreshControl().then{
        $0.backgroundColor = .systemBackground
        $0.attributedTitle = NSAttributedString("🔄 당겨서 새로고침")
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        self.attribute()
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainTableView{
    private func attribute(){
        self.register(MainTableViewCell.self, forCellReuseIdentifier: "MainCell")
        self.register(MainTableViewGroupCell.self, forCellReuseIdentifier: "MainGroup")
        self.register(MainTableViewHeaderCell.self, forCellReuseIdentifier: "MainHeader")
        self.register(MainTableViewDefaultCell.self, forCellReuseIdentifier: "MainDefault")
        self.dataSource = nil
        self.rowHeight = UITableView.automaticDimension
        self.estimatedRowHeight = 185
        self.separatorStyle = .none
        self.refreshControl = self.refresh
    }
    
    private func bind(){
        self.rx.modelSelected(MainTableViewCellData.self)
            .map {.cellTap($0)}
            .bind(to: self.mainTableViewAction)
            .disposed(by: self.bag)
        
        self.refresh.rx.controlEvent(.valueChanged)
            .map {_ in .refreshEvent}
            .bind(to: self.mainTableViewAction)
            .disposed(by: self.bag)
        
    }
    
    @discardableResult
    func setDI(action: PublishRelay<MainViewAction>) -> Self {
        mainTableViewAction
            .bind(to: action)
            .disposed(by: self.bag)
        
        return self
    }
    
    @discardableResult
    func setDI(importantData: Driver<ImportantData>) -> Self {
        importantData
            .drive(self.rx.importantTransform)
            .disposed(by: self.bag)
        
        return self
    }
    
    func setTableView(
        tableViewData: Driver<[MainTableViewSection]>,
        peopleData: Driver<Int>,
        groupData: Driver<SaveStationGroup>
    ) {
        let dataSources = RxTableViewSectionedAnimatedDataSource<MainTableViewSection>(animationConfiguration: AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade), configureCell: {[weak self] dataSource, tv, index, item in
            guard let self = self else {return UITableViewCell()}
            
            switch index.section{
            case 0:
                guard let cell = tv.dequeueReusableCell(withIdentifier: "MainHeader", for: index) as? MainTableViewHeaderCell else {return UITableViewCell()}
                
                cell.bind(peopleData: peopleData)
                
                cell.reportBtn.rx.tap
                    .map {_ in .reportBtnTap}
                    .bind(to: self.mainTableViewAction)
                    .disposed(by: cell.bag)
                
                cell.editBtn.rx.tap
                    .map {_ in .editBtnTap}
                    .bind(to: self.mainTableViewAction)
                    .disposed(by: cell.bag)
                
                return cell
                
            case 1:
                guard let cell = tv.dequeueReusableCell(withIdentifier: "MainGroup", for: index) as? MainTableViewGroupCell else {return UITableViewCell()}
          
                cell.bind(groupData: groupData)
                
                let oneClick = cell.groupOne.rx.tap
                    .map{ _ -> SaveStationGroup in
                        return .one
                    }
                let twoClick = cell.groupTwo.rx.tap
                    .map{_ -> SaveStationGroup in
                        return .two
                    }
                
                Observable
                    .merge(
                        oneClick, twoClick
                    )
                    .map {.groupTap($0)}
                    .bind(to: self.mainTableViewAction)
                    .disposed(by: cell.bag)
                
                return cell
                
            default:
                if item.id == "NoData"{
                    guard let cell = tv.dequeueReusableCell(withIdentifier: "MainDefault", for: index) as? MainTableViewDefaultCell else {return UITableViewCell()}
                    
                    cell.animationPlay()
                    return cell
                }else{
                    guard let cell = tv.dequeueReusableCell(withIdentifier: "MainCell", for: index) as? MainTableViewCell else {return UITableViewCell()}
               
                    cell.cellSet(data: item)
                    
                    cell.changeBtn.rx.tap
                        .map{ _ in .scheduleTap(index)}
                        .bind(to: self.mainTableViewAction)
                        .disposed(by: cell.bag)

                    return cell
                }
            }
        })
        
        dataSources.titleForHeaderInSection = {dataSource, index in
            dataSource[index].sectionName
        }
        
        tableViewData
            .drive(self.rx.items(dataSource: dataSources))
            .disposed(by: self.bag)
        
        tableViewData
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.refresh.endRefreshing()
            })
            .disposed(by: self.bag)
    }
}

extension Reactive where Base: MainTableView {
    var importantTransform: Binder<ImportantData> {
        return Binder(base) { base, data in
            guard let cell = base.cellForRow(at: IndexPath(row: 0, section: 0)) as? MainTableViewHeaderCell else {return}
            
            UIView.animate(withDuration: 0.5, animations: {
                cell.isImportant(data: data)
                base.reloadData()
            })
        }
    }
}
