//
//  ResultsViewController.swift
//  NameGame
//
//  Created by Collin Chandler on 2/9/18.
//  Copyright © 2018 WillowTree Apps. All rights reserved.
//

import Foundation
import UIKit

class ResultsViewController: UIViewController {
    weak var nameGame:NameGame?
    
    @IBOutlet weak var wrongGuessesLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItem = backButton
        
        messageLbl.text = nameGame!.getEndMessage()
        wrongGuessesLbl.text = String(nameGame!.wrongGuesses)
    
    }
    //Navigate back to the setup view
    func goBack(){
        self.navigationController?.popToRootViewController(animated: true)
    }
}
