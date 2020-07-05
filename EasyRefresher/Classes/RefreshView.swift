// 
//  RefreshView.swift
//  EasyRefresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2020/6/7
//  Copyright © 2020 Pircate. All rights reserved.
//

import UIKit

open class RefreshView: UIView, HasStateTitle, UserInterfacable {
    
    open var activityIndicatorStyle: UIActivityIndicatorView.Style {
        get { activityIndicator.style }
        set { activityIndicator.style = newValue }
    }
    
    open var automaticallyChangeAlpha: Bool = true
    
    open var impactFeedbackMode: ImpactFeedbackMode = .off
    
    public var stateTitles: [RefreshState : String] = [:]
    
    public var stateAttributedTitles: [RefreshState : NSAttributedString] = [:]
    
    var arrowDirection: ArrowDirection { .down }
    
    lazy var stackView: UIStackView = { buildStackView() }()
    
    lazy var arrowImageView: UIImageView = {
        let image = UIImage(named: "refresh_arrow_down", in: .current, compatibleWith: nil)
        let arrowImageView = UIImageView(image: image)
        arrowImageView.isHidden = true
        arrowImageView.transform = arrowDirection.reversedTransform(when: false)
        return arrowImageView
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView(style: .medium)
        } else {
            return UIActivityIndicatorView(style: .gray)
        }
    }()
    
    lazy var stateLabel: UILabel = {
        let stateLabel = UILabel()
        stateLabel.font = UIFont.systemFont(ofSize: 14)
        stateLabel.textAlignment = .center
        return stateLabel
    }()
    
    public let height: CGFloat
    
    public init(height: CGFloat) {
        self.height = height
        
        super.init(frame: .zero)
        
        layoutStackView()
    }
    
    public init(empty height: CGFloat) {
        self.height = height
        
        super.init(frame: .zero)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.height = 54
        
        super.init(coder: aDecoder)
        
        layoutStackView()
    }
    
    func buildStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [activityIndicator, arrowImageView, stateLabel])
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }
    
    private func layoutStackView() {
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}

extension RefreshView {
    
    enum ArrowDirection {
        case up
        case down
    }
}

extension RefreshView.ArrowDirection {
    
    func reversedTransform(when willRefresh: Bool) -> CGAffineTransform {
        switch self {
        case .up:
            return willRefresh ? .identity : CGAffineTransform(rotationAngle: .pi)
        case .down:
            return willRefresh ? CGAffineTransform(rotationAngle: .pi) : .identity
        }
    }
}
