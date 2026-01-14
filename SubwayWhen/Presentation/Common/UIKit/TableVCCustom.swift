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
    
    let additionalHeaderView: UIView?
    
    let titleViewHeight: CGFloat
    var viewTitle : String
   
    init(title : String, titleViewHeight : CGFloat, additionalHeaderView: UIView? = nil){
        self.viewTitle = title
        self.titleViewHeight = titleViewHeight
        self.additionalHeaderView = additionalHeaderView
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
        
        if let additionalHeaderView = self.additionalHeaderView {
            self.tableView.tableHeaderView = self.makeComposedHeaderView(additionalHeaderView)
        } else {
            self.tableView.tableHeaderView = self.titleView
        }
        self.view.layoutIfNeeded()
        
        self.titleView.mainTitleLabel.text = self.viewTitle
        self.topView.subTitleLabel.text = self.viewTitle
        
        if #available(iOS 26.0, *) {
            self.tableView.contentInset.bottom = 20
        }
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
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.topView.snp.bottom)
            
            if #available(iOS 26.0, *) {
                $0.bottom.equalToSuperview()
            } else {
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            }
        }
    }
    
    private func makeComposedHeaderView(_ additionalView: UIView) -> UIView {
        let view = UIView(
            frame: .init(
                origin: .zero,
                size: CGSize(width: 100, height: self.titleView.frame.height + additionalView.frame.height)
            )
        )
        
        view.addSubviews(self.titleView, additionalView)
        self.titleView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(self.titleViewHeight)
        }
        
        additionalView.snp.makeConstraints {
            $0.top.equalTo(self.titleView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        return view
    }
    
    /// 테이블뷰 헤더의 height를 업데이트 할 때 사용해요.
    func updateTableHeaderViewHeight() {
        guard let headerView = self.tableView.tableHeaderView else {return}
        headerView.layoutIfNeeded()
        
        let size = headerView.systemLayoutSizeFitting(
            .init(width: self.tableView.bounds.width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        var frame = headerView.frame
        frame.size.height = size.height
        headerView.frame = frame
        
        self.tableView.beginUpdates()
        self.tableView.tableHeaderView = headerView
        self.tableView.endUpdates()
    }
}

extension TableVCCustom : UITableViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 25 {
            self.topView.isMainTitleHidden(false)
        } else {
            self.topView.isMainTitleHidden(true)
        }
    }
}
