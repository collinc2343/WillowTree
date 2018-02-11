//
//  FaceButton.swift
//  NameGame
//
//  Created by Intern on 3/11/16.
//  Copyright © 2016 WillowTree Apps. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

open class FaceButton: UIButton {

    //Holds the profile id
    public private(set) var id: String = ""
    //Used to keep track if this button has been guessed wrong this round
    public private(set) var guessedWrong = false
    private var tintView: UIView = UIView(frame: CGRect.zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    //Setup the tint
    func setup() {
        setTitleColor(.white, for: .normal)
        titleLabel?.alpha = 0.0

        tintView.alpha = 0.0
        tintView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(tintView)

        tintView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tintView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        tintView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tintView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    //Adds the red tint
    func setWrongAnswer()
    {
        guessedWrong = true
        tintView.alpha = 0.5
        tintView.backgroundColor = UIColor.red
        self.bringSubview(toFront: tintView)
    }
    //Adds the green tint
    func setRightAnswer()
    {
        tintView.alpha = 0.5
        tintView.backgroundColor = UIColor.appColors.placeHolderColor
        self.bringSubview(toFront: tintView)
    }
    
    //Set our id. Maybe could have just made it public but whatever
    func setId(_id: String)
    {
        id = _id
    }

    //Show the user's face on the button.
    func setHeadShot(_url: String)
    {
        guessedWrong = false
        tintView.alpha = 0.0
        print(_url)
        SDWebImageManager.shared().loadImage(with: URL(string: _url), options: .continueInBackground, progress: { (receivedSize, expectedSize, url) in
            
        }) { (image, data, error, cachetype, finished, url) in
            if(error != nil)
            {
                print(error!.localizedDescription)
            }
            //self.contentMode = UIViewContentMode.scaleToFill
            guard let image:UIImage = image else {
                return
            }
            
            self.setBackgroundImage(image, for: .normal)
        }
    }
}
