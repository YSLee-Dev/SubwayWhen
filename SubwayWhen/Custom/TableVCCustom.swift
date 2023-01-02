//
//  TableVCCustom.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/02.
//

import UIKit

class TableVCCustom : UITableViewController{
    lazy var titleView = TitleView()
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        self.attribute()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TableVCCustom{
    private func attribute(){
        self.view.backgroundColor = .systemBackground
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        self.titleView.backBtn.addTarget(self, action: #selector(backBtnClick(_ :)), for: .touchUpInside)
    }
    
    private func layout(){
        self.view.addSubview(self.titleView)
        self.titleView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(50)
        }
    }
    
    @objc
    private func backBtnClick(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
    }
}
