//
//  ViewController.swift
//  EasyRefresher
//
//  Created by Pircate on 05/07/2019.
//  Copyright (c) 2019 Pircate. All rights reserved.
//

import UIKit
import EasyRefresher

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dataArray: [String] = [
        "AutoRefreshFooter",
        "AppearanceRefreshFooter",
        "GIFRefreshHeader"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        
        tableView.refresh.header = RefreshHeader(delegate: self)
        
        tableView.refresh.header.automaticallyChangeAlpha = false
        tableView.refresh.header.impactFeedbackMode = .on(style: .medium)
        
        tableView.refresh.footer = RefreshFooter {
            self.reqeust {
                self.tableView.refresh.footer.endRefreshing()
            }
        }
    }
    
    private func reqeust(completion: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

extension ViewController: RefreshDelegate {
    func refresherDidRefresh(_ refresher: Refresher) {
        reqeust {
            self.tableView.refresh.header.endRefreshing()
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")!
        cell.textLabel?.text = dataArray[indexPath.row]
        return cell
    }
}

extension UIViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            navigationController?.pushViewController(
                AutoRefreshFooterViewController(),
                animated: true)
        case 1:
            navigationController?.pushViewController(
                AppearanceRefreshFooterViewController(),
                animated: true)
        case 2:
            navigationController?.pushViewController(
                GIFRefreshHeaderViewController(),
                animated: true)
        default:
            break
        }
    }
}
