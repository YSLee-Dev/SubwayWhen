//
//  LocationManager.swift
//  SubwayWhen
//
//  Created by 이윤수 on 12/4/24.
//

import Foundation
import CoreLocation
import RxSwift

class LocationManager: NSObject, LocationManagerProtocol {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private let auth = PublishSubject<Bool>()
    private let locationData = PublishSubject<LocationData>()
    private let bag = DisposeBag()
    
    private override init() {
        super.init()
        self.locationManager.delegate = self
    }
    
    /// 위치권한을 요청할 때 사용해요.
    func locationAuthRequest() async -> Bool {
        if self.locationManager.authorizationStatus == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
            
            return await withCheckedContinuation { continuation in
                self.auth.take(1).subscribe(onNext: {
                    continuation.resume(returning: $0)
                })
                .disposed(by: self.bag)
            }
        } else {
            return self.locationAuthCheck()
        }
    }
    
    /// 위치권한을 확인할 때 사용해요.
    func locationAuthCheck() -> Bool {
        return self.locationManager.authorizationStatus == .authorizedWhenInUse
    }
    
    /// 위치 데이터를 요청할 때 사용해요
    /// auth 권한이 없으면 실행되지 않아요.
    func locationRequest() async -> LocationData? {
        if !self.locationAuthCheck() {return nil}
        self.locationManager.startUpdatingLocation()
        
        return await withCheckedContinuation { continuation in
            self.locationData.take(1).subscribe(onNext: {
                continuation.resume(returning: $0)
                self.locationManager.stopUpdatingLocation()
            })
            .disposed(by: self.bag)
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
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
