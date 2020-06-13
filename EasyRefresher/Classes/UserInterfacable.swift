// 
//  UserInterfacable.swift
//  EasyRefresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/5/9
//  Copyright © 2019 Pircate. All rights reserved.
//

import UIKit

public enum ImpactFeedbackMode {
    case off
    case on(style: UIImpactFeedbackGenerator.FeedbackStyle)
}

public protocol UserInterfacable {
    
    // The height of refresher's view.
    var height: CGFloat { get }
    
    /// The alpha value of refresher's view.
    var alpha: CGFloat { get set }
    
    /// A Boolean value indicating whether the refresher is hidden, default is false.
    var isHidden: Bool { get set }
    
    /// The background color of refresher's view.
    var backgroundColor: UIColor? { get set }
    
    /// A Boolean value indicating whether the refresher automatically change view's alpha value when pulling.
    var automaticallyChangeAlpha: Bool { get set }
    
    /// The basic appearance of the refresher's activity indicator.
    var activityIndicatorStyle: UIActivityIndicatorView.Style { get set }
    
    /// A enum value indicating whether the refresher impact occurred when will refresh.
    var impactFeedbackMode: ImpactFeedbackMode { get set }
}
