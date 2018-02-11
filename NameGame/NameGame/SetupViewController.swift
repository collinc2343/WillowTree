//
//  SetupViewController.swift
//  NameGame
//
//  Created by Collin Chandler on 2/9/18.
//  Copyright © 2018 WillowTree Apps. All rights reserved.
//

import Foundation
import UIKit

class SetupViewController: UIViewController {
    
    @IBOutlet weak var gameTypeSegment: UISegmentedControl!
    @IBOutlet weak var roundsLbl: UILabel!
    @IBOutlet weak var roundsStepper: UIStepper!
    @IBOutlet weak var gameDescLbl: UILabel!
    @IBOutlet weak var roundsWarningLbl: UILabel!
    
    var nameGame:NameGame = NameGame()
    var loadingComplete = false
    var startPressed = false
    var indicator:UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup the loading indicator and start it
        indicator.activityIndicatorViewStyle = .gray
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        indicator.backgroundColor = UIColor.appColors.placeHolderColor
        self.view.addSubview(indicator)
        indicator.startAnimating()
        
        roundsStepper.value = Double(nameGame.numRounds)
        gameTypeSegment.selectedSegmentIndex = nameGame.getGameType()
        roundsLbl.text = nameGame.getRoundCount()
        roundsWarningLbl.text = nameGame.getRoundWarning()
        gameDescLbl.text = nameGame.getGameDesc()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startPressed = false
        //Load up the game data from the webservice
        nameGame.beginLoadGame(_delegate: self)
    }
    
    @IBAction func roundsChanged(_ sender: Any) {
        nameGame.setNumRounds(_numRounds: Int(roundsStepper.value))
        roundsLbl.text = nameGame.getRoundCount()
        roundsWarningLbl.text = nameGame.getRoundWarning()
    }
    
    @IBAction func gameTypeChanged(_ sender: Any) {
        let selectedGameType = gameTypeSegment.selectedSegmentIndex
        nameGame.setGameType(_gameType: selectedGameType)
        gameDescLbl.text = nameGame.getGameDesc()
    }
    
    
    @IBAction func startPressed(_ sender: UIButton) {
        startPressed = true
        //Check if indicator is animating, if so ignore this
        if(indicator.isAnimating){
            return
        }
        //If we didn't finish loading and the indicator is no longer animating, we should try loading again
        else if(loadingComplete == false){
            nameGame.beginLoadGame(_delegate: self)
        }
        //We can begin the game
        else
        {
            beginGame()
        }
    }
    
    func beginGame(){
        nameGame.currentRound = 1
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nameGameViewController = storyBoard.instantiateViewController(withIdentifier: "gameViewController") as! NameGameViewController
        nameGameViewController.nameGame = self.nameGame
        self.navigationController?.pushViewController(nameGameViewController, animated: true)
    }
}

extension SetupViewController: NameGameDelegate {
    func progressCompleted() {
        loadingComplete = true
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
        }
        
        if(startPressed){
            beginGame()
        }
    }
    
    func progressError(error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.indicator.stopAnimating()
        }
    }
}
