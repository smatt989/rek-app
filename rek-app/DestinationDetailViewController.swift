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

    @IBOutlet weak var destinationName: UILabel!
    @IBOutlet weak var destinationAddress: UILabel!
    @IBOutlet weak var reviewView: UIView!
    @IBOutlet weak var reviewRating: RatingView!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var thanksLabel: UILabel!
    
    @IBOutlet weak var ratingButtons: RatingView!
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
    
    @IBOutlet weak var mapview: MKMapView!
    
    private func openInMaps(){
        let coordinate = destination!.coordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = destination?.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    private func createAndSendReviewRequest(rating: Double, note: String?) {
        if let id = destination?.id {
            let review = ReviewRequest(destinationId: id, rating: rating, note: note)
            ReviewRequest.postReviewRequest(review, success: {[weak weakself = self] r in
                weakself?.loadSavedDestination()
            }, failure: { err in print("crap an error: \(err)")})
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        reviewTable.delegate = self
        reviewTable.dataSource = self
        reviewTable.allowsSelection = false
        setupRatingButtons()
    }
    
    private func setupRatingButtons() {
        ratingButtons.onUserTap = { [weak weakself = self] rating in
            let storyboard = UIStoryboard(name: Identifiers.StoryBoards.mainStoryboard, bundle: nil)
            let reviewController = storyboard.instantiateViewController(withIdentifier: Identifiers.ViewControllers.reviewController) as! ReviewViewController
            
            reviewController.reviewText = weakself?.richDestination?.ownReview?.note
            reviewController.makeReviewFunction = weakself?.createAndSendReviewRequest
            reviewController.rating = rating
            weakself?.present(reviewController, animated: true) {
                
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupView() {
        destinationName.text = destination?.name
        destinationAddress.text = destination?.address
        mapview.addAnnotation(destination!)
        mapview.region = MKCoordinateRegion(center: destination!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
        thanksLabel.isHidden = true
    }
    
    private func setupRichView() {
        DispatchQueue.main.async { [weak weakself = self] in
            weakself?.setupRatingView()
            weakself?.ratingButtons.rating = weakself?.richDestination?.ownReview?.rating.map{$0}
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
            
            if weakself?.richDestination?.thanksReceived.count ?? 0 > 0 {
                let thankCount = weakself!.richDestination!.thanksReceived.count
                var people = "people"
                if thankCount == 1 {
                    people = "person"
                }
                weakself?.thanksLabel.text = "\(thankCount) \(people) thanked you!"
                weakself?.thanksLabel.isHidden = false
            }
        }
    }
    
    private func setupRatingView() {
        if richDestination != nil {
            if richDestination!.reviewCount > 0 {
                reviewCountLabel.text = "\(richDestination!.reviewCount) reviews"
                reviewRating.interactable = false
                reviewRating.rating = richDestination?.reviewRating
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
        if suggestionsOnToggle && richDestination?.inboundRecommendations.count ?? 0 == 0 {
            tableView.showBackground(headline: "OH WELL", informationText1: "No recommendations for you here yet", informationText2: nil, instructionsText: nil)
            return 0
        } else if !suggestionsOnToggle && richDestination?.reviews.count ?? 0 == 0 {
            tableView.showBackground(headline: "FIRST!", informationText1: "No one you follow has left any reviews yet.", informationText2: nil, instructionsText: "Tap a rating to give the first review!")
            return 0
        } else {
            tableView.showTable()
            return 1
        }
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
    
    func thankForRecommendation(receiverUserId: Int) {
        let request = ThankRequest(receiverUserId: receiverUserId, destinationId: richDestination!.destination.id!)
        ThankRequest.postThankRequest(request, success: { [weak weakself = self] in
            weakself?.loadSavedDestination()
            }, failure: { error in
                print(error)
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.Cells.reviewCell, for: indexPath) as! ReviewTableViewCell
        
        cell.userNameLabel.textColor = UIColor.black
        cell.thankedLabel.isHidden = true
        cell.thanksButton.isHidden = true
        cell.ratingDisplay.isHidden = true
        if suggestionsOnToggle {
            let recommendation = richDestination!.inboundRecommendations[indexPath.row]
            cell.userNameLabel.text = recommendation.sender.username
            cell.reviewTextView.text = recommendation.note
            if richDestination!.thanksSent.contains(where: {$0.receiverUserId == recommendation.sender.id}) {
                cell.thankedLabel.isHidden = false
            } else {
                cell.thanksButton.isHidden = false
                cell.thanksButtonTap = { [weak weakself = self] in
                    weakself?.thankForRecommendation(receiverUserId: recommendation.sender.id)
                }
            }
        } else {
            let review = richDestination!.reviews[indexPath.row]

            cell.ratingDisplay.interactable = false
            cell.ratingDisplay.rating = review.rating!
            cell.ratingDisplay.isHidden = false
            
            cell.userNameLabel.text = review.user.username
            
            
            cell.reviewTextView.text = review.note
        }
        
        return cell
    }

}
