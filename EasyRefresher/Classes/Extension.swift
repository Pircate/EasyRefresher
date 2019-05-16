// 
//  Extension.swift
//  EasyRefresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/5/16
//  Copyright © 2019 Pircate. All rights reserved.
//

extension Bundle {
    
    static var current: Bundle? {
        guard let resourcePath = Bundle(for: RefreshComponent.self).resourcePath,
            let bundle = Bundle(path: "\(resourcePath)/EasyRefresher.bundle") else {
                return nil
        }
        return bundle
    }
}

extension String {
    
    func localized(value: String? = nil, table: String = "EasyRefresher") -> String {
        return Bundle.current?.localizedString(forKey: self, value: value, table: table) ?? self
    }
}
