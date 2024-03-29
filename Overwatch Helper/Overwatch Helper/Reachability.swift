//
//  Reachability.swift
//  Overwatch Helper
//
//  Created by Benyan Gong on 3/13/17.
//  Copyright © 2017 Alex&Ben. All rights reserved.
//
import Foundation
import SystemConfiguration

protocol Utilities{
    
}

extension NSObject: Utilities{
    
    /// Network ReachabilityStatus
    ///
    /// - notReachable: No Network
    /// - reachableViaWWAN: 4G/3G/2G
    /// - reachableViaWiFi: Wifi
    enum ReachabilityStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }
    
    
    /// Current Network Reachablitiy
    var currentReachability:ReachabilityStatus{
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        var flags:SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags){
            return .notReachable
        }
        
        if flags.contains(.reachable) == false{
            return .notReachable
        }
            
        else if flags.contains(.isWWAN) == true{
            return .reachableViaWWAN
        }
            
        else if flags.contains(.connectionRequired) == false{
            return .reachableViaWiFi
        }
            
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false{
            return .reachableViaWiFi
        }
        else{
            return .notReachable
        }
        
    }
}
