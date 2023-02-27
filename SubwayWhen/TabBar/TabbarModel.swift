//
//  TabbarModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/27.
//

import Foundation

import FirebaseDatabase

class TabbarModel{
    private let database : DatabaseReference
    
    init(){
        self.database = Database.database().reference()
    }
    
    // 팝업 불러오기
    func popupRequest(result: @escaping (_ title:String, _ subTitle : String, _ contents:String)->()){
        self.database.observe(.value){ snaphot, _ in
            guard let value = snaphot.value as? [String : [String:[String]]] else {return}
            let subwayWhen = value["SubwayWhen"]
            let licenses = subwayWhen?["DefaultPopup"]
            
            result(licenses?[0] ?? "Nil", licenses?[1] ?? "", licenses?[2] ?? "")
            
        }
    }
    
    // 업데이트 버전 확인
    func versionRequest(result: @escaping (_ version:String)->()){
        self.database.observe(.value){ snaphot, _ in
            guard let value = snaphot.value as? [String : [String:[String]]] else {return}
            let subwayWhen = value["SubwayWhen"]
            let licenses = subwayWhen?["AppUpdateVersion"]
            
            result(licenses?.first ?? "1.0.0")
            
        }
    }
    
    // 저장된 설정 불러오기
    func saveSettingLoad() -> Result<Void, URLError>{
        guard let data = UserDefaults.standard.data(forKey: "saveSetting") else {return .failure(.init(.dataNotAllowed))}
        guard let setting = try? PropertyListDecoder().decode(SaveSetting.self, from: data) else {return .failure(.init(.cannotDecodeContentData))}
        
        FixInfo.saveSetting = setting
        print(setting)
        
        return .success(Void())
    }
}
