//
//  NetworkMonitor.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/21.
//

import Foundation

import Network

final class NetworkMonitor{
    // 싱글톤
    static let shared = NetworkMonitor()
    
    private let networkMonitor = NWPathMonitor()
    private let queue = DispatchQueue.global()
    
    public private(set) var isConnected: Bool = false
    
    func monitorStart(){
        self.networkMonitor.start(queue: self.queue)
        self.networkMonitor.pathUpdateHandler = {[weak self] path in
            self?.isConnected = path.status == .satisfied
        }
    }
    
    func pathUpdate(result : @escaping (_ status : Bool)->()){
        self.networkMonitor.pathUpdateHandler = {path in
            DispatchQueue.main.async {
                result(path.status == .satisfied)
            }
        }
    }
    
    func monitorStop(){
        self.networkMonitor.cancel()
    }
}
