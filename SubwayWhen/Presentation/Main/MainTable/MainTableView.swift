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
    let bag = DisposeBag()
    
    lazy var refresh = UIRefreshControl().then{
        $0.backgroundColor = .systemBackground
        $0.attributedTitle = NSAttributedString("🔄 당겨서 새로고침")
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.attribute()
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
    
    func bind(_ viewModel : MainTableViewModel){
        // VIEWMODEl -> VIEW
        let dataSources = RxTableViewSectionedAnimatedDataSource<MainTableViewSection>(animationConfiguration: AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade), configureCell: {dataSource, tv, index, item in
            switch index.section{
            case 0:
                guard let cell = tv.dequeueReusableCell(withIdentifier: "MainHeader", for: index) as? MainTableViewHeaderCell else {return UITableViewCell()}
          
                cell.bind(viewModel.mainTableViewHeaderViewModel)
                return cell
                
            case 1:
                guard let cell = tv.dequeueReusableCell(withIdentifier: "MainGroup", for: index) as? MainTableViewGroupCell else {return UITableViewCell()}
          
                cell.bind(viewModel.mainTableViewGroupModel)
                return cell
            default:
                if item.id == "NoData"{
                    guard let cell = tv.dequeueReusableCell(withIdentifier: "MainDefault", for: index) as? MainTableViewDefaultCell else {return UITableViewCell()}
                    
                    cell.animationPlay()
                    return cell
                }else{
                    guard let cell = tv.dequeueReusableCell(withIdentifier: "MainCell", for: index) as? MainTableViewCell else {return UITableViewCell()}
               
                    cell.cellSet(data: item, cellModel: viewModel.mainTableViewCellModel, indexPath: index)
                    return cell
                }
            }
           
        })
        
        dataSources.titleForHeaderInSection = {dataSource, index in
            dataSource[index].sectionName
        }
        
        viewModel.cellData
            .drive(self.rx.items(dataSource: dataSources))
            .disposed(by: self.bag)
        

        // VIEW -> VIEWMODEL
        self.rx.modelSelected(MainTableViewCellData.self)
            .filter{
                !($0.id == "header" || $0.id == "group" || $0.id == "NoData")
            }
            .bind(to: viewModel.cellClick)
            .disposed(by: self.bag)
        
        self.rx.modelSelected(MainTableViewCellData.self)
            .filter{
                $0.id == "NoData"
            }
            .map{_ in Void()}
            .bind(to: viewModel.plusBtnClick)
            .disposed(by: self.bag)
        
        
        self.refreshControl?.rx.controlEvent(.valueChanged)
            .map{[weak self] _ in
                self?.refreshControl?.endRefreshing()
                return Void()
            }
            .asSignal(onErrorJustReturn: ())
            .emit(to: viewModel.refreshOn)
            .disposed(by: self.bag)
        
    }
}
