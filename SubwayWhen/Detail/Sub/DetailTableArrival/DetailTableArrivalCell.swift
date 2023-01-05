//
//  DetailTableArrivalCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/05.
//

import UIKit

import RxSwift
import RxCocoa

class DetailTableArrivalCell : UITableViewCell{
    var bag = DisposeBag()
    
    override func prepareForReuse() {
        self.bag = DisposeBag()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.attribute()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DetailTableArrivalCell {
    private func attribute(){
        
    }
    
    private func layout(){
        
    }
    
    func bind(_ viewModel : DetailTableArrivalCellModel){
    }
}
