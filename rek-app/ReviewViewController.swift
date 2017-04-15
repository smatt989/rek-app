//
//  ReviewViewController.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/12/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var like: Bool?{
        didSet {
            DispatchQueue.main.async { [weak weakself = self] in
                weakself?.resetLikeButtons()
                if weakself?.like != nil && weakself!.like! {
                    weakself?.likeButton.tintColor = UIColor.green
                    weakself?.dislikeButton.tintColor = UIColor.lightGray
                } else if weakself?.like != nil && !weakself!.like! {
                    weakself?.dislikeButton.tintColor = UIColor.red
                    weakself?.likeButton.tintColor = UIColor.lightGray
                }
            }
        }
        
    }
    
    var reviewText: String? {
        didSet {
            emptyNote = reviewText == nil || reviewText!.isEmpty
        }
    }
    
    var makeReviewFunction: ((Bool, String?) -> Void)?
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var textView: UITextView!

    @IBAction func likeButtonTap(_ sender: UIButton) {
        like = true
    }
    
    @IBAction func dislikeButtonTap(_ sender: UIButton) {
        like = false
    }

    @IBAction func doneButtonTap(_ sender: UIButton) {
        if like != nil {
            var note: String?
            if !emptyNote {
                note = textView.text
            }
            makeReviewFunction?(like!, note)
        }
        dismiss(animated: true, completion: nil)
    }

    private func resetLikeButtons() {
        likeButton.tintColor = UIColor.blue
        dislikeButton.tintColor = UIColor.blue
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
        reviewText = text
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        setupReviewNoteInput()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
