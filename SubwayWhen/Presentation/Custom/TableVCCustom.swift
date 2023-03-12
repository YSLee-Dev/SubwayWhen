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
    let titleView : TitleView
    
    lazy var tableView = UITableView().then{
        $0.dataSource = nil
        $0.delegate = self
        $0.sectionHeaderHeight = 30
        $0.backgroundColor = .systemBackground
        $0.separatorStyle = .none
    }
    
    var viewTitle : String
   
    init(title : String, titleViewHeight : CGFloat){
        self.viewTitle = title
        self.titleView = TitleView(frame: CGRect(x: 0, y: 0, width: 100 , height: titleViewHeight))
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(title : String){
        self.init(title: title, titleViewHeight: 30)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.attribute(title: self.viewTitle)
        self.layout()
    }
}

extension TableVCCustom{
    private func attribute(title : String){
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        self.view.backgroundColor = .systemBackground
        
        self.tableView.tableHeaderView = self.titleView
        
        self.titleView.mainTitleLabel.text = self.viewTitle
        
        self.topView.subTitleLabel.text = self.viewTitle
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
    
}

extension TableVCCustom : UITableViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 25{
            self.topView.isMainTitleHidden(false)
        }else{
            self.topView.isMainTitleHidden(true)
        }
        
    }
}
