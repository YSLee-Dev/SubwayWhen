//
//  AppDefaultModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/23.
//

import Foundation

protocol AppDefaultModelProtocol{
    func popupRequest(result: @escaping (_ title:String, _ subTitle : String, _ contents:String)->())
    func versionRequest(result: @escaping (_ version:String)->())
    func saveSettingLoad() -> Result<SaveSetting, URLError>
    func saveStationLoad() -> Result<[SaveStation], URLError>
}
