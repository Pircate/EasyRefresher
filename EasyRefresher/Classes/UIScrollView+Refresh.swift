// 
//  UIScrollView+Refresh.swift
//  Refresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/4/26
//  Copyright © 2019 Pircate. All rights reserved.
//

import UIKit
import ObjectiveC

extension UIScrollView {
    
    public var header: RefreshHeader {
        get {
            if let obj = objcGetAssociatedObject(for: &AssociatedKeys.header) as? RefreshHeader {
                return obj
            }
            
            let header = RefreshHeader()
            header.scrollView = self
            
            objcSetAssociatedObject(header, for: &AssociatedKeys.header)
            
            return header
        }
        set {
            objcSetAssociatedObject(newValue, for: &AssociatedKeys.header)
            
            newValue.scrollView = self
        }
    }
    
    public var footer: RefreshFooter {
        get {
            if let obj = objcGetAssociatedObject(for: &AssociatedKeys.footer) as? RefreshFooter {
                return obj
            }
            
            let footer = RefreshFooter()
            footer.scrollView = self
            
            objcSetAssociatedObject(footer, for: &AssociatedKeys.footer)
            
            return footer
        }
        set {
            objcSetAssociatedObject(newValue, for: &AssociatedKeys.footer)
            
            newValue.scrollView = self
        }
    }
    
    private func objcGetAssociatedObject(for key: UnsafeRawPointer) -> Any? {
        return objc_getAssociatedObject(self, key)
    }
    
    private func objcSetAssociatedObject(_ value: Any?, for key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

struct AssociatedKeys {
    
    static var header = "com.pircate.github.refresh.header"
    
    static var footer = "com.pircate.github.refresh.footer"
}
