//
//  AppDefaultModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/27.
//

import Foundation

import FirebaseDatabase

class AppDefaultModel : AppDefaultModelProtocol{
    private let database : DatabaseReference
    
    init(){
        self.database = Database.database().reference()
    }
    
    deinit{
        AppLogger.core.log(.debug, "AppDefaultModel DEINIT")
    }
    
    // 팝업 불러오기
    func popupRequest(result: @escaping (_ title:String, _ subTitle : String, _ contents:String)->()){
        self.database.observe(.value){ snaphot, _ in
            guard let data = snaphot.value as? [String : [String :Any]] else {return}
            let subwayWhen = data["SubwayWhen"]
            let defaultPopup = subwayWhen?["DefaultPopup"]
            let value = defaultPopup as? [String]
            
            result(value?[0] ?? "Nil", value?[1] ?? "", value?[2].replacingOccurrences(of: "(E)", with: "\n") ?? "")
        }
    }
    
    // 업데이트 버전 확인
    func versionRequest(result: @escaping (_ version:String)->()){
        self.database.observe(.value){ snaphot, _ in
            guard let value = snaphot.value as? [String : [String:Any]] else {return}
            let subwayWhen = value["SubwayWhen"]
            let appUpdateVersion = subwayWhen?["AppUpdateVersion"]
            let version = appUpdateVersion as? [String]
            
            result(version?.first ?? "1.0.0")
        }
    }
    
    // 저장된 설정 불러오기
    func saveSettingLoad() -> Result<SaveSetting, URLError>{
        guard let data = UserDefaults.shared.data(forKey: "saveSetting") else {return .failure(.init(.dataNotAllowed))}
        guard let setting = try? PropertyListDecoder().decode(SaveSetting.self, from: data) else {return .failure(.init(.cannotDecodeContentData))}
        
        return .success(setting)
    }
    
    
    // 저장된 지하철역 불러오기
    func saveStationLoad() -> Result<[SaveStation], URLError>{
        guard let data = UserDefaults.shared.data(forKey: "saveStation") else {return .failure(.init(.dataNotAllowed))}
        guard let list = try? PropertyListDecoder().decode([SaveStation].self, from: data) else {return .failure(.init(.cannotDecodeContentData))}
        
        return .success(list)
    }
    
    // 공휴일 데이터 불러오기
    func holidayDataLoad(result: @escaping (_ holidayData: HolidayData) -> ()) {
        self.database.observe(.value) { snapshot, _ in
            guard let data = snapshot.value as? [String: [String: Any]] else { result(.init(version: 0, list: [])); return }
            let subwayWhen = data["SubwayWhen"]
            let holidayList = subwayWhen?["HolidayList"] as? [String: Any]
            let version = holidayList?["version"] as? Int ?? 0
            let list = holidayList?["value"] as? [String] ?? []
            
            result(HolidayData(version: version, list: list))
        }
    }
    
    // 저장된 공휴일 데이터 불러오기
    func savedHolidayDataLoad() -> HolidayData {
        let version = UserDefaults.shared.integer(forKey: "holidayVersion")
        let list = UserDefaults.shared.stringArray(forKey: "holidayList") ?? []
        return .init(version: version, list: list)
    }
}
