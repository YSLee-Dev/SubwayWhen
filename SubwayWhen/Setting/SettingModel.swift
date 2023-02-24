//
//  SettingModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/24.
//

import Foundation

import RxSwift
import FirebaseDatabase

class SettingModel{
    private let database : DatabaseReference
    
    init(){
        self.database = Database.database().reference()
    }
    
    func licensesRequest() -> Observable<[String]>{
        let listData = PublishSubject<[String]>()
        
        self.database.observe(.value){ snaphot, _ in
            guard let value = snaphot.value as? [String : [String:[String]]] else {return}
            let subwayWhen = value["SubwayWhen"]
            let licenses = subwayWhen?["Licenses"]
            
            listData
                .onNext(licenses ?? [])
        }
        
        return listData
            .asObservable()
    }
}
