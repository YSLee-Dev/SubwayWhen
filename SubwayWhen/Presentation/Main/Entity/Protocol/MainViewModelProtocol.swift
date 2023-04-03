//
//  MainViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift
import RxCocoa

protocol MainViewModelProtocol{
    var mainTableViewModel : MainTableViewModelProtocol{get}
    
    var reloadData : PublishRelay<Void>{get}
    
    var reportBtnClick : Driver<Void>{get}
    var stationPlusBtnClick : Driver<Void>{get}
    var editBtnClick : Driver<Void>{get}
    var clickCellData : Driver<MainTableViewCellData>{get}
    var mainTitle : Driver<String>{get}
    var mainTitleHidden : Driver<Void>{get}
}
