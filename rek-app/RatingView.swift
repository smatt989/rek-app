//
//  RatingView.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/17/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class RatingView: UIView {
    
    var rating: Double? {
        didSet {
            setStars()
        }
    }
    
    var onUserTap: ((Double?) -> Void)?
    
    var interactable = true {
        didSet {
            star1.isUserInteractionEnabled = interactable
            star2.isUserInteractionEnabled = interactable
            star3.isUserInteractionEnabled = interactable
            star4.isUserInteractionEnabled = interactable
            star5.isUserInteractionEnabled = interactable
        }
    }
    
    private let star5Threshold = 4.5
    private let star4Threshold = 3.5
    private let star3Threshold = 2.5
    private let star2Threshold = 1.5
    private let star1Threshold = 0.0
    
    private let unselectedImage = #imageLiteral(resourceName: "star-rating-grey")
    private var selectedImage: UIImage {
        get {
            switch rating {
            case _ where rating == nil:
                return unselectedImage
            case _ where rating! > star5Threshold:
                return starRating5
            case _ where rating! > star4Threshold:
                return starRating4
            case _ where rating! > star3Threshold:
                return starRating3
            case _ where rating! > star2Threshold:
                return starRating2
            default:
                return starRating1
            }
        }
    }
    
    private let starRating1 = #imageLiteral(resourceName: "star-rating-1")
    private let starRating2 = #imageLiteral(resourceName: "star-rating-2")
    private let starRating3 = #imageLiteral(resourceName: "star-rating-3")
    private let starRating4 = #imageLiteral(resourceName: "star-rating-4")
    private let starRating5 = #imageLiteral(resourceName: "star-rating-5")

    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!

    @IBAction func star1Tap(_ sender: UIButton) {
        rating = 1
        onUserTap?(rating)
    }

    @IBAction func star2Tap(_ sender: UIButton) {
        rating = 2
        onUserTap?(rating)
    }

    @IBAction func star3Tap(_ sender: UIButton) {
        rating = 3
        onUserTap?(rating)
    }
    
    @IBAction func star4Tap(_ sender: UIButton) {
        rating = 4
        onUserTap?(rating)
    }
    
    @IBAction func star5Tap(_ sender: UIButton) {
        rating = 5
        onUserTap?(rating)
    }
    
    private func unselectStar(_ star: UIButton) {
        star.setImage(unselectedImage, for: .normal)
    }
    
    private func selectStar(_ star: UIButton) {
        star.setImage(selectedImage, for: .normal)
    }
    
    private func resetStars() {
        DispatchQueue.main.async { [weak weakself = self] in
            if weakself != nil {
                weakself!.unselectStar(weakself!.star1)
                weakself!.unselectStar(weakself!.star2)
                weakself!.unselectStar(weakself!.star3)
                weakself!.unselectStar(weakself!.star4)
                weakself?.unselectStar(weakself!.star5)
            }
        }
    }
    
    private func setStars() {
        resetStars()
        DispatchQueue.main.async { [weak weakself = self] in
            if weakself?.rating != nil {
                if weakself!.rating! >= weakself!.star1Threshold {
                    weakself!.selectStar(weakself!.star1)
                }
                if weakself!.rating! > weakself!.star2Threshold {
                    weakself!.selectStar(weakself!.star2)
                }
                if weakself!.rating! > weakself!.star3Threshold {
                    weakself!.selectStar(weakself!.star3)
                }
                if weakself!.rating! > weakself!.star4Threshold {
                    weakself!.selectStar(weakself!.star4)
                }
                if weakself!.rating! > weakself!.star5Threshold {
                    weakself!.selectStar(weakself!.star5)
                }
            }
        }
    }
    
    var contentView : UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        contentView = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        contentView.frame = bounds
        
        // Make the view stretch with containing view
        contentView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(contentView)
        
        star1.imageView?.contentMode = .scaleAspectFit
        star2.imageView?.contentMode = .scaleAspectFit
        star3.imageView?.contentMode = .scaleAspectFit
        star4.imageView?.contentMode = .scaleAspectFit
        star5.imageView?.contentMode = .scaleAspectFit
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
    
}
