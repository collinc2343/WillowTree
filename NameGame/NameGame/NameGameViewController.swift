//
//  ViewController.swift
//  NameGame
//
//  Created by Matt Kauper on 3/8/16.
//  Copyright © 2016 WillowTree Apps. All rights reserved.
//

import UIKit
import SDWebImage

class NameGameViewController: UIViewController {

    @IBOutlet weak var outerStackView: UIStackView!
    @IBOutlet weak var innerStackView1: UIStackView!
    @IBOutlet weak var innerStackView2: UIStackView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet var imageButtons: [FaceButton]!
    //A timer so we can show for 1 second that you got the correct answer
    private var roundEndTimer:Timer?
    private let roundEndTimerLength = 0.5
    internal let defaultImage:UIImage? = UIImage(named: "WTPlaceholder")
    internal var answerGuessed = false
    weak var nameGame:NameGame?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Request profiles
        nameGame?.getMoreProfiles(_delegate: self)
        //Set our default background image
        for imageButton in imageButtons
        {
            imageButton.setBackgroundImage(defaultImage, for: .normal)
        }
        let orientation: UIDeviceOrientation = self.view.frame.size.height > self.view.frame.size.width ? .portrait : .landscapeLeft
        configureSubviews(orientation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Since we invalidate our timer on view will disappear we have to check if we should put it back on in view will appear
        if(answerGuessed && roundEndTimer == nil)
        {
            roundEndTimer = Timer.scheduledTimer(timeInterval: roundEndTimerLength, target: self, selector: #selector(completeRound), userInfo: nil, repeats: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //End our round end timer since we don't want it going off while we're disappeared
        roundEndTimer?.invalidate()
        roundEndTimer = nil
    }

    @IBAction func faceTapped(_ button: FaceButton) {
        //If we've already guessed this one, or the correct answer has been guessed, ignore the touch
        if(button.guessedWrong || answerGuessed)
        {
            return
        }
        //Make the guess
        if(nameGame!.makeGuess(_id: button.id))
        {
            answerGuessed = true
            button.setRightAnswer()
            roundEndTimer = Timer.scheduledTimer(timeInterval: roundEndTimerLength, target: self, selector: #selector(completeRound), userInfo: nil, repeats: false)
        }
        else
        {
            //Wrong answer try again
            button.setWrongAnswer()
        }
    }
    //Completes the round, clears the cache, and either requests more profiles or ends the game
    func completeRound(){
        //So we don't get too much memory building up
        SDWebImageManager.shared().imageCache?.clearMemory()
        //It was right, complete the round
        if(nameGame!.completeRound())
        {
            //There are more rounds, so get more profiles
            nameGame!.getMoreProfiles(_delegate: self)
        }
        else
        {
            //No more rounds, end the game
            endGame()
        }
    }
    
    //Transition to the results
    func endGame(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let resultsViewController = storyBoard.instantiateViewController(withIdentifier: "resultsViewController") as! ResultsViewController
        resultsViewController.nameGame = self.nameGame
        self.navigationController?.pushViewController(resultsViewController, animated: true)
    }

    func configureSubviews(_ orientation: UIDeviceOrientation) {
        if orientation.isLandscape {
            outerStackView.axis = .vertical
            innerStackView1.axis = .horizontal
            innerStackView2.axis = .horizontal
        } else {
            outerStackView.axis = .horizontal
            innerStackView1.axis = .vertical
            innerStackView2.axis = .vertical
        }

        view.setNeedsLayout()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let orientation: UIDeviceOrientation = size.height > size.width ? .portrait : .landscapeLeft
        configureSubviews(orientation)
    }
}

extension NameGameViewController: NameGameDelegate {
    func progressCompleted() {
        self.answerGuessed = false
        DispatchQueue.main.async {
            for i in (0..<self.imageButtons.count)
            {
                print("Setting headshot: " + String(i))
                //Set our placeholder image
                self.imageButtons[i].setBackgroundImage(self.defaultImage, for: .normal)
                //Start loading the headshot
                self.imageButtons[i].setHeadShot(_url: self.nameGame!.currentProfiles[i].imageURL)
                //Set our id to the corresponding profile
                self.imageButtons[i].setId(_id: self.nameGame!.currentProfiles[i].id)
            }
            //Set our new question
            self.questionLabel.text = self.nameGame!.getRoundName()
        }
    }
    
    func progressError(error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
