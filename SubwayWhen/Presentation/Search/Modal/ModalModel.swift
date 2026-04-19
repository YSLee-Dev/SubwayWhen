//
//  ModalModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

class ModalModel : ModalModelProtocol{
    func useLineTokorailCode(_ useLine : String) -> String{
        var brand = ""
        if useLine == "경의중앙"{
            brand = "K4"
        }else if useLine == "수인분당"{
            brand = "K1"
        }else if useLine == "경춘"{
            brand = "K2"
        }else if useLine == "우이"{
            brand = "UI"
        }else if useLine == "신분당"{
            brand = "D1"
        }else if useLine == "공항"{
            brand = "A1"
        }else{
            brand = ""
        }
        
        return brand
    }
    
}
