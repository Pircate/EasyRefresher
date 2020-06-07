// 
//  StatefulRefreshComponent.swift
//  EasyRefresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2020/6/7
//  Copyright © 2020 Pircate. All rights reserved.
//

open class StatefulRefreshComponent: RefreshComponent {
    
    internal(set) public override var state: RefreshState {
        didSet {
            guard state != oldValue else { return }
            
            startAnimating(when: state == .refreshing)
            
            impactOccurred(when: state == .willRefresh)

            rotateArrow(for: state)
            
            didChangeStateTitle(for: state)
        }
    }
}

private extension StatefulRefreshComponent {
    
    func startAnimating(when refreshing: Bool) {
        if refreshing {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func impactOccurred(when willRefresh: Bool) {
        guard willRefresh, case let .on(style) = impactFeedbackMode else { return }
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: style)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
    
    func rotateArrow(for state: RefreshState) {
        arrowImageView.isHidden = state == .idle || isRefreshing || !isEnabled
        
        UIView.animate(withDuration: 0.25) {
            self.arrowImageView.transform = self.arrowDirection.reversedTransform(when: state == .willRefresh)
        }
    }
    
    func didChangeStateTitle(for state: RefreshState) {
        if let attributedTitle = attributedTitle(for: state) {
            stateLabel.isHidden = false
            stateLabel.attributedText = attributedTitle
        } else if let title = title(for: state) {
            stateLabel.isHidden = false
            stateLabel.attributedText = nil
            stateLabel.text = title
        } else {
            stateLabel.isHidden = true
        }
    }
}
