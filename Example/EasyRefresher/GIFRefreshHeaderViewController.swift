// 
//  GIFRefreshHeaderViewController.swift
//  EasyRefresher_Example
//
//  Created by Pircate(swifter.dev@gmail.com) on 2019/5/13
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import EasyRefresher

class GIFRefreshHeaderViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataArray: [String] = ["", "", "", "", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        
        let images = (1...60).compactMap { UIImage(named: "dropdown_anim__000\($0)") }
        
        tableView.refresh.header = RefreshHeader(stateView: GIFStateView(gifImages: images)) {
            self.reqeust {
                self.tableView.refresh.header.endRefreshing()
            }
        }
        
        tableView.refresh.header.beginRefreshing()
    }
    
    private func reqeust(completion: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

extension GIFRefreshHeaderViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")!
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}


public class GIFStateView: UIView {
    
    private lazy var gifImageView: UIImageView = {
        return UIImageView()
    }()
    
    public init(gifImages: [UIImage]) {
        super.init(frame: .zero)
        
        self.gifImageView.animationImages = gifImages
        
        addSubview(gifImageView)
        
        gifImageView.translatesAutoresizingMaskIntoConstraints = false
        gifImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        gifImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        gifImageView.widthAnchor.constraint(equalToConstant: 54).isActive = true
        gifImageView.heightAnchor.constraint(equalToConstant: 54).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GIFStateView: RefreshStateful {
    
    public func refresher(_ refresher: Refresher, didChangeState state: RefreshState) {
        switch state {
        case .idle:
            gifImageView.isHidden = true
            gifImageView.stopAnimating()
        case .pulling:
            gifImageView.isHidden = false
            gifImageView.stopAnimating()
            gifImageView.image = gifImageView.animationImages?.first
        case .willRefresh:
            gifImageView.isHidden = false
            gifImageView.stopAnimating()
            gifImageView.image = gifImageView.animationImages?.last
        case .refreshing:
            gifImageView.isHidden = false
            gifImageView.startAnimating()
        }
    }
}
