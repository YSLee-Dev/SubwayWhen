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
import RxDataSources

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
        self.setEditing(true, animated: true)
        self.tableView.register(EditViewCell.self, forCellReuseIdentifier: "EditViewCell")
        self.view.backgroundColor = UIColor(named: "MainColor")
        self.refreshControl = UIRefreshControl()
    }
    
    func bind(_ viewmModel  : EditViewModel){
        // Bind 함수가 메모리에 먼저 올라감
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .done, target: self, action: nil)
        
        // VIEWMODEL -> VIEW
        let dataSource = RxTableViewSectionedAnimatedDataSource<EditViewCellSection>(animationConfiguration: .init(insertAnimation: .left, reloadAnimation: .fade, deleteAnimation: .right), configureCell: {_, tv, indexpath, data in
            guard let cell = tv.dequeueReusableCell(withIdentifier: "EditViewCell", for: indexpath) as? EditViewCell else {return UITableViewCell()}
            cell.cellSet(data: data)
            return cell
        })
        
        dataSource.canEditRowAtIndexPath = {_, _ in
            true
        }
        
        dataSource.canMoveRowAtIndexPath = {_, _ in
            true
        }
        
        dataSource.titleForHeaderInSection = {dataSource, index in
            dataSource[index].sectionName
        }
        
        viewmModel.cellData
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.bag)
        
        // VIEW -> VIEWMODEL
        self.tableView.rx.modelDeleted(EditViewCellData.self)
            .map{
                $0.id
            }
            .bind(to: viewmModel.deleteCell)
            .disposed(by: self.bag)
        
        self.tableView.rx.itemMoved
            .bind(to: viewmModel.moveCell)
            .disposed(by: self.bag)
        
        self.refreshControl?.rx.controlEvent(.valueChanged)
            .map{[weak self] _ in
                self?.refreshControl?.endRefreshing()
                return Void()
            }
            .startWith(Void())
            .bind(to: viewmModel.refreshOn)
            .disposed(by: self.bag)
        
        // VIEW
        self.navigationItem.rightBarButtonItem?.rx.tap
            .bind(to: self.rx.dissmissEdit)
            .disposed(by: self.bag)
    }
}

extension Reactive where Base : EditVC{
    var dissmissEdit : Binder<Void>{
        return Binder(base){ base, _ in
            base.dismiss(animated: true)
        }
    }
}
