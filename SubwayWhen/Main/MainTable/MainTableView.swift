//
//  MainTableView.swift
//  SubwayWhen
//
//  Created by ์ด์ค์ on 2022/11/30.
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
        $0.attributedTitle = NSAttributedString("๐ ๋น๊ฒจ์ ์๋ก๊ณ ์นจ")
    }
    
    let footerView = MainTableViewFooterView(frame: CGRect(x: 0, y: 0, width: 300, height: 115))
    
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
        self.register(MainTableViewFooterView.self, forHeaderFooterViewReuseIdentifier: "MainFooter")
        self.dataSource = nil
        self.rowHeight = 185
        self.separatorStyle = .none
        self.refreshControl = self.refresh
        self.tableFooterView = self.footerView
    }
    
    func bind(_ viewModel : MainTableViewModel){
        self.footerView.bind(viewModel.mainTableViewFooterViewModel)
        
        // VIEWMODEl -> VIEW
        let dataSources = RxTableViewSectionedAnimatedDataSource<MainTableViewSection>(animationConfiguration: AnimationConfiguration(insertAnimation: .left, reloadAnimation: .fade, deleteAnimation: .right), configureCell: {dataSource, tv, index, item in
            guard let cell = tv.dequeueReusableCell(withIdentifier: "MainCell", for: index) as? MainTableViewCell else {return UITableViewCell()}
       
            cell.cellSet(data: item, cellModel: viewModel.mainTableViewCellModel, indexPath: index)
            return cell
        })
        
        
        viewModel.cellData
            .drive(self.rx.items(dataSource: dataSources))
            .disposed(by: self.bag)
        

        // VIEW -> VIEWMODEL
        self.rx.modelSelected(MainTableViewCellData.self)
            .bind(to: viewModel.cellClick)
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
