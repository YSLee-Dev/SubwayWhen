//
//  ReportTableViewLineCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/21.
//

import UIKit

import RxSwift
import RxCocoa
import RxOptional

class ReportTableViewLineCell : UITableViewCell{
    let mainBG = MainStyleUIView()
    let defaultView = ReportTableViewDefaultLineView()
    
    let mainTitle = UILabel().then{
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.largeSize, weight: .semibold)
    }
    
    let line = UILabel().then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 30
        $0.backgroundColor = .systemGray
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.text = "?"
    }
    
    let stationField = UITextField().then{
        $0.placeholder = "노선을 선택해주세요."
        $0.textAlignment = .right
    }
    
    let picker = UIPickerView()
    
    lazy var tfToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 50)).then{
        $0.backgroundColor = .systemBackground
        $0.sizeToFit()
    }
    
    lazy var doneBarBtn = UIBarButtonItem(title: "완료", style: .done, target: nil, action: nil)
    
    var bag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.attribute()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.bag = DisposeBag()
        self.unseleted()
    }
}

extension ReportTableViewLineCell{
    private func attribute(){
        self.selectionStyle = .none
        
        self.tfToolBar.items = [self.doneBarBtn]
        self.stationField.inputAccessoryView = self.tfToolBar
        self.stationField.inputView = self.picker
    }
    
    private func layout(){
        self.contentView.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.top.equalToSuperview().inset(ViewStyle.padding.mainStyleViewTB)
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.height.equalTo(122)
        }
        
        [self.mainTitle, self.line, self.stationField].forEach{
            self.mainBG.addSubview($0)
        }
        
        self.mainTitle.snp.makeConstraints{
            $0.leading.top.equalToSuperview().inset(15)
            $0.height.equalTo(17)
        }
        
        self.line.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(15)
            $0.top.equalTo(self.mainTitle.snp.bottom).offset(15)
            $0.size.equalTo(60)
        }
        
        self.stationField.snp.makeConstraints{
            $0.trailing.equalToSuperview().inset(15)
            $0.centerY.equalTo(self.line)
        }
        
        self.contentView.addSubview(self.defaultView)
        self.defaultView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.top.equalTo(self.mainBG.snp.bottom).offset(15)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().inset(ViewStyle.padding.mainStyleViewTB)
        }
    }
    
    func bind(_ cellModel : ReportTableViewLineCellModel){
        self.defaultView.bind(cellModel.defaultLineViewModel)
        
        // VIEWMODEL -> VIEW
        cellModel.lineList
            .drive(self.picker.rx.itemTitles){ _, data in
                return data
            }
            .disposed(by: self.bag)
        
        cellModel.lineSet
            .drive(self.stationField.rx.text)
            .disposed(by: self.bag)
        
        cellModel.lineSet
            .drive(self.rx.lineColorSet)
            .disposed(by: self.bag)
        
        cellModel.lineUnSeleted
            .drive(onNext: {[weak self] in
                self?.unseleted()
            })
            .disposed(by: self.bag)
        
        // VIEW -> VIEWMODEL
        self.picker.rx.modelSelected(String.self)
            .map{ ReportBrandData(rawValue: $0.first ?? "")}
            .filterNil()
            .bind(to: cellModel.lineSeleted)
            .disposed(by: self.bag)
        
        
        self.doneBarBtn.rx.tap
            .withLatestFrom(cellModel.lineSeleted){
                !($1 == .not)
            }
            .filter{$0}
            .map{_ in Void()}
            .bind(to: cellModel.lineFix)
            .disposed(by: self.bag)
    }
    
    func unseleted(){
        UIView.animate(withDuration: 0.5, delay: 0){
            self.stationField.isEnabled = false
            self.mainBG.alpha = 0.5
            
            self.defaultView.removeFromSuperview()
            self.mainBG.snp.remakeConstraints{
                $0.top.bottom.equalToSuperview().inset(ViewStyle.padding.mainStyleViewTB)
                $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            }
            self.line.snp.updateConstraints{
                $0.top.equalTo(self.mainTitle.snp.bottom).offset(40)
            }
        }
        
        self.layoutIfNeeded()
    }
    
    func viewDataSet(_ data: ReportTableViewCellData){
        self.mainTitle.text = data.cellTitle
    }
    
    func cutLineName(_ name: String) -> String{
        let zeroCut = name.replacingOccurrences(of: "0", with: "")
        
        if zeroCut.count < 4 {
            return String(zeroCut[zeroCut.startIndex ..< zeroCut.index(zeroCut.startIndex, offsetBy: zeroCut.count)])
        }else{
            return String(zeroCut[zeroCut.startIndex ..< zeroCut.index(zeroCut.startIndex, offsetBy: 4)])
        }
    }
}

extension Reactive where Base : ReportTableViewLineCell{
    var lineColorSet : Binder<String> {
        return Binder(base){base, data in
            base.line.text = data == "노선을 선택해주세요." ? "?" : base.cutLineName(data)
            base.line.backgroundColor = data == "노선을 선택해주세요." ? .gray : UIColor(named: "\(data)")
        }
    }
}
