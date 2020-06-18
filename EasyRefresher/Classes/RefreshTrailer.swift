// 
//  RefreshTrailer.swift
//  EasyRefresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2020/6/14
//  Copyright © 2020 Pircate. All rights reserved.
//

import UIKit

public protocol TrailerRefresher: Refresher {}

open class RefreshTrailer: RefreshComponent, TrailerRefresher {
    
    override var scrollView: UIScrollView? {
        didSet { scrollView?.alwaysBounceHorizontal = true }
    }
    
    private lazy var constraintOfLeftAnchor: NSLayoutConstraint? = {
        guard let scrollView = scrollView, isDescendant(of: scrollView) else { return nil }
        
        let constraint = leftAnchor.constraint(equalTo: scrollView.leftAnchor)
        constraint.isActive = true
        
        return constraint
    }()
    
    open override func updateConstraints() {
        super.updateConstraints()
        
        guard let scrollView = scrollView else { return }
        
        constraintOfLeftAnchor?.constant = scrollView.contentSize.width
    }
    
    override func buildStackView() -> UIStackView {
        let stackView = super.buildStackView()
        stackView.transform = .init(rotationAngle: -.pi / 2)
        return stackView
    }
    
    override func prepare() {
        super.prepare()
        
        alpha = 0
        setTitle("pull_left_to_refresh".localized(), for: .pulling)
        setTitle("release_to_load_more".localized(), for: .willRefresh)
    }
    
    override func add(to scrollView: UIScrollView) {
        guard !scrollView.subviews.contains(self) else { return }
        
        scrollView.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    override func willBeginRefreshing(completion: @escaping () -> Void) {
        guard let scrollView = scrollView else { return }
        
        alpha = 1
        
        UIView.animate(withDuration: 0.25, animations: {
            scrollView.contentInset.right = self.originalInset.right + self.height
            scrollView.changed_inset.right = self.height
        }, completion: { _ in completion() })
    }
    
    override func didEndRefreshing(completion: @escaping () -> Void) {
        guard let scrollView = scrollView else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            scrollView.contentInset.right -= scrollView.changed_inset.right
            scrollView.changed_inset.right = 0
        }, completion: { _ in completion() })
    }
    
    override func scrollViewContentInsetDidReset(_ scrollView: UIScrollView) {
        scrollView.contentInset.right -= scrollView.changed_inset.right
        scrollView.changed_inset.right = 0
    }
    
    override func scrollViewContentOffsetDidChange(_ scrollView: UIScrollView) {
        guard !isHidden else { return }
        
        let offset: CGFloat
        
        if scrollView.refreshInset.left + scrollView.contentSize.width >= scrollView.bounds.width {
            offset = scrollView.contentOffset.x
                + scrollView.bounds.width
                - scrollView.contentSize.width
                - scrollView.refreshInset.right
        } else {
            offset = scrollView.contentOffset.x + scrollView.refreshInset.left
        }
        
        offsetDidChange(-offset)
        
        didChangeAlpha(by: -offset)
        
        guard isEnabled else { return }
        
        didChangeState(by: -offset)
    }
    
    override func scrollViewContentSizeDidChange(_ scrollView: UIScrollView) {
        super.scrollViewContentSizeDidChange(scrollView)
        
        setNeedsUpdateConstraints()
    }
}
