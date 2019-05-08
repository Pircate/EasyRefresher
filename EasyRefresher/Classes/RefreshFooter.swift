//
//  RefreshFooter.swift
//  Refresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/4/26
//  Copyright © 2019 Pircate. All rights reserved.
//

import UIKit

open class RefreshFooter: UIView {
    
    open var state: RefreshState = .idle {
        didSet {
            guard state != oldValue else { return }
            
            switch state {
            case .idle:
                stopRefreshing()
            case .refreshing:
                refreshClosure()
                
                initialInsetTop = scrollView?.contentInset.top ?? 0
                initialInsetBottom = scrollView?.contentInset.bottom ?? 0
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
    
    open var isAutoRefresh: Bool { return false }
    
    public var stateTitles: [RefreshState: String] = [
        .pulling: "上拉可以加载更多",
        .willRefresh: "松开立即加载更多",
        .refreshing: "正在加载更多的数据..."]
    
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
    
    private var initialInsetTop: CGFloat = 0
    
    private var initialInsetBottom: CGFloat = 0
    
    weak var scrollView: UIScrollView? {
        didSet {
            guard let scrollView = scrollView else { return }
            
            initialInsetTop = scrollView.contentInset.top
            initialInsetBottom = scrollView.contentInset.bottom
            scrollView.alwaysBounceVertical = true
            
            add(into: scrollView)
            observe(scrollView)
        }
    }
    
    public required init(refreshClosure: @escaping () -> Void) {
        self.refreshClosure = refreshClosure
        
        super.init(frame: CGRect.zero)
        
        build()
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

extension RefreshFooter {
    
    private func build() {
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func add(into scrollView: UIScrollView) {
        guard !scrollView.subviews.contains(self) else { return }
        
        scrollView.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        heightAnchor.constraint(equalToConstant: 54).isActive = true
    }
    
    private func removeAllObservers() {
        scrollObservation?.invalidate()
        panStateObservation?.invalidate()
    }
    
    private func observe(_ scrollView: UIScrollView) {
        removeAllObservers()
        
        scrollObservation = scrollView.observe(\.contentOffset) { [weak self] this, change in
            guard let `self` = self else { return }
            
            this.bringSubviewToFront(self)
            
            guard !self.isRefreshing else {
                self.startRefreshing()
                return
            }
            
            let offset: CGFloat
            let constant: CGFloat
            
            if this.contentSize.height > this.bounds.height {
                offset = this.contentOffset.y + this.bounds.height - this.contentSize.height
                constant = this.contentSize.height
            } else {
                offset = this.contentOffset.y
                constant = this.bounds.height
            }
            
            self.translatesAutoresizingMaskIntoConstraints = false
            self.topAnchor.constraint(equalTo: this.topAnchor, constant: constant).isActive = true
            
            if self.isAutoRefresh, offset > 0 {
                self.state = .refreshing
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
            
            self.state = .refreshing
        }
    }
}

extension RefreshFooter {
    
    private func startRefreshing() {
        indicatorView.startAnimating()
        
        UIView.animate(withDuration: 0.25) {
            if self.contentSizeHeightGreaterThanBoundsHeight {
                self.scrollView?.contentInset.bottom = self.initialInsetBottom + 54
            } else {
                self.scrollView?.contentInset.top = self.initialInsetTop - 54
            }
        }
    }
    
    private func stopRefreshing() {
        indicatorView.stopAnimating()
        
        UIView.animate(withDuration: 0.25) {
            if self.contentSizeHeightGreaterThanBoundsHeight {
                self.scrollView?.contentInset.bottom = self.initialInsetBottom
            } else {
                self.scrollView?.contentInset.top = self.initialInsetTop
            }
        }
    }
    
    private var contentSizeHeightGreaterThanBoundsHeight: Bool {
        guard let scrollView = scrollView else { return false }
        
        return scrollView.contentSize.height > scrollView.bounds.height
    }
}

extension RefreshFooter: Refreshable {
}

extension RefreshFooter: HasStateTitle {
}
