//
//  RefreshFooter.swift
//  Refresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/4/26
//  Copyright © 2019 Pircate. All rights reserved.
//

import UIKit

open class RefreshFooter: RefreshComponent {
    
    public override var stateTitles: [RefreshState : String] {
        get {
            guard super.stateTitles.isEmpty else { return super.stateTitles }
            
            return [.pulling: "上拉可以加载更多",
                    .willRefresh: "松开立即加载更多",
                    .refreshing: "正在加载更多的数据..."]
        }
        set {
            super.stateTitles = newValue
        }
    }
    
    var isAutoRefresh: Bool { return false }
    
    override var arrowDirection: ArrowDirection { return .up }
    
    private var scrollObservation: NSKeyValueObservation?
    
    private var panStateObservation: NSKeyValueObservation?
    
    private lazy var constraintTop: NSLayoutConstraint? = {
        guard let scrollView = scrollView else { return nil }
        
        let constraint = topAnchor.constraint(equalTo: scrollView.topAnchor)
        constraint.isActive = true
        
        return constraint
    }()
    
    private var isUpdateConstraint: Bool = false
    
    override func willBeginRefreshing(completion: @escaping () -> Void) {
        guard let scrollView = scrollView else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            if scrollView.contentSize.height > scrollView.bounds.height {
                scrollView.contentInset.bottom = self.idleInset.bottom + 54
                scrollView.changed_inset.bottom.increase()
                self.isUpdateConstraint = false
            } else {
                self.constraintTop?.constant = self.constant(by: scrollView) - 54
                self.isUpdateConstraint = true
            }
        }, completion: { _ in completion() })
    }
    
    override func willEndRefreshing() {
        guard let scrollView = scrollView else { return }
        
        if isUpdateConstraint {
            constraintTop?.constant = constant(by: scrollView)
        } else {
            scrollView.changed_inset.bottom.decrease()
        }
    }
    
    override func observe(_ scrollView: UIScrollView) {
        removeAllObservers()
        
        scrollObservation = scrollView.observe(\.contentOffset) { [weak self] this, change in
            guard let `self` = self else { return }
            
            this.bringSubviewToFront(self)
            
            guard !self.isRefreshing else { return }
            
            let offset: CGFloat
            let constant: CGFloat
            
            if this.contentSize.height > this.bounds.height {
                offset = this.contentOffset.y + this.bounds.height - this.contentSize.height
                constant = this.contentSize.height
            } else {
                offset = this.contentOffset.y + this.contentInset.top
                constant = this.bounds.height - this.contentInset.top
            }
            
            self.constraintTop?.constant = constant

            if self.isAutoRefresh, this.isDragging, offset > 0 {
                self.beginRefreshing()
                return
            }
            
            switch offset {
            case 54...:
                self.state = .willRefresh
            case 0..<54:
                self.state = .pulling
            default:
                self.state = .idle
            }
        }
        
        panStateObservation = scrollView.observe(
        \.panGestureRecognizer.state) { [weak self] this, change in
            guard let `self` = self,
                !self.isAutoRefresh,
                this.panGestureRecognizer.state == .ended else { return }
            
            guard self.state == .willRefresh else { return }
            
            self.beginRefreshing()
        }
    }
}

extension RefreshFooter {
    
    func resetConstraint() {
        guard isRefreshing, isUpdateConstraint, let scrollView = scrollView else { return }
        
        UIView.animate(withDuration: 0.25) {
            self.constraintTop?.constant = self.constant(by: scrollView)
            self.layoutIfNeeded()
        }
    }
    
    private func constant(by scrollView: UIScrollView) -> CGFloat {
        return scrollView.bounds.height - scrollView.contentInset.top
    }
    
    private func removeAllObservers() {
        scrollObservation?.invalidate()
        panStateObservation?.invalidate()
    }
}
