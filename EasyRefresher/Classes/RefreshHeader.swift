// 
//  RefreshHeader.swift
//  Refresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/4/26
//  Copyright © 2019 Pircate. All rights reserved.
//

import UIKit

open class RefreshHeader: UIView {
    
    open var state: RefreshState = .idle {
        didSet {
            guard state != oldValue else { return }
            
            switch state {
            case .idle:
                stateLabel.text = ""
                stopRefreshing()
            case .pulling:
                stateLabel.text = "下拉刷新"
            case .willRefresh:
                stateLabel.text = "释放加载"
            case .refreshing:
                stateLabel.text = "正在刷新中..."
                refreshClosure()
                
                initialInsetTop = scrollView?.contentInset.top ?? 0
                startRefreshing()
            }
            
            stateLabel.sizeToFit()
        }
    }
    
    open var refreshClosure: () -> Void = {}
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        UIActivityIndicatorView(style: .gray)
    }()
    
    private lazy var stateLabel: UILabel = {
        let stateLabel = UILabel()
        stateLabel.font = UIFont.systemFont(ofSize: 14)
        stateLabel.textAlignment = .center
        return stateLabel
    }()
    
    private var scrollObservation: NSKeyValueObservation?
    
    private var panStateObservation: NSKeyValueObservation?
    
    private weak var scrollView: UIScrollView?
    
    private var initialInsetTop: CGFloat = 0
    
    convenience init(scrollView: UIScrollView) {
        self.init(frame: CGRect(x: 0, y: -54, width: UIScreen.main.bounds.width, height: 54))
        self.scrollView = scrollView
        self.initialInsetTop = scrollView.contentInset.top
        scrollView.alwaysBounceVertical = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        build()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        build()
    }
}

extension RefreshHeader {
    
    private func build() {
        addSubview(stateLabel)
        addSubview(indicatorView)
        
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        stateLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stateLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.rightAnchor.constraint(equalTo: stateLabel.leftAnchor, constant: -10).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func removeAllObservers() {
        scrollObservation?.invalidate()
        panStateObservation?.invalidate()
    }
    
    private func addObservers() {
        scrollObservation = scrollView?.observe(\.contentOffset) { [weak self] this, change in
            guard let `self` = self else { return }
            
            guard !self.isRefreshing else {
                self.startRefreshing()
                return
            }
            
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
        
        panStateObservation = scrollView?.observe(\.panGestureRecognizer.state) { [weak self] this, change in
            guard let `self` = self, this.panGestureRecognizer.state == .ended else { return }
            
            guard self.state == .willRefresh else { return }
            
            self.state = .refreshing
        }
    }
    
    private func startRefreshing() {
        indicatorView.startAnimating()
        
        UIView.animate(withDuration: 0.25) {
            self.scrollView?.contentInset.top = self.initialInsetTop + 54
        }
    }
    
    private func stopRefreshing() {
        indicatorView.stopAnimating()
        
        UIView.animate(withDuration: 0.25) {
            self.scrollView?.contentInset.top = self.initialInsetTop
        }
    }
}

extension RefreshHeader: RefreshComponent {
    
    public func addRefresher(_ refreshClosure: @escaping () -> Void) {
        guard let scrollView = scrollView else { return }
        
        removeAllObservers()
        addObservers()
        
        guard !scrollView.subviews.contains(self) else { return }
        
        scrollView.addSubview(self)
        self.refreshClosure = refreshClosure
    }
}
