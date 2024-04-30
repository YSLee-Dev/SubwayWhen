//
//  BundleExtension.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/24.
//

import Foundation

extension Bundle{
    func tokenLoad(_ name : String) -> String{
        guard let fileUrl = Bundle.main.url(forResource: "RequestToken", withExtension: "plist") else {return ""}
        guard let list = NSDictionary(contentsOf: fileUrl) else {return ""}
        guard let value = list[name] as? String else {return ""}
        return value
        
    }
}
