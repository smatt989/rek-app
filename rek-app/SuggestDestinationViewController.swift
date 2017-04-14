//
//  SuggestDestinationViewController.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/2/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class SuggestDestinationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {

    var destination: Destination?
    
    private var emptyNote = true

    @IBOutlet weak var destinationNameLabel: UILabel!
    @IBOutlet weak var suggestionNoteInput: UITextView!
    @IBOutlet weak var searchBoxInput: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func cancelButtonTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTap(_ sender: UIButton) {
        shareWithUsers()
        dismiss(animated: true, completion: nil)
    }
    
    private func setup() {
        if destination != nil {
            DispatchQueue.main.async { [weak weakself = self] in
                weakself?.destinationNameLabel.text = weakself?.destination?.name
            }
        }
    }
    
    private var placeholderText = "Add a note visible only to the people you select..."
    
    private func setupSuggestionNoteInput() {
        suggestionNoteInput.delegate = self
        suggestionNoteInput.text = placeholderText
        suggestionNoteInput.textColor = UIColor.lightGray
        emptyNote = true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if emptyNote {
            textView.text = nil
            textView.textColor = UIColor.black
            emptyNote = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            setupSuggestionNoteInput()
        }
    }
    
    private func shareWithUsers() {
        let shareRequests = toShareWith.map{user in DestinationShareRequest(destinationId: destination!.id!, shareWithUserId: user.id, note: getNote())}
        
        DestinationShareRequest.shareMany(shareRequests, success: {
            
        }, failure: { _ in
            print("DID NOT SHARE")
        })
    }
    
    private func getNote() -> String? {
        let note = suggestionNoteInput.text
        if note == nil || note!.isEmpty || emptyNote {
            return nil
        } else {
            return note
        }
    }
    
    var searching = false
    
    private var toShareWith = [User]()
    
    
    private var addedUsers = [User]() {
        didSet {
            redrawTable()
        }
    }
    
    private func addUserToShare(_ user: User) {
        toShareWith.append(user)
    }
    
    private func removeUserToShare(_ user: User) {
        toShareWith = toShareWith.filter{ $0.id != user.id }
    }
    
    private func loadAddedUsers() {
        User.addedUsers(success: { [weak weakself = self] in
            weakself?.addedUsers = $0
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
            object: searchBoxInput,
            queue: queue) { [weak weakself = self] notification in
                if let query = weakself?.searchBoxInput.text, query.characters.count > 2 {
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
        searchBoxInput.delegate = self
        searchBoxInput.autocorrectionType = UITextAutocorrectionType.no
        searchBoxInput.returnKeyType = .done
    }
    
    private func redrawTable() {
        DispatchQueue.main.async { [weak weakself = self] in
            weakself?.tableView.reloadData()
            weakself?.tableView.setNeedsDisplay()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Identifiers.Cells.userSearchCell, for: indexPath) as! UserSearchTableViewCell
        
        if searching {
            cell.user = searchedUsers[indexPath.row]
        } else {
            cell.user = addedUsers[indexPath.row]
        }
        
        cell.added = addedUsers.contains{
            $0.id == cell.user!.id
        }
        
        cell.toBeShared = toShareWith.contains{
            $0.id == cell.user!.id
        }
        
        cell.setup()
        //cell.isHidden = isHiddenCell(username: cell.user!.username)
        cell.addShareCallback = addUserToShare
        cell.removeShareCallback = removeUserToShare
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searching {
            return searchedUsers.count
        } else {
            return addedUsers.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadAddedUsers()
        listenToSearch()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeningToSearch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setup()
        setupSuggestionNoteInput()
        setupSearchBox()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

}
