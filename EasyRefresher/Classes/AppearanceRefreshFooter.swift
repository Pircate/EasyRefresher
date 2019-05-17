// 
//  AppearanceRefreshFooter.swift
//  EasyRefresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/5/11
//  Copyright © 2019 Pircate. All rights reserved.
//

open class AppearanceRefreshFooter: RefreshFooter {
    
    public override var automaticallyChangeAlpha: Bool {
        get { return false }
        set {}
    }
    
    public override var state: RefreshState {
        get { return super.state }
        set {
            guard newValue == .idle else {
                super.state = newValue
                return
            }
            
            super.state = .pulling
        }
    }
    
    override func prepare() {
        super.prepare()
        
        alpha = 1
        addTapGestureRecognizer()
        setTitle("tap_or_pull_up_to_load_more".localized(), for: .pulling)
    }
    
    override func didEndRefreshing(completion: @escaping () -> Void) { completion() }
    
    override func changeState(by offset: CGFloat) {
        switch -offset {
        case ..<(-54):
            state = .willRefresh
        default:
            state = .pulling
        }
    }
}

extension AppearanceRefreshFooter {
    
    private func addTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(tapGestureAction(sender:)))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
        beginRefreshing()
    }
}
