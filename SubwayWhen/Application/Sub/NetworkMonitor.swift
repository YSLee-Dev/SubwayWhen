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
    
    private let networkMonitor : NWPathMonitor
    private let queue : DispatchQueue
    
    private init(networkMonitor : NWPathMonitor = .init(), queue : DispatchQueue = DispatchQueue.global(qos: .background)){
        self.networkMonitor = networkMonitor
        self.queue = queue
    }
    
    func monitorStart(){
        self.networkMonitor.start(queue: self.queue)
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
