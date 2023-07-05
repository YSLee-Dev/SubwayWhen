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
    
    private let auth = PublishSubject<Bool>()
    private let locationData = PublishSubject<LocationData>()
    
    init (
        locationManager: CLLocationManager = .init()
    ) {
        self.locationManager = locationManager
    }
    
    func locationAuthCheck() -> Observable<Bool> {
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        return self.auth
            .asObservable()
    }
    
    func locationRequest() -> Observable<LocationData> {
        self.locationManager.requestLocation()
        
        return self.locationData
            .asObservable()
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
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationData.onNext(.init(lat: 0.0, lon: 0.0))
        print(error)
    }
}
