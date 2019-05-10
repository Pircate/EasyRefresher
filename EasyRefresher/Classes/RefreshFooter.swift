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
    
    private lazy var constraintTop: NSLayoutConstraint? = {
        guard let scrollView = scrollView else { return nil }
        
        let constraint = topAnchor.constraint(equalTo: scrollView.topAnchor)
        constraint.isActive = true
        
        return constraint
    }()
    
    private var isTransform: Bool = false
    
    override func willBeginRefreshing(completion: @escaping () -> Void) {
        guard let scrollView = scrollView else { return }
        
        if scrollView.contentInset.top + scrollView.contentSize.height + 54 >= scrollView.bounds.height {
            UIView.animate(withDuration: 0.25, animations: {
                scrollView.contentInset.bottom = self.idleInset.bottom + 54
                scrollView.changed_inset.bottom += 54
                self.isTransform = false
            }, completion: { _ in completion() })
        } else {
            transform = CGAffineTransform(translationX: 0, y: -54)
            isTransform = true
            completion()
        }
    }
    
    override func willEndRefreshing() {
        guard let scrollView = scrollView else { return }
        
        if isTransform {
            transform = .identity
        } else {
            scrollView.changed_inset.bottom -= 54
        }
    }
    
    override func scrollViewContentOffsetDidChange(_ scrollView: UIScrollView) {
        let offset: CGFloat
        let constant: CGFloat
        
        if scrollView.contentSize.height > scrollView.bounds.height {
            offset = scrollView.contentOffset.y
                + scrollView.bounds.height
                - scrollView.contentSize.height
                - scrollView.contentInset.bottom
            constant = scrollView.contentSize.height
        } else {
            offset = scrollView.contentOffset.y + scrollView.contentInset.top
            constant = scrollView.bounds.height - scrollView.contentInset.top
        }
        
        constraintTop?.constant = constant
        
        if isAutoRefresh, scrollView.isDragging, offset > 0 {
            beginRefreshing()
            return
        }
        
        switch offset {
        case 54...:
            state = .willRefresh
        case 0..<54:
            state = .pulling
        default:
            state = .idle
        }
    }
    
    override func scrollViewPanStateDidChange(_ scrollView: UIScrollView) {
        guard !isAutoRefresh else { return }
        
        super.scrollViewPanStateDidChange(scrollView)
    }
}

extension RefreshFooter {
    
    func transformIdentity() {
        UIView.animate(withDuration: 0.25) {
            self.transform = .identity
        }
    }
}
