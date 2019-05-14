// 
//  RefreshComponent.swift
//  EasyRefresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/5/8
//  Copyright © 2019 Pircate. All rights reserved.
//

open class RefreshComponent: UIView {
    
    public var activityIndicatorStyle: UIActivityIndicatorView.Style = .gray {
        didSet { activityIndicator.style = activityIndicatorStyle }
    }
    
    public var stateTitles: [RefreshState : String] = [:]
    
    public var stateAttributedTitles: [RefreshState : NSAttributedString] = [:]
    
    public var state: RefreshState = .idle {
        didSet {
            guard state != oldValue else { return }
            
            stateChanged(state)
            
            switch state {
            case .refreshing:
                activityIndicator.startAnimating()
            default:
                activityIndicator.stopAnimating()
            }
            
            rotateArrow(for: state)
            
            changeStateTitle(for: state)
        }
    }
    
    public var refreshClosure: () -> Void
    
    weak var scrollView: UIScrollView? {
        didSet { scrollView?.alwaysBounceVertical = true }
    }
    
    lazy var originalInset: UIEdgeInsets = {
        guard let scrollView = scrollView else { return .zero }
        
        return scrollView.contentInset
    }()
    
    var arrowDirection: ArrowDirection { return .down }
    
    private var stateChanged: (RefreshState) -> Void = { _ in }
    
    private var contentOffsetObservation: NSKeyValueObservation?
    
    private var contentSizeObservation: NSKeyValueObservation?
    
    private var panStateObservation: NSKeyValueObservation?
    
    private var isEnding: Bool = false
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [activityIndicator, arrowImageView, stateLabel])
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let image = UIImage(named: "refresh_arrow_down", in: Bundle.current, compatibleWith: nil)
        let arrowImageView = UIImageView(image: image)
        arrowImageView.isHidden = true
        return arrowImageView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        UIActivityIndicatorView(style: activityIndicatorStyle)
    }()
    
    private lazy var stateLabel: UILabel = {
        let stateLabel = UILabel()
        stateLabel.font = UIFont.systemFont(ofSize: 14)
        stateLabel.textAlignment = .center
        return stateLabel
    }()
    
    public init(refreshClosure: @escaping () -> Void) {
        self.refreshClosure = refreshClosure
        
        super.init(frame: CGRect.zero)
        
        build()
        prepare()
    }
    
    public override init(frame: CGRect) {
        self.refreshClosure = {}
        
        super.init(frame: frame)
        
        build()
        prepare()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.refreshClosure = {}
        
        super.init(coder: aDecoder)
        
        build()
        prepare()
    }
    
    func add(to scrollView: UIScrollView) {
        guard !scrollView.subviews.contains(self) else { return }
        
        scrollView.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        heightAnchor.constraint(equalToConstant: 54).isActive = true
    }
    
    func observe(_ scrollView: UIScrollView) {
        removeAllObservers()
        
        contentOffsetObservation = scrollView.observe(\.contentOffset) { [weak self] this, _ in
            guard let `self` = self else { return }
            
            this.bringSubviewToFront(self)
            
            guard !self.isRefreshing else { return }
            
            self.scrollViewContentOffsetDidChange(this)
        }
        
        contentSizeObservation = scrollView.observe(\.contentSize) { [weak self] this, _ in
            guard let `self` = self else { return }
            
            self.scrollViewContentSizeDidChange(this)
        }
        
        panStateObservation = scrollView.observe(\.panGestureRecognizer.state) { [weak self] this, _ in
            guard let `self` = self else { return }
            
            self.scrollViewPanStateDidChange(this)
        }
    }
    
    func prepare() {}
    
    func willBeginRefreshing(completion: @escaping () -> Void) {}
    
    func didEndRefreshing(completion: @escaping () -> Void) {}
    
    func scrollViewContentOffsetDidChange(_ scrollView: UIScrollView) {}
    
    func scrollViewContentSizeDidChange(_ scrollView: UIScrollView) {}
    
    func scrollViewPanStateDidChange(_ scrollView: UIScrollView) {
        guard scrollView.panGestureRecognizer.state == .ended, state == .willRefresh else { return }
        
        beginRefreshing()
    }
}

extension RefreshComponent {
    
    var isDescendantOfScrollView: Bool {
        guard let scrollView = scrollView else { return false }
        
        return isDescendant(of: scrollView)
    }
    
    private func build() {
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func prepareForRefreshing() {
        guard let scrollView = scrollView else { return }
        
        var contentInset = scrollView.contentInset
        contentInset.top -= scrollView.changed_inset.top
        contentInset.bottom -= scrollView.changed_inset.bottom
        
        originalInset = contentInset
    }
    
    private func removeAllObservers() {
        contentOffsetObservation?.invalidate()
        contentSizeObservation?.invalidate()
        panStateObservation?.invalidate()
    }
    
    private func rotateArrow(for state: RefreshState) {
        arrowImageView.isHidden = state == .idle || state == .refreshing
        
        let transform: CGAffineTransform
        switch arrowDirection {
        case .up:
            transform = state == .willRefresh ? .identity : CGAffineTransform(rotationAngle: .pi)
        case .down:
            transform = state == .willRefresh ? CGAffineTransform(rotationAngle: .pi) : .identity
        }
        
        UIView.animate(withDuration: 0.25) { self.arrowImageView.transform = transform }
    }
    
    private func changeStateTitle(for state: RefreshState) {
        if let attributedTitle = attributedTitle(for: state) {
            stateLabel.isHidden = false
            stateLabel.attributedText = attributedTitle
        } else if let title = title(for: state) {
            stateLabel.isHidden = false
            stateLabel.text = title
        } else {
            stateLabel.isHidden = true
        }
    }
}

extension RefreshComponent: Refresher {
    
    public func addRefreshClosure(_ refreshClosure: @escaping () -> Void) {
        self.refreshClosure = refreshClosure
        
        guard let scrollView = scrollView else { return }
        
        add(to: scrollView)
        observe(scrollView)
    }
    
    public func beginRefreshing() {
        guard isDescendantOfScrollView else {
            fatalError("Please add refresher to UIScrollView before begin refreshing")
        }
        
        guard !isRefreshing else { return }
        
        prepareForRefreshing()
        state = .refreshing
        willBeginRefreshing { self.refreshClosure() }
    }
    
    public func endRefreshing() {
        guard isDescendantOfScrollView else {
            fatalError("Please add refresher to UIScrollView before end refreshing")
        }
        
        guard isRefreshing, !isEnding else { return }
        
        isEnding = true
        
        state = .idle
        didEndRefreshing { self.isEnding = false }
    }
}

extension RefreshComponent {
    
    public convenience init<T>(
        stateView: T,
        refreshClosure: @escaping () -> Void)
        where T: UIView, T: RefreshStateful
    {
        self.init(refreshClosure: refreshClosure)
        stackView.removeFromSuperview()
        
        addSubview(stateView)
        
        stateView.translatesAutoresizingMaskIntoConstraints = false
        stateView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stateView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stateView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stateView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        stateChanged = { stateView.refresher(self, didChangeState: $0) }
    }
}

extension RefreshComponent {
    
    enum ArrowDirection {
        case up
        case down
    }
}

private extension Bundle {
    
    static var current: Bundle? {
        guard let resourcePath = Bundle(for: RefreshComponent.self).resourcePath,
            let bundle = Bundle(path: "\(resourcePath)/EasyRefresher.bundle") else {
                return nil
        }
        return bundle
    }
}
