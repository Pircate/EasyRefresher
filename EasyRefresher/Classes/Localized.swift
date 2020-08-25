// 
//  Localized.swift
//  EasyRefresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/5/16
//  Copyright © 2019 Pircate. All rights reserved.
//

import Foundation

extension String {
    
    func localized(
        _ language: Language = .current,
        value: String? = nil,
        table: String = "Localizable"
    ) -> String {
        guard let path = Bundle.current?.path(forResource: language.rawValue, ofType: "lproj") else {
            return self
        }
        
        return Bundle(path: path)?.localizedString(forKey: self, value: value, table: table) ?? self
    }
}

public enum Language: String {
    case en
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"
    
    public static var current: Language = {
        guard let language = Locale.preferredLanguages.first else { return .en }
        
        if language.contains("zh-HK") { return .zhHant }
        
        if language.contains("zh-Hans") { return .zhHans }
        
        return Language(rawValue: language) ?? .en
    }()
}

extension Bundle {
    
    static let current: Bundle? = {
        guard let resourcePath = Bundle(for: RefreshComponent.self).resourcePath else { return nil }
        
        return Bundle(path: "\(resourcePath)/EasyRefresher.bundle")
    }()
}
