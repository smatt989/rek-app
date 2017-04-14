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
    private var sectionCount = 3
    
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
    
    private func lookupArrayBySection(_ int: Int) -> [RichDestination] {
        switch int {
        case 0: return suggestedDestinations
        case 1: return reviewedDestinations
        case 2: return myDestinations
        default: return [RichDestination]()
        }
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
        setupHiddenHeaders()
        setupLocationFinder()
        setupLocationSearch()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentLocation != nil {
            fetchDestinations(location: CLLocation(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude))
        }
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
    }
    
    private func tapSectionFunction(section: Int) {
        interacted = true
        let indexPaths = (0..<lookupArrayBySection(section).count).map { i in return IndexPath(item: i, section: section)  }
        
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
        var section = 0
        
        while searching && section < sectionCount {
            if lookupArrayBySection(section).count > 0 {
                DispatchQueue.main.async{ [weak weakself = self] in
                    weakself?.tapSectionFunction(section: section)
                }
                searching = false
            } else {
                section = section + 1
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
            return lookupArrayBySection(section).count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return drawTableViewHeader(section: section).contentView
    }
    
    private func drawTableViewHeader(section: Int) -> DestinationSectionTableViewCell {
        let headerView = tableView.dequeueReusableCell(withIdentifier: Identifiers.Cells.destinationSectionCell) as! DestinationSectionTableViewCell
        
        var headerTitle: String?
        
        switch section{
        case 0: headerTitle = "Recommended"
        case 1: headerTitle = "Reviewed"
        case 2: headerTitle = "Your Reviews"
        default: headerTitle = nil
        }
        
        headerView.backgroundColor = UIColor.black
        headerView.section = section
        headerView.mapButton.section = section
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHeaderCallback))
        headerView.contentView.isUserInteractionEnabled = true
        headerView.contentView.addGestureRecognizer(tap)
        headerView.contentView.tag = section
        
        headerView.mapButton.isHidden = lookupArrayBySection(section).count == 0
        
        headerView.headerTitleLabel.text = headerTitle?.uppercased()
        headerView.headerCountLabel.text = "\(lookupArrayBySection(section).count) Destinations"
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerView = tableView.dequeueReusableCell(withIdentifier: Identifiers.Cells.destinationSectionCell) as! DestinationSectionTableViewCell
        
        return CGFloat(headerView.bounds.height)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.Cells.destinationCell, for: indexPath) as! DestinationTableViewCell
        
        let lookupArray = lookupArrayBySection(indexPath.section)
        
        cell.destination = lookupArray[indexPath.row]
        cell.currentLocation = currentLocation
        cell.setup()
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
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
            }
        } else if segue.identifier == Identifiers.Segues.profile {
            if let viewController = segue.destination as? ProfileViewController {
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

