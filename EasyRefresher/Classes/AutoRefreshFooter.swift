// 
//  AutoRefreshFooter.swift
//  EasyRefresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/5/8
//  Copyright © 2019 Pircate. All rights reserved.
//

open class AutoRefreshFooter: RefreshFooter {

    override var isAutoRefresh: Bool { true }
    
    public init(
        triggerPercent: CGFloat = 0,
        height: CGFloat = 54,
        refreshClosure: @escaping () -> Void
    ) {
        super.init(height: height, refreshClosure: refreshClosure)
        
        self.triggerPercent = triggerPercent
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

open class AppearanceAutoRefreshFooter: AppearanceRefreshFooter {
    
    override var isAutoRefresh: Bool { true }
    
    public init(
        triggerPercent: CGFloat = 0,
        height: CGFloat = 54,
        refreshClosure: @escaping () -> Void
    ) {
        super.init(height: height, refreshClosure: refreshClosure)
        
        self.triggerPercent = triggerPercent
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
