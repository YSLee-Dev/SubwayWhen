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

class EditVC : TableVCCustom{
    let bag = DisposeBag()
    
    let backGestureView = UIView().then{
        $0.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attribute()
        self.layout()
        self.bind(EditViewModel())
    }
}

extension EditVC{
    private func attribute(){
        self.tableView.rowHeight = 90
        self.tableView.setEditing(true, animated: true)
        self.tableView.register(EditViewCell.self, forCellReuseIdentifier: "EditViewCell")
        self.tableView.refreshControl = UIRefreshControl()
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(backGesture))
        gesture.direction = .right
        self.backGestureView.addGestureRecognizer(gesture)
    }
    
    private func layout(){
        self.view.addSubview(self.backGestureView)
        self.backGestureView.snp.makeConstraints{
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(15)
        }
    }
    
    private func bind(_ viewmModel  : EditViewModel){
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
        
        self.tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .map{[weak self] _ in
                self?.tableView.refreshControl?.endRefreshing()
                return Void()
            }
            .startWith(Void())
            .bind(to: viewmModel.refreshOn)
            .disposed(by: self.bag)
    }
    
    @objc
    private func backGesture(_ sender:Any){
        self.dismiss(animated: true)
    }
}
