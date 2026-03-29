//
//  Calendar+.swift
//  SubwayWhen
//
//  Created by 이윤수 on 3/22/26.
//

import Foundation

extension Calendar {
    func dayType(_ date: Date = Date()) -> DayType {
        let weekday = self.component(.weekday, from: date)

        if weekday == 1 { return .holiday }
        if weekday == 7 { return .saturday }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: date)
        return FixInfo.holidayData.list.contains(dateString) ? .holiday : .weekday
    }
}
