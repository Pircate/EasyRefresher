// 
//  UIScrollView+Refresh.swift
//  EasyRefresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/4/26
//  Copyright © 2019 Pircate. All rights reserved.
//

import UIKit
import ObjectiveC

public typealias Refresher = Refreshable & HasStateTitle & UserInterfacable

public protocol HeaderRefresher: Refresher {
    
    /// The text of time when refresher last updated.
    var lastUpdatedTimeText: ((Date?) -> String?)? { get set }
}

public protocol FooterRefresher: Refresher {}

extension UIScrollView {
    
    var refresh_header: HeaderRefresher {
        get {
            if let obj = objcGetAssociatedObject(for: &AssociatedKeys.header) as? HeaderRefresher {
                return obj
            }
            
            let header = RefreshHeader()
            header.scrollView = self
            
            objcSetAssociatedObject(header, for: &AssociatedKeys.header)
            
            return header
        }
        set {
            if let obj = objcGetAssociatedObject(for: &AssociatedKeys.header) as? RefreshHeader {
                // 结构的属性调用 set 方法也会触发结构体自身的 set 方法，若 newValue 是自身则不重复赋值,
                // 否则需要移除掉旧的 refresher。
                if obj === newValue { return }
                
                obj.removeFromScrollView()
            }
            
            objcSetAssociatedObject(newValue, for: &AssociatedKeys.header)
            
            guard let header = newValue as? RefreshHeader else {
                fatalError("Please use RefreshHeader or it's subclass.")
            }
            
            header.scrollView = self
            header.add(to: self)
        }
    }
    
    var refresh_footer: FooterRefresher {
        get {
            if let obj = objcGetAssociatedObject(for: &AssociatedKeys.footer) as? FooterRefresher {
                return obj
            }
            
            let footer = RefreshFooter()
            footer.scrollView = self
            
            objcSetAssociatedObject(footer, for: &AssociatedKeys.footer)
            
            return footer
        }
        set {
            if let obj = objcGetAssociatedObject(for: &AssociatedKeys.footer) as? RefreshFooter {
                if obj === newValue { return }
                
                obj.removeFromScrollView()
            }
            
            objcSetAssociatedObject(newValue, for: &AssociatedKeys.footer)
            
            guard let footer = newValue as? RefreshFooter else {
                fatalError("Please use RefreshFooter or it's subclass.")
            }
            
            footer.scrollView = self
            footer.add(to: self)
        }
    }
    
    var changed_inset: UIEdgeInsets {
        get {
            if let obj = objcGetAssociatedObject(for: &AssociatedKeys.changedInset) as? UIEdgeInsets {
                return obj
            }
            
            objcSetAssociatedObject(UIEdgeInsets.zero, for: &AssociatedKeys.changedInset)
            
            return .zero
        }
        set {
            objcSetAssociatedObject(newValue, for: &AssociatedKeys.changedInset)
        }
    }
}

private extension UIScrollView {
    
    func objcGetAssociatedObject(for key: UnsafeRawPointer) -> Any? {
        return objc_getAssociatedObject(self, key)
    }
    
    func objcSetAssociatedObject(_ value: Any?, for key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

struct AssociatedKeys {
    
    static var header = "com.pircate.github.refresh.header"
    
    static var footer = "com.pircate.github.refresh.footer"
    
    static var changedInset = "com.pircate.github.changed.inset"
}

extension UIScrollView {
    
    var refreshInset: UIEdgeInsets {
        guard #available(iOS 11.0, *) else {
            return contentInset
        }
        
        return adjustedContentInset
    }
}
