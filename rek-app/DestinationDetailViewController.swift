//
//  DestinationDetailViewController.swift
//  rek-app
//
//  Created by Matthew Slotkin on 3/31/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DestinationDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var richDestination: RichDestination? {
        didSet {
            setupRichView()
        }
    }
    
    var destination: Destination? {
        didSet {
            if destination?.id == nil || richDestination == nil {
                loadSavedDestination()
            }
        }
    }
    
    var currentLocation: CLLocationCoordinate2D?
    
    private var like: Bool? {
        didSet {
            resetLikeButtons()
            if like != nil && like! {
                //createAndSendReviewRequest(positiveRating: true, note: nil)
                likeButton.tintColor = UIColor.green
                dislikeButton.tintColor = UIColor.lightGray
            } else if like != nil && !like! {
                //createAndSendReviewRequest(positiveRating: false, note: nil)
                dislikeButton.tintColor = UIColor.red
                likeButton.tintColor = UIColor.lightGray
            }
        }
    }

    @IBOutlet weak var destinationName: UILabel!
    @IBOutlet weak var destinationAddress: UILabel!
    @IBOutlet weak var reviewView: UIView!
    @IBOutlet weak var reviewRatingLabel: UILabel!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var reviewTable: UITableView!
    
    @IBOutlet weak var reviewTableToggle: UISegmentedControl!
    
    @IBAction func mapButtonTap(_ sender: UIButton) {
        openInMaps()
    }
    
    var suggestionsOnToggle = true {
        didSet {
            redrawTable()
        }
    }
    
    @IBAction func reviewTypeToggle(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: suggestionsOnToggle = true
        case 1: suggestionsOnToggle = false
        default: break
        }
    }
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    @IBOutlet weak var mapview: MKMapView!
    
    @IBAction func likeButtonTap(_ sender: UIButton) {
        like = true
    }
    
    @IBAction func dislikeButtonTap(_ sender: UIButton) {
        like = false
        performSegue(withIdentifier: Identifiers.Segues.positiveReviewPopover, sender: self)
    }
    
    private func resetLikeButtons() {
        likeButton.tintColor = UIColor.blue
        dislikeButton.tintColor = UIColor.blue
    }
    
    private func openInMaps(){
        let coordinate = destination!.coordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = destination?.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    private func createAndSendReviewRequest(positiveRating: Bool, note: String?) {
        if let id = destination?.id {
            let review = ReviewRequest(destinationId: id, positiveRating: positiveRating, note: note)
            ReviewRequest.postReviewRequest(review, success: {[weak weakself = self] r in
                weakself?.richDestination?.ownReview = r
                weakself?.setupRichView()
            }, failure: { err in print("crap an error: \(err)")})
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        reviewTable.delegate = self
        reviewTable.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupView() {
        destinationName.text = destination?.name
        destinationAddress.text = destination?.address
        mapview.addAnnotation(destination!)
        mapview.region = MKCoordinateRegion(center: destination!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    }
    
    private func setupRichView() {
        DispatchQueue.main.async { [weak weakself = self] in
            weakself?.setupRatingView()
            weakself?.like = weakself?.richDestination?.ownReview?.positiveRating
            weakself?.setupDistanceLabel()
            weakself?.redrawTable()
            weakself?.reviewTableToggle.setTitle("Recommendations (\(weakself!.richDestination!.inboundRecommendations.count))", forSegmentAt: 0)
            weakself?.reviewTableToggle.setTitle("Reviews (\(weakself!.richDestination!.reviews.count))", forSegmentAt: 1)
            var toSelect = 0
            if weakself?.richDestination?.inboundRecommendations.count ?? 0 > 0 {
                toSelect = 0
                weakself?.suggestionsOnToggle = true
            } else {
                toSelect = 1
                weakself?.suggestionsOnToggle = false
            }
            weakself?.reviewTableToggle.selectedSegmentIndex = toSelect
        }
    }
    
    private func setupRatingView() {
        if richDestination != nil {
            if richDestination!.reviewCount > 0 {
                reviewCountLabel.text = "\(richDestination!.reviewCount) reviews"
                reviewRatingLabel.text = "\(Int(richDestination!.reviewRating! * 100))%"
                reviewView.isHidden = false
            } else {
                reviewView.isHidden = true
            }
        }
    }
    
    private func setupDistanceLabel() {
        if richDestination != nil {
            if currentLocation != nil {
                distanceLabel.text = DestinationUtilities.distanceToString(distance: richDestination!.distanceAway(currentLocation: currentLocation!))
                distanceLabel.isHidden = false
            } else {
                distanceLabel.isHidden = true
            }
        }
    }
    
    private func loadSavedDestination() {
        if let dest = destination {
            Destination.loadSavedDestination(dest, success: { [weak weakself = self] d in
                weakself?.richDestination = d
                weakself?.destination = d.destination
                }, failure: { err in
                    print("BIG ERROR: \(err.localizedDescription)")
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.suggestDestination {
            if let viewController = segue.destination as? SuggestDestinationViewController {
                viewController.destination = destination
            }
        } else if segue.identifier == Identifiers.Segues.positiveReviewPopover {
            if let viewController = segue.destination as? ReviewViewController {
                viewController.like = like
                viewController.reviewText = richDestination?.ownReview?.note
                viewController.makeReviewFunction = createAndSendReviewRequest
            }
        } else if segue.identifier == Identifiers.Segues.detailsToMap {
            if let viewController = segue.destination as? MapViewController {
                viewController.annotations = [richDestination!]
                viewController.selectedDestination = richDestination
            }
        }
    }
    
    private func redrawTable()  {
        DispatchQueue.main.async { [weak weakself = self] in
            weakself?.reviewTable.reloadData()
            weakself?.reviewTable.setNeedsDisplay()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if richDestination != nil {
            if suggestionsOnToggle {
                return richDestination!.inboundRecommendations.count
            } else {
                return richDestination!.reviewCount
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.Cells.reviewCell, for: indexPath) as! ReviewTableViewCell
        
        cell.userNameLabel.textColor = UIColor.black
        if suggestionsOnToggle {
            let recommendation = richDestination!.inboundRecommendations[indexPath.row]
            cell.userNameLabel.text = recommendation.sender.username
            cell.reviewTextView.text = recommendation.note
        } else {
            let review = richDestination!.reviews[indexPath.row]
            var likeText = ""
            if review.positiveRating != nil && review.positiveRating! {
                likeText = "(like)"
                cell.userNameLabel.textColor = UIColor.green
            }
            if review.positiveRating != nil && !review.positiveRating! {
                likeText = "(dislike)"
                cell.userNameLabel.textColor = UIColor.red
            }
            cell.userNameLabel.text = "\(review.user.username) \(likeText)"
            
            
            cell.reviewTextView.text = review.note
        }
        
        return cell
    }

}
