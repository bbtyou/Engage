//
//  InboxViewController.swift
//  Engage
//
//  Created by Charles Imperato on 11/21/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit
import wvslib

// - Type alias for view data
typealias InboxMessage = (time: Date, subject: String, body: String, author: String, read: Bool)

class InboxViewController: UIViewController {

    // - MARK: Outlets
    
    @IBOutlet fileprivate var emptyView: UIView!
    @IBOutlet fileprivate var emptyViewLabel: UILabel!
    @IBOutlet fileprivate var emptyViewInstructionLabel: UILabel!
    @IBOutlet fileprivate var emptyViewImageView: UIImageView!
    @IBOutlet fileprivate var inboxTableView: UITableView!

    // - Notifiable
    var notifyContainer: UIView?
    
    // - Presenter for the view
    var presenter: InboxPresenter? {
        didSet {
            self.presenter?.delegate = self
        }
    }
    
    // - Inbox detail presenter
    fileprivate weak var inboxDetailPresenter: InboxDetailPresenter?
    
    // - Inbox messages for display
    fileprivate var messages = [InboxMessage]() {
        didSet {
            self.inboxTableView.reloadData()
        }
    }
    
    // - Pull to refresh
    fileprivate let refresh = UIRefreshControl.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Inbox"

        // - Style the empty view
        self.emptyViewLabel.textColor = self.bodyTextColor
        self.emptyViewInstructionLabel.textColor = self.bodyTextColor
        self.emptyViewImageView.image = UIImage.init(named: "pulldown")?.maskedImage(with: UIColor.lightGray)
        
        // - Set up the refresh control
        self.refresh.attributedTitle = NSAttributedString.init(string: "Pull to refresh", attributes: [NSAttributedString.Key.foregroundColor: themeColor])
        self.refresh.tintColor = self.themeColor
        self.refresh.addTarget(self, action: #selector(refreshInbox), for: .valueChanged)
        self.inboxTableView.addSubview(self.refresh)
        
        // Do any additional setup after loading the view.
        self.presenter?.load()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.notifyContainer?.removeFromSuperview()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "inboxdetail", let detailView = segue.destination as? InboxDetailViewController {
            detailView.presenter = self.inboxDetailPresenter
        }
    }
    
    deinit {
        Current.log().verbose("** Deallocated viewController \(InboxViewController.self).")
    }
    
    // MARK: - Actions
    
    @objc fileprivate func refreshInbox() {
        self.presenter?.load()
    }
}

// MARK: - Themeable

extension InboxViewController: Themeable {}

// MARK: - Waitable

extension InboxViewController: Waitable {}

// MARK: - Notifiable

extension InboxViewController: Notifiable {}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension InboxViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InboxTableViewCell", for: indexPath) as! InboxTableViewCell

        // Update the cell with the message
        cell.message = self.messages[indexPath.row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIDevice.current.sizeClass == .regular ? 150 : 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // - Show message details
        self.presenter?.messageSelected(indexPath.row)
        
        // - Mark the message as read
        self.presenter?.markRead(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteEdit = UITableViewRowAction.init(style: .default, title: "Delete") { (action, indexPath) in
            self.presenter?.delete(indexPath.row)
        }
        
        return [deleteEdit]
    }
}

// MARK: - InboxDelegate

extension InboxViewController: InboxDelegate {
    
    func messagesLoaded(_ messages: [InboxMessage]) {
        // - Hide the Empty contents view
        self.emptyView.isHidden = true
        self.view.sendSubviewToBack(self.emptyView)
        
        // - Refresh the table view
        self.messages = messages
        self.refresh.endRefreshing()
    }
    
    func showEmpty() {
        self.messages = []
        self.refresh.endRefreshing()
        
        // Show empty view
        self.emptyView.isHidden = false
        self.view.bringSubviewToFront(self.emptyView)
    }
    
    func showError(withMessage message: String?) {
        let alert = UIAlertController.init(title: "Inbox Error", message: "There was a problem with the inbox.  \(message ?? "")", preferredStyle: .alert)
        let ok = UIAlertAction.init(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showDetails(_ presenter: InboxDetailPresenter) {
        self.inboxDetailPresenter = presenter
        self.performSegue(withIdentifier: "inboxdetail", sender: self)
    }
}
