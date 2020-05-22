// 
//  AutoRefreshFooter.swift
//  EasyRefresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/5/8
//  Copyright © 2019 Pircate. All rights reserved.
//

open class AutoRefreshFooter: RefreshFooter {
    
    private let triggerPercent: CGFloat
    
    public init(
        triggerPercent: CGFloat = 0,
        height: CGFloat = 54,
        refreshClosure: @escaping () -> Void
    ) {
        self.triggerPercent = (0...1).clamp(triggerPercent)
        
        super.init(height: height, refreshClosure: refreshClosure)
    }
    
    public init<T>(
        stateView: T,
        triggerPercent: CGFloat = 0,
        height: CGFloat = 54,
        refreshClosure: @escaping () -> Void
    ) where T : UIView, T : RefreshStateful {
        self.triggerPercent = (0...1).clamp(triggerPercent)
        
        super.init(stateView: stateView, height: height, refreshClosure: refreshClosure)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.triggerPercent = 0
        
        super.init(coder: aDecoder)
    }
    
    override func scrollViewPanGestureStateDidChange(_ scrollView: UIScrollView) {}
    
    override func triggerAutoRefresh(by offset: CGFloat, isDragging: Bool) -> Bool {
        guard isDragging, offset > 0, offset / height > triggerPercent else {
            return false
        }
        
        return true
    }
}

private extension ClosedRange {
    
    func clamp(_ value : Bound) -> Bound {
        return lowerBound > value ? lowerBound
            : upperBound < value ? upperBound
            : value
    }
}
