// 
//  Refreshable.swift
//  EasyRefresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/4/26
//  Copyright © 2019 Pircate. All rights reserved.
//

public enum RefreshState {
    case idle
    case pulling
    case willRefresh
    case refreshing
}

public protocol Refreshable: class {
    
    var isRefreshing: Bool { get }
    
    var refreshClosure: () -> Void { get set }
    
    init(refreshClosure: @escaping () -> Void)
    
    func addRefreshClosure(_ refreshClosure: @escaping () -> Void)
    
    func beginRefreshing()
    
    func endRefreshing()
}

public extension Refreshable where Self: RefreshStateful {
    
    var isRefreshing: Bool {
        return state == .refreshing
    }
}
