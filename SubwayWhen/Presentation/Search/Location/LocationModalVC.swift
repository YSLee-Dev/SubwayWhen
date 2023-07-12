//
//  LocationModalVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/05.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

import Then
import SnapKit
import Lottie

class LocationModalVC: ModalVCCustom {
    var animationIcon : LottieAnimationView?
    
    let refreshIcon = UIActivityIndicatorView().then{
        $0.color = UIColor(named: "AppIconColor")
    }
    
    let viewModel: LocationModalViewModel
    
    private let modalCompletion =  PublishSubject<Void>()
    private let didDisappear = PublishSubject<Void>()
    private let bag = DisposeBag()
    
    init(modalHeight: CGFloat, btnTitle: String, mainTitle: String, subTitle: String, viewModel: LocationModalViewModel) {
        self.viewModel = viewModel
        super.init(modalHeight: modalHeight, btnTitle: btnTitle, mainTitle: mainTitle, subTitle: subTitle)
        self.bind()
    }
    
    lazy var tableView = UITableView().then {
        $0.rowHeight = 90
        $0.backgroundColor = .systemBackground
        $0.register(LocationModalCell.self, forCellReuseIdentifier: "LocationModalCell")
        $0.dataSource = nil
        $0.delegate = nil
        $0.separatorStyle = .none
    }
    
    deinit {
        print("LocationModalVC DEINIT")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.didDisappear.onNext(Void())
    }
    
    override func modalDismiss() {
        UIView.animate(withDuration: 0.25, delay: 0, animations: {
            self.mainBG.transform = CGAffineTransform(translationX: 0, y: self.modalHeight)
            self.mainBGContainer.transform = CGAffineTransform(translationX: 0, y: self.modalHeight)
            self.grayBG.backgroundColor = .clear
        }, completion: { _ in
            self.modalCompletion.onNext(Void())
        })
    }
}

private extension LocationModalVC {
    func attribute() {
        self.refreshIcon.startAnimating()
    }
    
    func layout() {
        guard let okBtn = self.okBtn else {return}
        
        self.mainBG.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(self.subTitle.snp.bottom).offset(10)
            $0.bottom.equalTo(okBtn.snp.top).offset(-10)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.tableView.addSubview(self.refreshIcon)
        self.refreshIcon.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func bind() {
        guard let okBtn = self.okBtn else {return}
        
        let input = LocationModalViewModel.Input(
            modalCompletion: self.modalCompletion.asObservable(),
            okBtnTap: okBtn.rx.tap.asObservable(),
            didDisappear: self.didDisappear.asObservable(),
            stationTap: self.tableView.rx.modelSelected(LocationModalCellData.self).asObservable()
        )
        
        let output = self.viewModel.transform(input: input)
        
        output.modalDismissAnimation
            .drive(self.rx.modalDismiss)
            .disposed(by: self.bag)
        
        output.locationAuthStatus
            .drive(self.rx.authSwitch)
            .disposed(by: self.bag)
        
        
        let dataSources = RxTableViewSectionedAnimatedDataSource<LocationModalSectionData>(
            animationConfiguration: .init(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade),
            configureCell: { _, tv, index, data in
                guard let cell = tv.dequeueReusableCell(withIdentifier: "LocationModalCell", for: index) as? LocationModalCell else {return UITableViewCell()}
                cell.cellSet(data: data)
                return cell
            })
        
        output.vcinityStations
            .drive(self.tableView.rx.items(dataSource: dataSources))
            .disposed(by: self.bag)
        
        output.loadingStop
            .drive(self.rx.refreshIconStop)
            .disposed(by: self.bag)
        
    }
    
    func iconLayout(){
        self.animationIcon = LottieAnimationView(name: "Report")
        guard let animationIcon = self.animationIcon else {return}
        
        self.mainBG.addSubview(animationIcon)
        animationIcon.snp.makeConstraints{
            $0.size.equalTo(100)
            $0.top.equalTo(self.subTitle.snp.bottom).offset(100)
            $0.centerX.equalToSuperview()
        }
    }
    
    func animationStart() {
        guard let animationIcon = self.animationIcon else {return}
        
        animationIcon.animationSpeed = 2
        animationIcon.play()
    }
}

extension Reactive where Base: LocationModalVC {
    var modalDismiss: Binder<Void> {
        return Binder(base) { base, _ in
            base.modalDismiss()
        }
    }
    
    var authSwitch: Binder<Bool>{
        return Binder(base){ base, bool in
            if bool{
                base.layout()
                base.refreshIcon.startAnimating()
            }else{
                base.iconLayout()
                base.animationStart()
                base.subTitle.text = "위치 권한이 설정되어 있지 않아요."
                base.okBtn?.titleLabel?.text = "닫기"
            }
        }
    }
    
    var refreshIconStop: Binder<Void> {
        return Binder(base) { base, _ in
            base.refreshIcon.stopAnimating()
        }
    }
}
