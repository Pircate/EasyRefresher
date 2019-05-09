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
    
    override func willBeginRefreshing(completion: @escaping () -> Void) {
        guard let scrollView = scrollView else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            scrollView.contentInset.top = self.idleInset.top + 54
            scrollView.changed_inset.top += 54
        }, completion: { _ in completion() })
    }
    
    override func willEndRefreshing() {
        guard let scrollView = scrollView else { return }
        
        scrollView.changed_inset.top -= 54
        
        guard let footer = scrollView.refresh_footer as? RefreshFooter else { return }
        
        footer.resetConstraint()
    }
    
    override func add(into scrollView: UIScrollView) {
        super.add(into: scrollView)
        
        bottomAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
    }
    
    override func scrollViewContentOffsetDidChange(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + scrollView.contentInset.top
        
        switch offset {
        case 0...:
            state = .idle
        case -54..<0:
            state = .pulling
        default:
            state = .willRefresh
        }
    }
}
