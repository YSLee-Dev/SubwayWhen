//
//  ShinbundangLineScheduleModel+CoreDataProperties.swift
//
//
//  Created by 이윤수 on 9/16/24.
//
//

import Foundation
import CoreData


extension ShinbundangLineScheduleModel {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShinbundangLineScheduleModel> {
        return NSFetchRequest<ShinbundangLineScheduleModel>(entityName: "ShinbundangLineScheduleModel")
    }
    
    @NSManaged public var stationName: String?
    @NSManaged public var scheduleDetailData: Data?
    @NSManaged public var scheduleVersion: Int?
    
    var scheduleData: [ShinbundangScheduleModel] {
        get {
            guard let data = self.scheduleDetailData else { return [] }
            return (try? JSONDecoder().decode([ShinbundangScheduleModel].self, from: data)) ?? []
        }
        set {
            self.scheduleDetailData = try? JSONEncoder().encode(newValue)
        }
    }
}
