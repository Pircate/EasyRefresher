// 
//  RefreshComponent.swift
//  EasyRefresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/5/8
//  Copyright © 2019 Pircate. All rights reserved.
//

import UIKit

public protocol RefreshDelegate: class {
    func refresherDidRefresh(_ refresher: Refresher)
}

open class RefreshComponent: RefreshStatefulView {
    
    internal(set) public var state: RefreshState = .idle {
        didSet {
            guard state != oldValue else { return }
            
            stateDidChange(state)
        }
    }
    
    public var refreshClosure: (() -> Void)?
    
    weak var scrollView: UIScrollView? {
        didSet { scrollView?.alwaysBounceVertical = true }
    }
    
    lazy var originalInset: UIEdgeInsets = {
        guard let scrollView = scrollView else { return .zero }
        
        return scrollView.contentInset
    }()
    
    private weak var delegate: RefreshDelegate?
    
    private var isEnding: Bool = false
    
    private lazy var observation: ScrollViewObservation = { ScrollViewObservation() }()
    
    // MARK: - life cycle
    public init(height: CGFloat = 54, refreshClosure: @escaping () -> Void) {
        self.refreshClosure = refreshClosure
        
        super.init(height: height)
        
        prepare()
    }
    
    public init<T>(
        stateView: T,
        height: CGFloat = 54,
        refreshClosure: @escaping () -> Void
    ) where T: UIView, T: RefreshStateful {
        self.refreshClosure = refreshClosure
        
        super.init(empty: height)
        
        prepare()
        
        addStateView(stateView)
        didChangeStateView(stateView)
    }
    
    public init(height: CGFloat = 54, delegate: RefreshDelegate) {
        self.delegate = delegate
        
        super.init(height: height)
        
        prepare()
    }
    
    public init<T>(
        stateView: T,
        height: CGFloat = 54,
        delegate: RefreshDelegate
    ) where T: UIView, T: RefreshStateful {
        self.delegate = delegate
        
        super.init(empty: height)
        
        prepare()
        
        addStateView(stateView)
        didChangeStateView(stateView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        prepare()
    }
    
    override init(height: CGFloat = 54) {
        super.init(height: height)
        
        prepare()
    }
    
    // MARK: - override
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        observation.invalidate()
        
        guard let scrollView = newSuperview as? UIScrollView else { return }
        
        observe(scrollView)
    }
    
    func add(to scrollView: UIScrollView) {
        guard !scrollView.subviews.contains(self) else { return }
        
        scrollView.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func prepare() {
        setTitle("loading".localized(), for: .refreshing)
        setTitle("no_more_data".localized(), for: .disabled)
    }
    
    func didChangeState(by offset: CGFloat) {
        switch offset {
        case 0...:
            state = .idle
        case -height..<0:
            state = .pulling
        default:
            state = .willRefresh
        }
    }
    
    func willBeginRefreshing(completion: @escaping () -> Void) {}
    
    func didEndRefreshing(completion: @escaping () -> Void) {}
    
    func scrollViewContentInsetDidReset(_ scrollView: UIScrollView) {}
    
    func scrollViewContentOffsetDidChange(_ scrollView: UIScrollView) {}
    
    func scrollViewContentSizeDidChange(_ scrollView: UIScrollView) {}
    
    func scrollViewPanGestureStateDidChange(_ scrollView: UIScrollView) {
        guard scrollView.panGestureRecognizer.state == .ended, state == .willRefresh else { return }
        
        beginRefreshing()
    }
}

extension RefreshComponent {
    
    func didChangeAlpha(by offset: CGFloat) {
        guard automaticallyChangeAlpha else {
            alpha = 1
            return
        }
        
        switch offset {
        case 0...:
            alpha = 0
        case -height..<0:
            alpha = -offset / height
        default:
            alpha = 1
        }
    }
}

// MARK: - private
private extension RefreshComponent {
    
    var isDescendantOfScrollView: Bool {
        guard let scrollView = scrollView else { return false }
        
        return isDescendant(of: scrollView)
    }
    
    func observe(_ scrollView: UIScrollView) {
        observation.observe(scrollView) { [weak self] this, keyPath in
            guard let `self` = self else { return }
            
            switch keyPath {
            case .contentOffset:
                this.bringSubviewToFront(self)
                
                guard !self.isRefreshing else { return }
                
                self.scrollViewContentOffsetDidChange(this)
            case .contentSize:
                self.scrollViewContentSizeDidChange(this)
            case .panGestureState:
                self.scrollViewPanGestureStateDidChange(this)
            }
        }
    }
    
    func addStateView(_ stateView: UIView) {
        addSubview(stateView)
        
        stateView.translatesAutoresizingMaskIntoConstraints = false
        stateView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stateView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stateView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stateView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func didChangeStateView(_ stateView: RefreshStateful) {
        stateChanged = { [weak self] in
            guard let self = self else { return }
            
            stateView.refresher(self, didChangeState: $0)
        }
        
        offsetChanged = { [weak self] in
            guard let self = self else { return }
            
            stateView.refresher(self, didChangeOffset: $0)
        }
    }
    
    func prepareForRefreshing() {
        guard let scrollView = scrollView else { return }
        
        var contentInset = scrollView.contentInset
        contentInset.top -= scrollView.changed_inset.top
        contentInset.left -= scrollView.changed_inset.left
        contentInset.bottom -= scrollView.changed_inset.bottom
        contentInset.right -= scrollView.changed_inset.right
        
        originalInset = contentInset
    }
    
    func endRefreshing(to state: RefreshState) {
        assert(isDescendantOfScrollView, "Please add refresher to UIScrollView before end refreshing.")
        
        guard isRefreshing, !isEnding else { return }
        
        isEnding = true
        
        didEndRefreshing {
            self.state = state
            self.isEnding = false
        }
    }
    
    func shouldRefreshing() -> Bool {
        return !isRefreshing && isEnabled && !isHidden
    }
}

// MARK: - Refresher
extension RefreshComponent: Refreshable {
    
    public var isEnabled: Bool {
        get { state != .disabled }
        set {
            if newValue {
                guard state == .disabled else { return }
                
                state = .idle
            } else {
                endRefreshing(to: .disabled)
            }
        }
    }
    
    open override var isHidden: Bool {
        didSet {
            guard oldValue != isHidden, isHidden else { return }
            
            endRefreshing()
        }
    }
    
    public func addRefreshClosure(_ refreshClosure: @escaping () -> Void) {
        self.refreshClosure = refreshClosure
        
        guard let scrollView = scrollView else { return }
        
        add(to: scrollView)
    }
    
    public func beginRefreshing() {
        assert(isDescendantOfScrollView, "Please add refresher to UIScrollView before begin refreshing.")
        
        guard shouldRefreshing() else { return }
        
        prepareForRefreshing()
        state = .refreshing
        willBeginRefreshing {
            self.refreshClosure?()
            
            self.delegate?.refresherDidRefresh(self)
        }
    }
    
    public func endRefreshing() {
        endRefreshing(to: .idle)
    }
    
    public func removeFromScrollView() {
        guard let scrollView = superview as? UIScrollView else { return }
        
        scrollViewContentInsetDidReset(scrollView)
        
        removeFromSuperview()
    }
}
