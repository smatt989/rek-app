//
//  ProfileViewController.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/12/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
import CoreLocation

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var currentLocation: CLLocationCoordinate2D?
    
    var reviewCount = 0
    var thanksCount = 0
    
    private func setup() {
        usernameLabel.text = appDelegate.authentication.currentUser?.username
        reviewCountLabel.text = String(reviewCount)
        kudosCountLabel.text = String(thanksCount)
    }
    
    private var searching = false {
        didSet {
            if !searching {
                loadUsers()
            }
        }
    }
    
    private var restingTableUsers = [User]() {
        didSet {
            redrawTable()
        }
    }
    
    private var addedUsers = [User]() {
        didSet {
            restingTableUsers = suggestedUsers + addedUsers
        }
    }
    
    private var suggestedUsers = [User]() {
        didSet {
            restingTableUsers = suggestedUsers + addedUsers
        }
    }
    
    private func loadAddedUsers() {
        User.addedUsers(success: { [weak weakself = self] in
            weakself?.addedUsers = $0
            }, failure: {
                print($0)
        }
        )
    }
    
    private func loadSuggestedUsers() {
        User.suggestedUsers(success: { [weak weakself = self] in
            weakself?.suggestedUsers = $0
            }, failure: {
                print($0)
        }
        )
    }
    
    private var searchedUsers = [User](){
        didSet {
            //hack to get people you know on the top
            var ordered = [User]()
            var knownUsersIndex = 0
            searchedUsers.forEach{ user in
                if addedUsers.contains(where: { $0.id == user.id}) {
                    ordered.insert(user, at: knownUsersIndex)
                    knownUsersIndex += 1
                } else {
                    ordered.append(user)
                }
            }
            
            searchedUsers = ordered
            redrawTable()
        }
    }
    
    private var searchBarListener: NSObjectProtocol?
    
    private func listenToSearch() {
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        
        searchBarListener = center.addObserver(
            forName: Notification.Name.UITextFieldTextDidChange,
            object: searchUsersBox,
            queue: queue) { [weak weakself = self] notification in
                if let query = weakself?.searchUsersBox.text, query.characters.count > 2 {
                    weakself?.searching = true
                    User.search(query: query, success: {
                        weakself?.searchedUsers = $0
                    }, failure: { _ in
                        print("DIDN'T GET SEARCH")
                    })
                } else {
                    weakself?.searching = false
                    weakself?.redrawTable()
                }
        }
    }
    
    private func stopListeningToSearch() {
        if let observer = searchBarListener {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func setupSearchBox() {
        searchUsersBox.delegate = self
        searchUsersBox.autocorrectionType = UITextAutocorrectionType.no
        searchUsersBox.returnKeyType = .done
    }
    
    private func redrawTable() {
        DispatchQueue.main.async { [weak weakself = self] in
            weakself?.tableView.reloadData()
            weakself?.tableView.setNeedsDisplay()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Identifiers.Cells.followUnfollowTableCell, for: indexPath) as! FollowUnfollowTableViewCell
        
        if searching {
            cell.user = searchedUsers[indexPath.row]
        } else {
            cell.user = restingTableUsers[indexPath.row]
        }
        
        cell.following = addedUsers.contains{
            $0.id == cell.user!.id
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedUsers.count
        } else {
            return restingTableUsers.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !searching && restingTableUsers.count == 0{
            tableView.showBackground(headline: "SO CLOSE!", informationText1: "You're not following anyone yet.", informationText2: nil, instructionsText: "Start searching in the searchbox above!")
            return 0
        } else {
            tableView.showTable()
            return 1
        }
    }
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var kudosCountLabel: UILabel!
    
    @IBOutlet weak var searchUsersBox: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func logoutButtonTap(_ sender: UIBarButtonItem) {
        User.logout{ [weak weakself = self] in
            weakself?.appDelegate.routeGivenAuthentication()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupSearchBox()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
        loadUsers()
    }
    
    private func loadUsers() {
        loadAddedUsers()
        loadSuggestedUsers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listenToSearch()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeningToSearch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.userPlaces {
            if let viewController = segue.destination as? MapViewController, let cell = sender as? FollowUnfollowTableViewCell {
                RichDestination.fetchReviewerDestinations(reviewerId: cell.user!.id, location: currentLocation!) { dests in
                    viewController.annotations = dests
                    viewController.specificUserReviews = cell.user
                    viewController.navigationItem.title = cell.user?.username
                }
            }
        }
    }

}
