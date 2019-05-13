//
//  RefreshFooter.swift
//  EasyRefresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/4/26
//  Copyright © 2019 Pircate. All rights reserved.
//

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
    
    private lazy var constraintOfTopAnchor: NSLayoutConstraint? = {
        guard let scrollView = scrollView, isDescendant(of: scrollView) else { return nil }
        
        let constraint = topAnchor.constraint(equalTo: scrollView.topAnchor)
        constraint.isActive = true
        
        return constraint
    }()
    
    private var isTransform: Bool = false
    
    override func willBeginRefreshing(completion: @escaping () -> Void) {
        guard let scrollView = scrollView else { return }
        
        if offsetOfContentGreaterThanScrollView(scrollView) >= -54 {
            UIView.animate(withDuration: 0.25, animations: {
                scrollView.contentInset.bottom = self.originalInset.bottom + 54
                scrollView.changed_inset.bottom += 54
                self.isTransform = false
            }, completion: { _ in completion() })
            
            constraintOfTopAnchor?.constant = scrollView.contentSize.height
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
        
        if offsetOfContentGreaterThanScrollView(scrollView) >= 0 {
            offset = scrollView.contentOffset.y
                + scrollView.bounds.height
                - scrollView.contentSize.height
                - scrollView.contentInset.bottom
        } else {
            offset = scrollView.contentOffset.y + scrollView.contentInset.top
        }
        
        updateConstraintOfTopAnchorIfNeeded()
        
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
    
    func constantOfTopAnchor(equalTo scrollView: UIScrollView) -> CGFloat {
        return offsetOfContentGreaterThanScrollView(scrollView) >= 0
            ? scrollView.contentSize.height
            : scrollView.bounds.height - scrollView.contentInset.top
    }
}

extension RefreshFooter {
    
    func updateConstraintOfTopAnchorIfNeeded() {
        guard let scrollView = scrollView else { return }
        
        constraintOfTopAnchor?.constant = constantOfTopAnchor(equalTo: scrollView)
    }
}

extension RefreshFooter {
    
    func reset() {
        UIView.animate(withDuration: 0.25) { self.transform = .identity }
        
        updateConstraintOfTopAnchorIfNeeded()
    }
    
    private func offsetOfContentGreaterThanScrollView(_ scrollView: UIScrollView) -> CGFloat {
        return scrollView.contentInset.top + scrollView.contentSize.height - scrollView.bounds.height
    }
}
