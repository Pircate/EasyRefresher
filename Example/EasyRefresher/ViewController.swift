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
                completion()
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "cellID")!
    }
}
