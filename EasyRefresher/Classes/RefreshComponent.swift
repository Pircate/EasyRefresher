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
            
            switch state {
            case .refreshing:
                activityIndicator.startAnimating()
            default:
                activityIndicator.stopAnimating()
            }
            
            rotateArrow(for: state)
            
            if let attributedTitle = attributedTitle(for: state) {
                stateLabel.attributedText = attributedTitle
            } else {
                stateLabel.text = title(for: state)
            }
            
            stateLabel.sizeToFit()
        }
    }
    
    public var refreshClosure: () -> Void = {}
    
    weak var scrollView: UIScrollView? {
        didSet {
            scrollView?.alwaysBounceVertical = true
        }
    }
    
    var idleInset: UIEdgeInsets = .zero
    
    var arrowDirection: ArrowDirection { return .down }
    
    private var isEnding: Bool = false
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [activityIndicator, arrowImageView, stateLabel])
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let image = UIImage(named: "refresh_arrow_down", in: Bundle.current, compatibleWith: nil)
        return UIImageView(image: image)
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
    
    public required init(refreshClosure: @escaping () -> Void) {
        self.refreshClosure = refreshClosure
        
        super.init(frame: CGRect.zero)
        
        build()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        build()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        build()
    }
    
    func willBeginRefreshing(completion: @escaping () -> Void) {}
    
    func willEndRefreshing() {}
    
    func add(into scrollView: UIScrollView) {
        guard !scrollView.subviews.contains(self) else { return }
        
        scrollView.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        heightAnchor.constraint(equalToConstant: 54).isActive = true
    }
    
    func observe(_ scrollView: UIScrollView) {}
}

extension RefreshComponent {
    
    private func build() {
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func prepare() {
        guard let scrollView = scrollView else { return }
        
        var contentInset = scrollView.contentInset
        contentInset.top -= scrollView.changed_inset.top
        contentInset.bottom -= scrollView.changed_inset.bottom
        
        idleInset = contentInset
    }
    
    private func didEndRefreshing(completion: @escaping () -> Void) {
        guard let scrollView = scrollView else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            scrollView.contentInset.top = self.idleInset.top + scrollView.changed_inset.top
            scrollView.contentInset.bottom = self.idleInset.bottom + scrollView.changed_inset.bottom
        }, completion: { _ in
            self.isEnding = false
            completion()
        })
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
}

extension RefreshComponent: Refresher {
    
    public func addRefreshClosure(_ refreshClosure: @escaping () -> Void) {
        self.refreshClosure = refreshClosure
        
        guard let scrollView = scrollView else { return }
        
        add(into: scrollView)
        observe(scrollView)
    }
    
    public func beginRefreshing() {
        guard !isRefreshing else { return }
        
        prepare()
        state = .refreshing
        willBeginRefreshing { self.refreshClosure() }
    }
    
    public func endRefreshing() {
        guard isRefreshing, !isEnding else { return }
        
        isEnding = true
        
        willEndRefreshing()
        state = .idle
        didEndRefreshing {}
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
