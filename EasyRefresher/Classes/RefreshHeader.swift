// 
//  RefreshHeader.swift
//  EasyRefresher
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/4/26
//  Copyright © 2019 Pircate. All rights reserved.
//

import UIKit

public enum LastUpdatedTimeStrategy {
    case none
    case `default`
    case custom((Date?) -> String)
}

public protocol HeaderRefresher: Refresher {
    
    /// The text of time when refresher last updated.
    var lastUpdatedTimeStrategy: LastUpdatedTimeStrategy { get set }
}

open class RefreshHeader: RefreshComponent, HeaderRefresher {
    
    public var lastUpdatedTimeStrategy: LastUpdatedTimeStrategy = .default
    
    private lazy var lastUpdatedLabel: UILabel = {
        let lastUpdatedLabel = UILabel()
        lastUpdatedLabel.font = UIFont.systemFont(ofSize: 12)
        lastUpdatedLabel.textAlignment = .center
        lastUpdatedLabel.textColor = .darkGray
        return lastUpdatedLabel
    }()
    
    private let lastUpdatedTimekey = "com.pircate.github.lastUpdatedTime"
    
    private var lastUpdatedTime: Date? {
        get { UserDefaults.standard.object(forKey: lastUpdatedTimekey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: lastUpdatedTimekey) }
    }
    
    override func buildStackView() -> UIStackView {
        let vStackView = UIStackView(arrangedSubviews: [stateLabel, lastUpdatedLabel])
        vStackView.axis = .vertical
        vStackView.spacing = 5
        vStackView.alignment = .center
        
        let hStackView = UIStackView(arrangedSubviews: [activityIndicator, arrowImageView, vStackView])
        hStackView.spacing = 8
        hStackView.alignment = .center
        return hStackView
    }
    
    override func add(to scrollView: UIScrollView) {
        super.add(to: scrollView)
        
        bottomAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
    }
    
    override func prepare() {
        super.prepare()
        
        alpha = 0
        setTitle("pull_down_to_refresh".localized(), for: .pulling)
        setTitle("release_to_refresh".localized(), for: .willRefresh)
    }
    
    override func stateDidChange(_ state: RefreshState) {
        super.stateDidChange(state)
        
        updateLastUpdatedTime(for: state)
    }
    
    override func willBeginRefreshing(completion: @escaping () -> Void) {
        guard let scrollView = scrollView else { return }
        
        alpha = 1
        
        UIView.animate(withDuration: 0.25, animations: {
            scrollView.contentInset.top = self.originalInset.top + self.height
            scrollView.changed_inset.top = self.height
        }, completion: { _ in completion() })
    }
    
    override func didEndRefreshing(completion: @escaping () -> Void) {
        guard let scrollView = scrollView else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            scrollView.contentInset.top -= scrollView.changed_inset.top
            scrollView.changed_inset.top = 0
        }, completion: { _ in
            self.lastUpdatedTime = Date()
            completion()
        })
    }
    
    override func scrollViewContentInsetDidReset(_ scrollView: UIScrollView) {
        scrollView.contentInset.top -= scrollView.changed_inset.top
        scrollView.changed_inset.top = 0
    }
    
    override func scrollViewContentOffsetDidChange(_ scrollView: UIScrollView) {
        guard !isHidden else { return }
        
        let offset = scrollView.contentOffset.y + scrollView.refreshInset.top
        
        offsetDidChange(offset)
        
        didChangeAlpha(by: offset)
        
        guard isEnabled else { return }
        
        didChangeState(by: offset)
    }
    
    private func updateLastUpdatedTime(for state: RefreshState) {
        guard state != .idle, state != .disabled else {
            lastUpdatedLabel.isHidden = true
            return
        }
        
        switch lastUpdatedTimeStrategy {
        case .none:
            lastUpdatedLabel.isHidden = true
        case .default:
            lastUpdatedLabel.isHidden = false
            guard let lastUpdatedTime = lastUpdatedTime else {
                lastUpdatedLabel.text = "\("last_update_time".localized())\("no_record".localized())"
                return
            }
            
            lastUpdatedLabel.text = "\("last_update_time".localized())\(lastUpdatedTime.lastUpdatedTimeString)"
        case .custom(let closure):
            lastUpdatedLabel.isHidden = false
            lastUpdatedLabel.text = closure(lastUpdatedTime)
        }
    }
}

private extension Date {
    
    var lastUpdatedTimeString: String {
        let isToday = Calendar.refresh.isDateInToday(self)
        DateFormatter.refresh.dateFormat = isToday ? "HH:mm" : "yyyy-MM-dd HH:mm"
        
        let dateString = DateFormatter.refresh.string(from: self)
        return isToday ? "\("today".localized()) \(dateString)" : dateString
    }
}

private extension DateFormatter {
    
    static let refresh: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }()
}

private extension Calendar {
    
    static let refresh: Calendar = { Calendar(identifier: .gregorian) }()
}
