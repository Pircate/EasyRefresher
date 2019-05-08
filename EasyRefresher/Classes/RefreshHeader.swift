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
                stopRefreshing()
            case .refreshing:
                refreshClosure()
                
                initialInsetTop = scrollView?.contentInset.top ?? 0
                startRefreshing()
            default:
                break
            }
            
            if let attributedTitle = attributedTitle(for: state) {
                stateLabel.attributedText = attributedTitle
            } else {
                stateLabel.text = title(for: state)
            }
            
            stateLabel.sizeToFit()
        }
    }
    
    open var refreshClosure: () -> Void = {}
    
    public var stateTitles: [RefreshState: String] = [
        .pulling: "下拉可以刷新",
        .willRefresh: "松开立即刷新",
        .refreshing: "正在刷新数据中..."]
    
    public var stateAttributedTitles: [RefreshState: NSAttributedString] = [:]
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [indicatorView, stateLabel])
        stackView.spacing = 10
        return stackView
    }()
    
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
        self.init(frame: CGRect.zero)
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
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func removeAllObservers() {
        scrollObservation?.invalidate()
        panStateObservation?.invalidate()
    }
    
    private func addObservers() {
        scrollObservation = scrollView?.observe(\.contentOffset) { [weak self] this, change in
            guard let `self` = self else { return }
            
            this.bringSubviewToFront(self)
            
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

extension RefreshHeader: Refreshable {
    
    public func addRefresher(_ refreshClosure: @escaping () -> Void) {
        guard let scrollView = scrollView else { return }
        
        removeAllObservers()
        addObservers()
        
        guard !scrollView.subviews.contains(self) else { return }
        
        scrollView.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        bottomAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        heightAnchor.constraint(equalToConstant: 54).isActive = true
        
        self.refreshClosure = refreshClosure
    }
}

extension RefreshHeader: HasStateTitle {
}
