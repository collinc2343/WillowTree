//
//  NameGame.swift
//  NameGame
//
//  Created by Erik LaManna on 11/7/16.
//  Copyright © 2016 WillowTree Apps. All rights reserved.
//

import Foundation

protocol NameGameDelegate: class {
    func progressCompleted()
    func progressError(error: Error)
}

typealias responseObj = (JSON, Error?) -> Void

class NameGame {
    
    enum gameType {
        case random
        case matt
        case team
    }

    weak var delegate: NameGameDelegate?
    
    private let numberPeople = 6
    private let numRoundsForAscendance = 10
    private let SERVER_URL = "https://willowtreeapps.com"
    private let DATA_ENDPOINT = "/api/v1.0/profiles"
    private let ROUNDS_KEY = "rounds"
    private let GAME_TYPE_KEY = "game_type"
    private let STRING_TABLE = "Messages"
    private let WHILE_BREAK = 1000
    private var currGameType:gameType = .random

    private var dataLoading = false
    private var currentProfileIndex = 0
    private var profilesJSON:JSON? = nil
    private var profileCount = 0
    
    public private(set) var currentProfiles:[ProfileObj] = []
    public private(set) var wrongGuesses = 0
    public private(set) var correctIndex = 1
    public private(set) var numRounds = 10
    public var currentRound = 1
    
    //Load our default values from user defaults and set them
    init()
    {
        //Load our defaults
        let defaults = UserDefaults.standard
        let rounds = defaults.integer(forKey: ROUNDS_KEY)
        if(rounds > 0)
        {
            self.setNumRounds(_numRounds: rounds)
        }
        
        let gameType = defaults.integer(forKey: GAME_TYPE_KEY)
        self.setGameType(_gameType: gameType)
    }
    //Sets the number of rounds and saves it to user defaults
    func setNumRounds(_numRounds: Int)
    {
        if(_numRounds < 1)
        {
            return
        }
        numRounds = _numRounds
        let defaults = UserDefaults.standard
        defaults.set(numRounds, forKey: ROUNDS_KEY)
    }
    //Sets the game type as an int from the segmented control index and saves it to user defaults
    func setGameType(_gameType: Int)
    {
        switch _gameType
        {
        case 0:
            currGameType = .random
            break
        case 1:
            currGameType = .matt
            break
        case 2:
            currGameType = .team
            break
        default:
            currGameType = .random
        }
        let defaults = UserDefaults.standard
        defaults.set(_gameType, forKey: GAME_TYPE_KEY)
    }
    //Gets the game type as an int for the segmented control
    func getGameType() -> Int
    {
        switch currGameType
        {
        case .random:
            return 0
        case .matt:
            return 1
        case .team:
            return 2
        }
    }
    //Reset the game and if needed load the game data
    func beginLoadGame(_delegate: NameGameDelegate)
    {
        delegate = _delegate
        wrongGuesses = 0
        if(profilesJSON == nil && dataLoading == false)
        {
            dataLoading = true
            loadGameData { (json, error) in
                self.dataLoading = false
                if(error != nil)
                {
                    self.delegate?.progressError(error: error!)
                }
                else
                {
                    self.profilesJSON = json
                    guard let testProfileCount = (self.profilesJSON?.array?.count) else
                    {
                        let newError = NSError(domain: "", code: -1, userInfo: nil)
                        self.delegate?.progressError(error: newError)
                        return
                    }
                    self.profileCount = testProfileCount
                    self.delegate?.progressCompleted()
                }
            }
        }
        else
        {
            delegate?.progressCompleted()
        }
    }
    //Gets more profiles based on the current game type
    func getMoreProfiles(_delegate: NameGameDelegate)
    {
        delegate = _delegate
        switch currGameType {
        case .random:
            getRandomProfiles()
            break
        case .matt:
            getMatProfiles()
            break
        case .team:
            getTeamProfiles()
            break
        }
        
        if(currentProfiles.count < numberPeople)
        {
            delegate?.progressError(error: NSError(domain: "", code: -1, userInfo: nil))
            return
        }
        
        correctIndex = Int(arc4random_uniform(UInt32(numberPeople)))
        print("Correct index: " + String(correctIndex))
        delegate?.progressCompleted()
    }
    //Get the name of the person who is currently being guessed
    func getRoundName() -> String
    {
        return "Who is " + currentProfiles[correctIndex].getName() + "?"
    }
    
    func getRoundCount() -> String
    {
        return "Rounds: " + String(numRounds)
    }
    
