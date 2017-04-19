//
//  ViewController.swift
//  rek-app
//
//  Created by Matthew Slotkin on 3/30/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var interacted = false
    private var sections = [DestinationTableSection]()
    private var sectionCount: Int {
        get {
            return sections.count
        }
    }
    
    private var suggestedDestinations = [RichDestination]()
    private var reviewedDestinations = [RichDestination]()
    private var myDestinations = [RichDestination]() {
        didSet {
            if currentLocation != nil {
                myDestinations.sort(by: {
                    return $0.distanceAway(currentLocation: currentLocation!) < $1.distanceAway(currentLocation: currentLocation!)
                })
            }
        }
    }
    
    private func makeSections() {
        let section1 = DestinationTableSection(name: "Recommended", section: 0, headlineForMissingItems: headlineGenerator(), informationForMissingItems: "No one has sent you any new recommendations", actionTextForMissingItems: nil, actionForMissingItems: nil, itemsArray: { [weak weakself = self] in
            return weakself?.suggestedDestinations ?? [RichDestination]()})
        let section2 = DestinationTableSection(name: "Reviewed", section: 1, headlineForMissingItems: headlineGenerator(), informationForMissingItems: "No reviews available to you at the moment", actionTextForMissingItems: "Tap here to find people to follow", actionForMissingItems: startSearchingUsers, itemsArray: { [weak weakself = self] in
            return weakself?.reviewedDestinations ?? [RichDestination]()})
        let section3 = DestinationTableSection(name: "Your Reviews", section: 2, headlineForMissingItems: headlineGenerator(), informationForMissingItems: "You haven't reviewed anything yet", actionTextForMissingItems: "Tap here to start a review", actionForMissingItems: startSearchingPlaces, itemsArray: { [weak weakself = self] in
            return weakself?.myDestinations ?? [RichDestination]()})
        sections = [section1, section2, section3]
    }
    
    private func lookupArrayBySection(_ int: Int) -> [RichDestination] {
        return sections[int].itemsArray()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var currentLocation: CLLocationCoordinate2D? {
        didSet {
            locationSearchTable?.location = currentLocation
            tableView.reloadData()
        }
    }
    
    var resultSearchController: UISearchController?
    
    var destinations: [RichDestination] = [] {
        didSet {
            suggestedDestinations = [RichDestination]()
            reviewedDestinations = [RichDestination]()
            myDestinations = [RichDestination]()
            
            
            destinations.forEach{ destination in
                switch destination {
                case let a where a.ownReview != nil:
                    myDestinations.append(a)
                case let a where a.inboundRecommendations.count > 0:
                    suggestedDestinations.append(a)
                case let a where a.reviews.count > 0:
                    reviewedDestinations.append(a)
                default: break
                }
            }
            
            
            redrawTable()
        }
    }
    
    var locationFinder: LocationFinder?
    
    var locationSearchTable: LocationSearchTable?
    
    var selectedDestination: Destination?
    
    private func fetchDestinations(location: CLLocation) -> Void {
        RichDestination.fetchDestinations(location: location.coordinate) { [weak weakself = self] dests in
            weakself?.destinations = dests
            if weakself != nil {
                if !weakself!.interacted {
                    weakself?.openMenuOnInit()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        makeSections()
        setupHiddenHeaders()
        //setupLocationFinder()
        setupLocationSearch()
        
        tableView.addSubview(refreshControl)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        print("refreshing???")
        setupLocationFinder()
        refreshControl.endRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("appearing???")
        setupLocationFinder()
    }
    
    private func redrawTable()  {
        DispatchQueue.main.async { [weak weakself = self] in
            weakself?.tableView.reloadData()
            weakself?.tableView.setNeedsDisplay()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupLocationFinder() {
        locationFinder = LocationFinder{ [weak weakself = self] location in
            weakself?.currentLocation = location.coordinate
            weakself?.fetchDestinations(location: location)
        }

        locationFinder?.findLocation()
    }
    
    private func setupLocationSearch() {
        locationSearchTable = storyboard!.instantiateViewController(withIdentifier: Identifiers.ViewControllers.locationSearchTable) as? LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        locationSearchTable?.location = currentLocation
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for restaurants, bars, etc..."
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable?.handleDestinationSelect = {
            [weak weakself = self] placemarker in
            weakself?.selectedDestination = weakself?.mapPlacemarkerToDestination(placemarker)
            weakself?.makeSegue()
        }
    }
    
    func mapPlacemarkerToDestination(_ placemarker: MKPlacemark) -> Destination? {
        if let name = placemarker.name {
            return Destination(name: name, address: placemarker.parseAddress(), latitude: placemarker.coordinate.latitude, longitude: placemarker.coordinate.longitude, id: nil)
        }
        return nil
    }
    
    private var hidden = [Bool]()
    
    @objc private func tapHeaderCallback(sender:UITapGestureRecognizer) {
        let section = sender.view!.tag
        tapSectionFunction(section: section)
        smartAccordionOpen(section: section)
    }
    
    private func smartAccordionOpen(section: Int) {
        let hv = tableView.rectForHeader(inSection: section)
        
        let lastIndex = lookupArrayBySection(section).count - 1
        let maxScrollPoint = 4
        let maxOpenPoint = tableView.frame.height - CGFloat(maxScrollPoint) * tableView.rowHeight
        
        if !hidden[section] && hv.maxY > maxOpenPoint {
            let bottomItem = min(lastIndex, maxScrollPoint)
            var offset = 0
            if lastIndex >= bottomItem {
                offset = 25
            }
            tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + CGFloat(tableView.rowHeight * CGFloat(bottomItem) + CGFloat(offset))) , animated: true)
        }
    }
    
    private func tapSectionFunction(section: Int) {
        interacted = true
        var indexPaths = (0..<lookupArrayBySection(section).count).map { i in return IndexPath(item: i, section: section)  }
        
        if indexPaths.count == 0 {
            indexPaths = [IndexPath(item: 0, section: section)]
        }
        
        hidden[section] = !hidden[section]
        
        tableView?.beginUpdates()
        
        if hidden[section] {
            tableView?.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView?.insertRows(at: indexPaths, with: .fade)
        }
        
        tableView?.endUpdates()
    }
    
    private func openMenuOnInit() {
        var searching = true

        sections.forEach{ [weak weakself = self] section in
            if weakself != nil {
                if searching || weakself!.lookupArrayBySection(section.section).count == 0 {
                    DispatchQueue.main.async{ [weak weakself = self] in
                        if weakself != nil {
                            weakself!.tapSectionFunction(section: section.section)
                        }
                    }
                }
                if weakself!.lookupArrayBySection(section.section).count > 0 && searching {
                    searching = false
                }
            }
        }
    }
    
    private func setupHiddenHeaders() {
        (0..<sectionCount).forEach{ _ in
            hidden.append(true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hidden[section] {
            return 0
        } else {
            let elementsToShow = lookupArrayBySection(section).count
            if elementsToShow > 0 {
                return elementsToShow
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return drawTableViewHeader(section: section).contentView
    }
    
    private func headerTitleBySection(_ section: Int) -> String {
        return sections[section].name
    }
    
    private func drawTableViewHeader(section: Int) -> DestinationSectionTableViewCell {
        let headerView = tableView.dequeueReusableCell(withIdentifier: Identifiers.Cells.destinationSectionCell) as! DestinationSectionTableViewCell
        
        let headerTitle = headerTitleBySection(section)
        
        headerView.backgroundColor = UIColor.black
        headerView.section = section
        headerView.mapButton.section = section
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHeaderCallback))
        headerView.contentView.isUserInteractionEnabled = true
        headerView.contentView.addGestureRecognizer(tap)
        headerView.contentView.tag = section
        
        headerView.mapButton.isHidden = lookupArrayBySection(section).count == 0
        
        headerView.headerTitleLabel.text = headerTitle.uppercased()
        headerView.headerCountLabel.text = "(\(lookupArrayBySection(section).count))"
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerView = tableView.dequeueReusableCell(withIdentifier: Identifiers.Cells.destinationSectionCell) as! DestinationSectionTableViewCell
        
        return CGFloat(headerView.bounds.height)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lookupArray = lookupArrayBySection(indexPath.section)
        
        if lookupArray.count > 0 {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.Cells.destinationCell, for: indexPath) as! DestinationTableViewCell
            
            cell.destination = lookupArray[indexPath.row]
            cell.currentLocation = currentLocation
            cell.setup()
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.Cells.emptyRecommendationsCell, for: indexPath) as! EmptyRecommendationsTableViewCell
            let section = sections[indexPath.section]
            cell.setup(headline: section.headlineForMissingItems, information: section.informationForMissingItems, action: section.actionTextForMissingItems)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if lookupArrayBySection(indexPath.section).count == 0 {
            sections[indexPath.section].actionForMissingItems?()
        }
    }
    
    private func startSearchingPlaces() {
        resultSearchController!.searchBar.becomeFirstResponder()
    }
    
    private func startSearchingUsers() {
        performSegue(withIdentifier: Identifiers.Segues.profile, sender: nil)
    }
    
    private let headlines = [
        "DARN!",
        "RATS!",
        "DANG!",
        "SHUCKS!",
        "POOEY!",
        "@%#*&!",
        "DOH!"
    ]
    
    private func headlineGenerator() -> String {
        let headlineIndex = Int(arc4random_uniform(UInt32(headlines.count)))
        return headlines[headlineIndex]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.destinationDetail {
            if let cell = sender as? DestinationTableViewCell, let viewController = segue.destination as? DestinationDetailViewController {
                viewController.destination = cell.destination?.destination
                viewController.currentLocation = currentLocation
            }
            else if let viewController = segue.destination as? DestinationDetailViewController {
                viewController.destination = selectedDestination
                viewController.currentLocation = currentLocation
            }
        }
        else if segue.identifier == Identifiers.Segues.mapview {
            if let button = sender as? SectionHeaderUIButton, let viewController = segue.destination as? MapViewController {
                viewController.annotations = lookupArrayBySection(button.section)
                viewController.navigationItem.title = headerTitleBySection(button.section)
            }
        } else if segue.identifier == Identifiers.Segues.profile {
            if let viewController = segue.destination as? ProfileViewController {
                viewController.currentLocation = currentLocation
                viewController.reviewCount = myDestinations.count
                viewController.thanksCount = myDestinations.reduce(0) { result, d in
                    result + d.thanksReceived.count
                }
            }
        }
    }
    
    private func makeSegue() {
        performSegue(withIdentifier: Identifiers.Segues.destinationDetail, sender: self)
    }
}

