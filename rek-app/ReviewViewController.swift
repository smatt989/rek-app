//
//  ReviewViewController.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/12/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var reviewText: String? {
        didSet {
            emptyNote = reviewText == nil || reviewText!.isEmpty
        }
    }
    
    var rating: Double?
    
    var makeReviewFunction: ((Double, String?) -> Void)?
    
    @IBOutlet weak var ratingButtons: RatingView!
    @IBOutlet weak var textView: UITextView!

    @IBAction func doneButtonTap(_ sender: UIButton) {
        if rating != nil {
            var note: String?
            if !emptyNote {
                note = textView.text
            }
            makeReviewFunction?(rating!, note)
        }
        dismiss(animated: true, completion: nil)
    }
    
    private var emptyNote = true
    private var placeholderText = "Add a review visible to anyone who follows you..."
    
    private func setupReviewNoteInput() {
        textView.delegate = self
        if emptyNote {
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
        } else {
            textView.text = reviewText
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if emptyNote {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            setupReviewNoteInput()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        reviewText = textView.text
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        setupReviewNoteInput()
        ratingButtons.rating = rating
        ratingButtons.onUserTap = { [weak weakself = self] rating in
            weakself?.rating = rating
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
