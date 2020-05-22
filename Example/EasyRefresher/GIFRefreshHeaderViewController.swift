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
        
        tableView.refresh.header = RefreshHeader(animationImages: images) {
            self.reqeust {
                self.dataArray = ["", "", "", "", ""]
                self.tableView.refresh.header.endRefreshing()
                self.tableView.reloadData()
            }
        }
        
        tableView.refresh.header.automaticallyChangeAlpha = false
        
        tableView.refresh.header.beginRefreshing()
        
        tableView.refresh.footer.addRefreshClosure {
            self.reqeust {
                self.dataArray.append(contentsOf: ["", "", "", "", ""])
                self.tableView.refresh.footer.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    private func reqeust(completion: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
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

extension RefreshHeader {
    
    convenience init(animationImages: [UIImage], refreshClosure: @escaping () -> Void) {
        self.init(
            stateView: AnimatedStateView(animationImages: animationImages),
            refreshClosure: refreshClosure
        )
    }
}

public class AnimatedStateView: UIView {
    
    private lazy var gifImageView: UIImageView = {
        return UIImageView()
    }()
    
    public init(animationImages: [UIImage]) {
        super.init(frame: .zero)
        
        self.gifImageView.animationImages = animationImages
        
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

extension AnimatedStateView: RefreshStateful {
    
    public func refresher(_ refresher: Refresher, didChangeState state: RefreshState) {
        switch state {
        case .idle:
            gifImageView.isHidden = true
            gifImageView.stopAnimating()
        case .pulling:
            gifImageView.isHidden = false
            gifImageView.stopAnimating()
        case .willRefresh:
            gifImageView.isHidden = false
            gifImageView.stopAnimating()
            gifImageView.image = gifImageView.animationImages?.last
        case .refreshing:
            gifImageView.isHidden = false
            gifImageView.startAnimating()
        case .disabled:
            break
        }
    }
    
    public func refresher(_ refresher: Refresher, didChangeOffset offset: CGFloat) {
        guard let animationImages = gifImageView.animationImages else { return }
        
        let index = Int(offset / refresher.height * CGFloat(animationImages.count) - 1)
        gifImageView.image = animationImages[index]
    }
}
