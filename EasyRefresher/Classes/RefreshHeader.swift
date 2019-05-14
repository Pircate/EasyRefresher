// 
//  RefreshHeader.swift
//  EasyRefresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/4/26
//  Copyright © 2019 Pircate. All rights reserved.
//

open class RefreshHeader: RefreshComponent {
    
    override func add(to scrollView: UIScrollView) {
        super.add(to: scrollView)
        
        bottomAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
    }
    
    override func prepare() {
        alpha = 0
        stateTitles = [.pulling: "下拉可以刷新",
                       .willRefresh: "松开立即刷新",
                       .refreshing: "正在刷新数据中..."]
    }
    
    override func willBeginRefreshing(completion: @escaping () -> Void) {
        guard let scrollView = scrollView else { return }
        
        alpha = 1
        
        UIView.animate(withDuration: 0.25, animations: {
            scrollView.contentInset.top = self.originalInset.top + 54
            scrollView.changed_inset.top = 54
        }, completion: { _ in completion() })
    }
    
    override func didEndRefreshing(completion: @escaping () -> Void) {
        guard let scrollView = scrollView else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            scrollView.contentInset.top -= scrollView.changed_inset.top
            scrollView.changed_inset.top = 0
        }, completion: { _ in completion() })
    }
    
    override func scrollViewContentOffsetDidChange(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + scrollView.refreshInset.top
        
        switch offset {
        case 0...:
            state = .idle
            alpha = 0
        case -54..<0:
            state = .pulling
            alpha = -offset / 54
        default:
            state = .willRefresh
            alpha = 1
        }
    }
}
