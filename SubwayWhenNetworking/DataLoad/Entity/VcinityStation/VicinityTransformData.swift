//
//  VicinityTransformData.swift
//  SubwayWhenNetworking
//
//  Created by 이윤수 on 12/4/24.
//

import Foundation

struct VicinityTransformData: Equatable {
    let id: String
    let name: String
    let line: String
    let distance: String
    
    var lineColorName: String {
        guard self.line != "경의중앙선" else {return "경의선"}
        guard self.line != "에버라인" else {return "용인경전철"}
        guard self.line != "김포골드라인" else {return "김포도시철도"}
        guard self.line != "인천1호선" else {return "인천선"}
        guard self.line != "우이신설선" else {return "우이신설경전철"}
        
        guard Int(String(self.line.first ?? "A")) != nil else {return self.line}

        var value = self.line
        value.insert("0", at: self.line.startIndex)
        return value
    }
    
    var lineName: String {
        guard Int(String(self.line.first ?? "A")) == nil else {return self.line}
        
        if self.line == "공항철도" {
            return "공항"
        } else if self.line == "김포골드라인" {
            return "김포"
        } else if self.line == "에버라인" {
            return "용인"
        } else if self.line == "우이신설선" {
            return "우이"
        } else if self.line == "의정부경전철" {
            return "의정부"
        } else if self.line == "인천1호선" {
            return "인천1"
        } else if self.line == "인천2호선" {
            return "인천2"
        } else {
            return self.line.replacingOccurrences(of: "선", with: "")
        }
    }
}
