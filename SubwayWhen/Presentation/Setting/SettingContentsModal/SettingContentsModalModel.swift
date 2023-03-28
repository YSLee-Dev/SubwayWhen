//
//  SettingContentsModalModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/24.
//

import Foundation

import RxSwift
import FirebaseDatabase

class SettingContentsModalModel : SettingContentsModalModelProtocol{
    private let database : DatabaseReference
    
    init(){
        self.database = Database.database().reference()
    }
    
    func licensesRequest() -> Observable<[String]>{
        let listData = PublishSubject<[String]>()
        
        self.database.observe(.value){ snaphot, _ in
            guard let data = snaphot.value as? [String : [String :Any]] else {return}
            let subwayWhen = data["SubwayWhen"]
            let licenses = subwayWhen?["Licenses"]
            let result = licenses as? [String]
            
            listData.onNext(result ?? [])
        }
        
        return listData
            .asObservable()
    }
}
