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
    let editViewModel = EditViewModel()
    
    let backGestureView = UIView().then{
        $0.backgroundColor = .clear
    }
    
    let noListLabel = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.textColor = .gray
        $0.text = "현재 저장되어 있는 지하철역이 없어요."
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attribute()
        self.layout()
        self.bind(self.editViewModel)
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
        
        self.view.addSubview(self.noListLabel)
        self.noListLabel.snp.makeConstraints{
            $0.center.equalToSuperview()
        }
    }
    
    private func bind(_ viewModel  : EditViewModel){
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
        
        viewModel.cellData
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.bag)
        
        viewModel.cellData
            .filter{!($0.isEmpty)}
            .map{
                if ($0[0].items.isEmpty), ($0[1].items.isEmpty){
                    return false
                }else{
                    return true
                }
            }
            .drive(self.noListLabel.rx.isHidden)
            .disposed(by: self.bag)
        
        // VIEW -> VIEWMODEL
        self.tableView.rx.modelDeleted(EditViewCellData.self)
            .map{
                $0.id
            }
            .bind(to: viewModel.deleteCell)
            .disposed(by: self.bag)
        
        self.tableView.rx.itemMoved
            .bind(to: viewModel.moveCell)
            .disposed(by: self.bag)
        
        self.tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .map{[weak self] _ in
                self?.tableView.refreshControl?.endRefreshing()
                return Void()
            }
            .startWith(Void())
            .bind(to: viewModel.refreshOn)
            .disposed(by: self.bag)
    }
    
    @objc
    private func backGesture(_ sender:Any){
        self.dismiss(animated: true)
    }
}
