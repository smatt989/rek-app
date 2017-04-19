//
//  EmptyTableView.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/18/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class EmptyTableView: UIView {
    
    
    @IBOutlet weak var headlineText: UILabel!
    @IBOutlet weak var informationText1: UILabel!
    @IBOutlet weak var informationText2: UILabel!
    @IBOutlet weak var instructionsText: UILabel!

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
    }
    
    func setupText(headline: String, informationText1: String, informationText2: String?, instructionsText: String?) {
        
        DispatchQueue.main.async { [weak weakself = self] in
            if weakself != nil {
                weakself!.headlineText.text = headline
                weakself!.informationText1.text = informationText1
                weakself!.informationText2.text = informationText2
                weakself!.instructionsText.text = instructionsText
                
                weakself!.informationText2.isHidden = informationText2 == nil
                weakself!.instructionsText.isHidden = instructionsText == nil
            }
            
        }
        
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }

}
