//
//  SettingNotiSelectModalVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/21.
//

import UIKit

import SnapKit

import RxSwift
import RxCocoa
import RxDataSources

class SettingNotiSelectModalVC: TableVCCustom {
    let bag = DisposeBag()
    let viewModel: SettingNotiSelectModalViewModel
    
    lazy var noListLabel = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.textColor = .gray
        $0.text = "현재 저장되어 있는 지하철역이 없어요."
        $0.textAlignment = .center
    }
    
    private let didDisappearAction =  PublishSubject<Void>()
    
    init(
        title: String,
        titleViewHeight: CGFloat,
        viewModel: SettingNotiSelectModalViewModel
    ) {
        self.viewModel = viewModel
        super.init(title: title, titleViewHeight: titleViewHeight)
    }
    
    deinit {
        print("SettingNotiSelectModalVC DEINIT")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attribute()
        self.layout()
        self.bind()
        self.animation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.didDisappearAction.onNext(Void())
    }
}

private extension SettingNotiSelectModalVC {
    func attribute() {
        self.view.backgroundColor = UIColor(named: "LigthGrayColor") ?? .lightGray
        self.topView.layer.cornerRadius = ViewStyle.Layer.radius
        self.tableView.register(SettingNotiSelectModalCell.self, forCellReuseIdentifier: "SettingNotiSelectModalCell")
        self.tableView.rowHeight = 90
        
        [self.topView, self.tableView]
            .forEach{
                $0.transform = CGAffineTransform(translationX: 0, y: 250)
            }
        
    }
    
    func layout() {
        self.topView.snp.remakeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(40)
            $0.height.equalTo(60)
        }
        
        self.tableView.snp.remakeConstraints{
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(self.topView.snp.bottom).offset(-15)
        }
    }
    
    func animation() {
        UIView.animate(withDuration: 0.25, animations: {
            [self.topView, self.tableView]
                .forEach{
                    $0.transform = .identity
                }
        })
    }
    
    func bind() {
        let input = SettingNotiSelectModalViewModel.Input(
            didDisappearAction: self.didDisappearAction,
            popAction: self.topView.backBtn.rx.tap.asObservable(),
            stationTap: self.tableView.rx.modelSelected(SettingNotiSelectModalCellData.self).asObservable()
        )
        
        let output = self.viewModel.transform(input: input)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<SettingNotiSelectModalSectionData>(
            animationConfiguration: .init(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade),
            configureCell: { _, tv, index, data in
                guard let cell = tv.dequeueReusableCell(withIdentifier: "SettingNotiSelectModalCell", for: index) as? SettingNotiSelectModalCell else {return UITableViewCell()}
                cell.cellSet(data: data)
                return cell
            })
        
        output.stationList
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.bag)
        
        output.noLabelListShow
            .drive(self.rx.labelShow)
            .disposed(by: self.bag)
    }
}

extension Reactive where Base: SettingNotiSelectModalVC {
    var labelShow: Binder<Void> {
        return Binder(base) { base, _ in
            base.view.addSubview(base.noListLabel)
            base.noListLabel.snp.makeConstraints{
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview().offset(40)
            }
        }
    }
}
