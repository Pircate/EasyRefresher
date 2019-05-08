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
    
    var dataArray: [String] = ["", "", "", "", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        
        tableView.refresh.header.addRefresher {
            self.reqeust {
                self.tableView.refresh.header.endRefreshing()
            }
        }

        tableView.refresh.footer = AutoRefreshFooter {
            self.reqeust {
                self.tableView.refresh.footer.endRefreshing()
            }
        }
    }
    
    private func reqeust(completion: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            DispatchQueue.main.async {
                if self.tableView.refresh.header.isRefreshing {
                    self.dataArray = ["", "", "", "", ""]
                } else {
                    (0...10).forEach { _ in self.dataArray.append("") }
                }
                
                self.tableView.reloadData()
                
                completion()
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")!
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}
