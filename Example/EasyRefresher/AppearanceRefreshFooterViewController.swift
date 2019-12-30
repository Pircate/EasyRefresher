// 
//  AppearanceRefreshFooterViewController.swift
//  EasyRefresher_Example
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/5/13
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import EasyRefresher

class AppearanceRefreshFooterViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataArray: [String] = ["", "", "", "", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        
        tableView.refresh.header.addRefreshClosure {
            self.reqeust {
                self.dataArray = ["", "", "", "", ""]
                self.tableView.refresh.footer.isEnabled = true
                self.tableView.refresh.header.endRefreshing()
                self.tableView.reloadData()
            }
        }
        
        tableView.refresh.header.beginRefreshing()
        
        tableView.refresh.footer = AppearanceRefreshFooter {
            self.reqeust {
                self.dataArray.append(contentsOf: ["", "", "", "", ""])
                self.tableView.refresh.footer.isEnabled = false
                self.tableView.reloadData()
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

extension AppearanceRefreshFooterViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")!
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}
