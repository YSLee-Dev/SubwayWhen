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

class EditVC: TableVCCustom{
    private let bag = DisposeBag()
    private let editAction = PublishRelay<EditVCAction>()
    private let editViewModel: EditViewModel
    
    private let noListLabel = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.textColor = .gray
        $0.text = "현재 저장되어 있는 지하철역이 없어요."
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    init(
        viewModel: EditViewModel
    ){
        self.editViewModel = viewModel
        super.init(title: "편집", titleViewHeight: 30)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        print("DEINIT EDITVC")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attribute()
        self.layout()
        self.bind()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.editAction.accept(.willDisappear)
    }
}

private extension EditVC{
    func attribute(){
        self.tableView.rowHeight = 90
        self.tableView.setEditing(true, animated: true)
        self.tableView.register(EditViewCell.self, forCellReuseIdentifier: "EditViewCell")
    }
    
    func layout(){
        self.view.addSubview(self.noListLabel)
        self.noListLabel.snp.makeConstraints{
            $0.center.equalToSuperview()
        }
    }
    
    func bind(){
        self.tableView.rx.modelDeleted(SaveStation.self)
            .map {
                .deleteCell($0)
            }
            .bind(to: self.editAction)
            .disposed(by: self.bag)
        
        self.tableView.rx.itemMoved
            .map {
                .moveCell($0)
            }
            .bind(to: self.editAction)
            .disposed(by: self.bag)
        
        let input = EditViewModel.Input(
            actionList: self.editAction
                .asObservable()
        )
        let output = self.editViewModel.transform(input: input)
        
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
        
        output.cellData
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.bag)
        
        output.cellData
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
        
        // VIEW
        self.topView.backBtn.rx.tap
            .map {_ in .backBtnTap}
            .bind(to: self.editAction)
            .disposed(by: self.bag)
    }
}