    //Get the end message based on the current results
    func getEndMessage() -> String
    {
        var ratio = (Double(wrongGuesses) / Double(numRounds)).rounded()
        //Max our ratio at 3 since we only have 3 results messages
        if(ratio > 3.0)
        {
            ratio = 3.0
        }
        //Since we're rounding, it could round down to 0 with more than 1 wrong guess. We only want to give the best message to those who met the number of round requirements and got 0 wrong
        else if(ratio == 0.0 && (wrongGuesses > 0 || numRounds < numRoundsForAscendance))
        {
            ratio = 1.0
        }
        print(ratio)
        let stringKey = "results" + String(format:"%.0f", ratio)
        let strMsg = Bundle.main.localizedString(forKey: stringKey, value: nil, table: STRING_TABLE)
        return strMsg
    }
    //Get the current set game type description
    func getGameDesc() -> String
    {
        var strGameDesc = ""
        switch(currGameType)
        {
        case .random:
            strGameDesc = Bundle.main.localizedString(forKey: "game_type_desc_random", value: nil, table: STRING_TABLE)
            break
        case .matt:
            strGameDesc = Bundle.main.localizedString(forKey: "game_type_desc_matt", value: nil, table: STRING_TABLE)
            break
        case .team:
            strGameDesc = Bundle.main.localizedString(forKey: "game_type_desc_team", value: nil, table: STRING_TABLE)
            break
        }
        return strGameDesc
    }
    //Gets the warning for rounds based on the current set number of rounds
    func getRoundWarning() -> String
    {
        var strWarning = ""
        if(numRounds < numRoundsForAscendance)
        {
            strWarning = Bundle.main.localizedString(forKey: "round_count_warning", value: nil, table: STRING_TABLE)
            strWarning = String(format: strWarning, numRoundsForAscendance)
        }
        return strWarning
    }
    //Gets a set of random employees
    private func getRandomProfiles()
    {
        var whileCounter = 0
        currentProfiles = []
        while(currentProfiles.count < numberPeople && whileCounter < WHILE_BREAK)
        {
            whileCounter += 1
            currentProfileIndex = Int(arc4random_uniform(UInt32(profileCount - 1)))
            guard let currentProfileJSON:JSON = profilesJSON?[currentProfileIndex] else
            {
                print("Error. current profile index: " + String(currentProfileIndex))
                return
            }
            
            let currentProfile = ProfileObj()
            //Load the profile from json and save if it succeeds
            let profileLoaded = currentProfile.loadFromJSON(_json: currentProfileJSON)
            //Make sure we haven't already added this one
            let inArray = currentProfiles.contains(where: { (savedProfile) -> Bool in
                if(savedProfile.id == currentProfile.id)
                {
                    return true
                }
                else
                {
                    return false
                }
            })
            //If it's loaded properly, a current employee, and not already in our array, add it to our array
            if(profileLoaded && currentProfile.type == .current && inArray == false)
            {
                currentProfiles.append(currentProfile)
            }
        }

    }
    //Gets currently employed mats
    private func getMatProfiles()
    {
        var whileCounter = 0
        currentProfiles = []
        while(currentProfiles.count < numberPeople && whileCounter < WHILE_BREAK)
        {
            whileCounter += 1
            self.incrementProfileIndex()
            guard let currentProfileJSON:JSON = profilesJSON?[currentProfileIndex] else
            {
                return
            }
            
            let currentProfile = ProfileObj()
            let profileLoaded = currentProfile.loadFromJSON(_json: currentProfileJSON)
            //Make sure we haven't already added this one
            let inArray = currentProfiles.contains(where: { (savedProfile) -> Bool in
                if(savedProfile.id == currentProfile.id)
                {
                    return true
                }
                else
                {
                    return false
                }
            })
            //If it's loaded properly, a current employee, a mat, and not already in our array, add it to our array
            if(profileLoaded && currentProfile.type == .current && currentProfile.isMat == true && inArray == false)
            {
                currentProfiles.append(currentProfile)
            }
        }
    }
    //Gets profiles in numeric order regardless of whether they are current or former employees
    private func getTeamProfiles()
    {
        var whileCounter = 0
        currentProfiles = []
        while(currentProfiles.count < numberPeople && whileCounter < WHILE_BREAK)
        {
            whileCounter += 1
            self.incrementProfileIndex()
            guard let currentProfileJSON:JSON = profilesJSON?[currentProfileIndex] else
            {
                return
            }
            
            let currentProfile = ProfileObj()
            let profileLoaded = currentProfile.loadFromJSON(_json: currentProfileJSON)
            //If it's loaded properly, add it to our array
            if(profileLoaded)
            {
                currentProfiles.append(currentProfile)
            }
        }
    }
    //Increments our profile index
    private func incrementProfileIndex()
    {
        currentProfileIndex += 1
        if(currentProfileIndex >= profileCount)
        {
            currentProfileIndex = 0
        }
    }
    //Checks the guess id against the correct id. If wrong, increments wrong guesses
    func makeGuess(_id : String) -> Bool
    {
        if(currentProfiles[correctIndex].id == _id)
        {
            return true
        }
        else
        {
            wrongGuesses += 1
            return false
        }
    }
    //False if we're on the last round, otherwise increment and round complete
    func completeRound() -> Bool
    {
        if(currentRound >= numRounds)
        {
            return false
        }
        currentRound += 1
        return true
    }

    // Load JSON data from API
    func loadGameData(completion: @escaping (JSON?, Error?) -> Void) {
        let url = SERVER_URL + DATA_ENDPOINT
        let session = URLSession.shared
        let task = session.dataTask(with: URL(string: url)!) { (data, response, error) in
            if(error != nil)
            {
                completion(nil, error)
            }
            do{
                let jsonResult:JSON = try JSON(data: data!)
                completion(jsonResult, nil)
            }
            catch
            {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
}
