//
//  DestinationDetailViewController.swift
//  rek-app
//
//  Created by Matthew Slotkin on 3/31/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
import MapKit

class DestinationDetailViewController: UIViewController {
    
    var destination: Destination? {
        didSet {
            print("ID = \(destination?.id)")
            if destination?.id == nil {
                loadSavedDestination()
            }
        }
    }
    
    private var like: Bool? {
        didSet {
            resetLikeButtons()
            if like != nil && like! {
                createAndSendReviewRequest(positiveRating: true, note: nil)
                likeButton.tintColor = UIColor.green
            } else if like != nil && !like! {
                createAndSendReviewRequest(positiveRating: false, note: nil)
                dislikeButton.tintColor = UIColor.red
            }
        }
    }

    @IBOutlet weak var destinationName: UILabel!
    @IBOutlet weak var destinationAddress: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    @IBOutlet weak var mapview: MKMapView!
    
    @IBAction func likeButtonTap(_ sender: UIButton) {
        like = true
    }
    
    @IBAction func dislikeButtonTap(_ sender: UIButton) {
        like = false
    }
    
    private func resetLikeButtons() {
        likeButton.tintColor = UIColor.blue
        dislikeButton.tintColor = UIColor.blue
    }
    
    private func createAndSendReviewRequest(positiveRating: Bool, note: String?) {
        if let id = destination?.id {
            let review = ReviewRequest(destinationId: id, positiveRating: positiveRating, note: note)
            ReviewRequest.postReviewRequest(review, success: {_ in print("ok did it")}, failure: { err in print("crap an error: \(err)")})
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
        mapview.region = MKCoordinateRegion(center: destination!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    }
    
    private func loadSavedDestination() {
        if let dest = destination {
            Destination.loadSavedDestination(dest, success: { [weak weakself = self] d in
                weakself?.destination = d
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
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
