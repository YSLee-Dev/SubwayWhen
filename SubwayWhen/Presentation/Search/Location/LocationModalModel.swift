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
}

extension LocationModalModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            self.auth.onNext(false)
        } else if status == .authorizedWhenInUse {
            self.auth.onNext(true)
        }
    }
}
