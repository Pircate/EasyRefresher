// 
//  RefreshHeader.swift
//  Refresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/4/26
//  Copyright © 2019 Pircate. All rights reserved.
//

import UIKit

open class RefreshHeader: RefreshComponent {
    
    public override var stateTitles: [RefreshState : String] {
        get {
            guard super.stateTitles.isEmpty else { return super.stateTitles }
            
            return [.pulling: "下拉可以刷新",
                    .willRefresh: "松开立即刷新",
                    .refreshing: "正在刷新数据中..."]
        }
        set {
            super.stateTitles = newValue
        }
    }
    
    private var scrollObservation: NSKeyValueObservation?
    
    private var panStateObservation: NSKeyValueObservation?
    
    override func willBeginRefreshing(completion: @escaping () -> Void) {
        guard let scrollView = scrollView else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            scrollView.contentInset.top = self.idleInset.top + 54
            scrollView.changed_inset.top.increase()
        }, completion: { _ in completion() })
    }
    
    override func willEndRefreshing() {
        guard let scrollView = scrollView else { return }
        
        scrollView.changed_inset.top.decrease()
        
        guard let footer = scrollView.refresh_footer as? RefreshFooter else { return }
        
        footer.resetConstraint()
    }
    
    override func add(into scrollView: UIScrollView) {
        super.add(into: scrollView)
        
        bottomAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
    }
    
    override func observe(_ scrollView: UIScrollView) {
        removeAllObservers()
        
        scrollObservation = scrollView.observe(\.contentOffset) { [weak self] this, change in
            guard let `self` = self else { return }
            
            this.bringSubviewToFront(self)
            
            guard !self.isRefreshing else { return }
            
            let offset = this.contentOffset.y + this.contentInset.top
            
            switch offset {
            case 0...:
                self.state = .idle
            case -54..<0:
                self.state = .pulling
            default:
                self.state = .willRefresh
            }
        }
        
        panStateObservation = scrollView.observe(\.panGestureRecognizer.state) { [weak self] this, change in
            guard let `self` = self, this.panGestureRecognizer.state == .ended else { return }
            
            guard self.state == .willRefresh else { return }
            
            self.beginRefreshing()
        }
    }
}

private extension RefreshHeader {
    
    func removeAllObservers() {
        scrollObservation?.invalidate()
        panStateObservation?.invalidate()
    }
}

extension CGFloat {
    
    mutating func increase() {
        self += 54
    }
    
    mutating func decrease() {
        self -= 54
    }
}
