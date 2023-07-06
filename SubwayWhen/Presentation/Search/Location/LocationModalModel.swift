//
//  LocationModalModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/05.
//

import Foundation

import RxSwift
import RxCocoa

import CoreLocation

class LocationModalModel: NSObject, LocationModalModelProtocol {
    let locationManager: CLLocationManager
    let totalLoadModel : TotalLoadProtocol
    
    private let auth = PublishSubject<Bool>()
    private let locationData = PublishSubject<LocationData>()
    
    init (
        locationManager: CLLocationManager = .init(),
        model : TotalLoadModel = .init()
    ) {
        self.locationManager = locationManager
        self.totalLoadModel = model
    }
    
    func locationAuthCheck() -> Observable<Bool> {
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        return self.auth
            .asObservable()
    }
    
    func locationRequest() -> Observable<LocationData> {
        self.locationManager.startUpdatingLocation()
        
        return self.locationData
            .asObservable()
    }
    
    func locationToVicinityStationRequest(locationData: LocationData) -> Observable<[LocationModalSectionData]> {
        self.totalLoadModel.vcinityStationsDataLoad(x: locationData.lon, y: locationData.lat)
            .withUnretained(self)
            .map { model, data in
                let cellData = data.map {
                    LocationModalCellData(
                        id: $0.distance + $0.name,
                        name: model.stationNameSeparation(oldValue: $0.name),
                        line: model.lineSeparation(oldValue: $0.name),
                        distance: model.distanceTransform(oldValue: $0.distance)
                    )
                }
                
                return [LocationModalSectionData(id: UUID().uuidString, items: cellData)]
            }
    }
    
    private func distanceTransform(oldValue: String) -> String {
        guard let doubleValue = Int(oldValue) else {return "정보없음"}
        let numberFomatter = NumberFormatter()
        numberFomatter.numberStyle = .decimal
        
        guard let newValue = numberFomatter.string(for: doubleValue) else {return "정보없음"}
        return "\(newValue)m"
    }
    
    private func stationNameSeparation(oldValue: String) -> String {
        guard let wordIndex = oldValue.firstIndex(of: "역") else {return "정보없음"}
        return String(oldValue[oldValue.startIndex ..< wordIndex])
    }
    
    private func lineSeparation(oldValue: String) -> String {
        guard let wordIndex = oldValue.lastIndex(of: "역") else {return "정보없음"}
        return String(oldValue[oldValue.index(after: wordIndex) ..< oldValue.endIndex]).replacingOccurrences(of: " ", with: "")
    }
}

extension LocationModalModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            self.auth.onNext(false)
        } else if status == .authorizedWhenInUse {
            self.auth.onNext(true)
        } 
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            self.locationData.onNext(.init(lat: lat, lon: lon))
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationData.onNext(.init(lat: 0.0, lon: 0.0))
        print(error)
    }
}
