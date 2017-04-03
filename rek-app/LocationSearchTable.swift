//
//  LocationSearchTable.swift
//  rek-app
//
//  Created by Matthew Slotkin on 3/31/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTable: UITableViewController {
    var matchingItems: [MKMapItem] = []
    var location: CLLocationCoordinate2D?
    
    var handleDestinationSelect: ((MKPlacemark) -> Void)?
}

extension LocationSearchTable: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
            guard let loc = location,
                let searchBarText = searchController.searchBar.text else { return }
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = searchBarText
            request.region = MKCoordinateRegion(center: loc, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            let search = MKLocalSearch(request: request)
            search.start { response, _ in
                guard let response = response else {
                    return
                }
                self.matchingItems = response.mapItems
                self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.Cells.searchCell)!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = selectedItem.parseAddress()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleDestinationSelect?(selectedItem)
        dismiss(animated: true, completion: nil)
    }
}

extension MKPlacemark {
    func parseAddress() -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (subThoroughfare != nil && thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (subThoroughfare != nil || thoroughfare != nil) && (subAdministrativeArea != nil || administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (subAdministrativeArea != nil && administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            subThoroughfare ?? "",
            firstSpace,
            // street name
            thoroughfare ?? "",
            comma,
            // city
            locality ?? "",
            secondSpace,
            // state
            administrativeArea ?? ""
        )
        return addressLine
    }
}
