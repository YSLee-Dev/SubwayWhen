//
//  TableVCCustom.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/02.
//

import UIKit

import SnapKit
import Then

class TableVCCustom : UIViewController{
    lazy var topView = TopView()
    lazy var titleView = TitleView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
    
    lazy var tableView = UITableView().then{
        $0.dataSource = nil
        $0.delegate = self
        $0.sectionHeaderHeight = 30
        $0.backgroundColor = .systemBackground
        $0.separatorStyle = .none
    }
    
    var viewTitle : String
   
    init(title : String){
        self.viewTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.attribute(title: self.viewTitle)
        self.layout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension TableVCCustom{
    private func attribute(title : String){
        self.view.backgroundColor = .systemBackground
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        self.tableView.tableHeaderView = self.titleView
        
        
        self.titleView.mainTitleLabel.text = self.viewTitle
        self.topView.subTitleLabel.text = self.viewTitle
        self.topView.backBtn.addTarget(self, action: #selector(backBtnClick(_ :)), for: .touchUpInside)
    }
    
    private func layout(){
        self.view.addSubview(self.topView)
        self.topView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(45)
        }
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints{
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(self.topView.snp.bottom)
        }
    }
    
    @objc
    private func backBtnClick(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
}

extension TableVCCustom : UITableViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 25{
            self.topView.isMainTitleHidden(true)
        }else{
            self.topView.isMainTitleHidden(false)
        }
        
    }
}
