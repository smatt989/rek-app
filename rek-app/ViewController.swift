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
    
    @IBOutlet weak var tableView: UITableView!
    
    var currentLocation: CLLocationCoordinate2D? {
        didSet {
            locationSearchTable?.location = currentLocation
        }
    }
    
    var resultSearchController: UISearchController?
    
    var destinations: [String] = []
    
    var locationFinder: LocationFinder?
    
    var locationSearchTable: LocationSearchTable?
    
    var selectedDestination: Destination?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupLocationFinder()
        setupLocationSearch()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupLocationFinder() {
        locationFinder = LocationFinder{ [weak weakself = self] location in
            weakself?.currentLocation = location.coordinate
        }

        locationFinder?.findLocation()
    }
    
    private func setupLocationSearch() {
        print("SETTING UP THIS THING NOW...")
        locationSearchTable = storyboard!.instantiateViewController(withIdentifier: Identifiers.ViewControllers.locationSearchTable) as? LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        locationSearchTable?.location = currentLocation
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
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
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.Cells.destinationCell, for: indexPath) 
        
        cell.textLabel?.text = destinations[indexPath.row]
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.destinationDetail {
            if let viewController = segue.destination as? DestinationDetailViewController {
                viewController.destination = selectedDestination
            }
        }
    }
    
    private func makeSegue() {
        performSegue(withIdentifier: Identifiers.Segues.destinationDetail, sender: self)
    }

}

