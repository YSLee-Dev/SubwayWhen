//
//  SettingContentsModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/23.
//

import Foundation

import RxSwift
import RxCocoa
import RxOptional

class SettingContentsModalViewModel {
    let contents : Driver<String>
    
    let model = SettingModel()
    
    init(){
        let licenses = self.model.licensesRequest()
        
        self.contents = licenses
            .map{ data -> String in
                var value = ""
                
                for x in data{
                    value.append("\(x)\n")
                }
                return value
            }
            .asDriver(onErrorDriveWith: .empty())
    }
}
