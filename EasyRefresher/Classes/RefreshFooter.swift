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
    
    public override init(refreshClosure: @escaping () -> Void) {
        super.init(refreshClosure: refreshClosure)
        
        self.alpha = 0
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.alpha = 0
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.alpha = 0
    }
    
    override func willBeginRefreshing(completion: @escaping () -> Void) {
        guard let scrollView = scrollView else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 1
            scrollView.contentInset.bottom = self.originalInset.bottom + 54
            scrollView.changed_inset.bottom = 54
        }, completion: { _ in completion() })
    }
    
    override func didEndRefreshing(completion: @escaping () -> Void) {
        guard let scrollView = scrollView else { return }
        
        alpha = 0
        UIView.animate(withDuration: 0.25, animations: {
            scrollView.contentInset.bottom -= scrollView.changed_inset.bottom
            scrollView.changed_inset.bottom = 0
        }, completion: { _ in completion() })
    }
    
    override func scrollViewContentOffsetDidChange(_ scrollView: UIScrollView) {
        let offset: CGFloat
        
        if scrollView.refreshInset.top + scrollView.contentSize.height >= scrollView.bounds.height {
            offset = scrollView.contentOffset.y
                + scrollView.bounds.height
                - scrollView.contentSize.height
                - scrollView.refreshInset.bottom
        } else {
            offset = scrollView.contentOffset.y + scrollView.refreshInset.top
        }
        
        if isAutoRefresh, scrollView.isDragging, offset > 0 {
            beginRefreshing()
            return
        }
        
        changeState(by: offset)
    }
    
    override func scrollViewContentSizeDidChange(_ scrollView: UIScrollView) {
        super.scrollViewContentSizeDidChange(scrollView)
        
        updateConstraintOfTopAnchorIfNeeded()
    }
    
    override func scrollViewPanStateDidChange(_ scrollView: UIScrollView) {
        guard !isAutoRefresh else { return }
        
        super.scrollViewPanStateDidChange(scrollView)
    }
    
    func changeState(by offset: CGFloat) {
        switch offset {
        case 54...:
            state = .willRefresh
            alpha = 1
        case 0..<54:
            state = .pulling
            alpha = offset / 54
        default:
            state = .idle
            alpha = 0
        }
    }
}

extension RefreshFooter {
    
    private func updateConstraintOfTopAnchorIfNeeded() {
        guard let scrollView = scrollView else { return }
        
        constraintOfTopAnchor?.constant = scrollView.contentSize.height
    }
}
