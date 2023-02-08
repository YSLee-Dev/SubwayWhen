//
//  MainVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

class MainVC : UIViewController{
    let bag = DisposeBag()
    
    let mainTableView = MainTableView()
    let mainViewModel = MainViewModel()
    
    lazy var mainTitleLabel = UILabel().then{
        $0.textColor = .label
        $0.font = .boldSystemFont(ofSize: 25)
        $0.textAlignment = .left
        $0.text = "홈"
    }
    
    
    override func viewDidLoad() {
        self.attibute()
        self.layout()
        self.bind(self.mainViewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // view 다시 들어올 때 리프레시
        self.mainViewModel.reloadData
            .accept(Void())
    }
}
 
extension MainVC{
    private func attibute(){
        self.view.backgroundColor = .systemBackground
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
    }
    
    private func layout(){
        self.view.addSubview(self.mainTitleLabel)
        self.mainTitleLabel.snp.makeConstraints{
            $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(45)
            $0.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }
        
        self.view.addSubview(self.mainTableView)
        self.mainTableView.snp.makeConstraints{
            $0.top.equalTo(self.mainTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    private func bind(_ viewModel : MainViewModel){
        self.mainTableView.bind(viewModel.mainTableViewModel)
        
        // VIEWMODEL -> VIEW
        viewModel.stationPlusBtnClick
            .drive(self.rx.tapChange)
            .disposed(by: self.bag)
        
        viewModel.clickCellData
            .drive(self.rx.detailVCPresent)
            .disposed(by: self.bag)
        
        viewModel.editBtnClick
            .drive(self.rx.editVCPresent)
            .disposed(by: self.bag)
        
    }
}

extension Reactive where Base : MainVC {
    var tapChange : Binder<Void>{
        return Binder(base){base, _ in
            base.tabBarController?.selectedIndex = 1
        }
    }
    
    var editVCPresent : Binder<Void>{
        return Binder(base){base, _ in
            let editVC = EditVC(title: "편집")
            editVC.modalPresentationStyle = .fullScreen
            base.present(editVC, animated: true)
        }
    }
    
    var detailVCPresent : Binder<MainTableViewCellData>{
        return Binder(base){base, data in
            let viewModel = DetailViewModel()
            
            let detail = DetailVC(title: "\(data.useLine) \(data.stationName)", viewModel: viewModel)
            detail.hidesBottomBarWhenPushed = true
            /*
            #if DEBUG
            viewModel.detailViewData.accept(.init(upDown: data.upDown, arrivalTime: "도착시간", previousStation: "설명", subPrevious: "서브설명", code: "0", subWayId: "123", stationName: "서울역", lastStation: "lastStation", lineNumber: data.lineNumber, isFast: "", useLine: data.useLine, group: data.group, id: data.id, stationCode: data.stationCode, exceptionLastStation: "", type: .real, backStationId: "1001000134", nextStationId: "1001000132", totalStationId: data.totalStationId))
            #else
             */
            var excption = data
            
            if excption.useLine == "공항철도"{
                let next = excption.nextStationId
                excption.nextStationId = excption.backStationId
                excption.backStationId = next
            }
            
            viewModel.detailViewData.accept(excption)
            
            //#endif
            
            
            base.navigationController?.pushViewController(detail, animated: true)
        }
    }
}
