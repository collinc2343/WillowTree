//
//  PersonObj.swift
//  NameGame
//
//  Created by Collin Chandler on 2/9/18.
//  Copyright © 2018 WillowTree Apps. All rights reserved.
//

import Foundation
import UIKit

class ProfileObj
{
    enum ProfileType {
        case current
        case former
    }
    
    public private(set) var type:ProfileType = .current
    public private(set) var id = ""
    public private(set) var fName = ""
    public private(set) var lName = ""
    public private(set) var title:String? = nil
    public private(set) var imageURL = ""
    public private(set) var isMat = false
    public private(set) var loadedImage:UIImage? = nil
    
    func loadFromJSON(_json: JSON) -> Bool
    {
        //Get the id
        guard let tempID = _json["id"].string else
        {
            return false
        }
        id = tempID
        
        //Get the first name and check if it's a mat
        guard let tempFName = _json["firstName"].string else
        {
            return false
        }
        
        fName = tempFName
        //Grab the first 3 letters and see if they're mat
        if(fName.lowercased().prefix(3) == "mat")
        {
            isMat = true
        }
        //Get the last name
        guard let tempLName = _json["lastName"].string else
        {
            return false
        }
        lName = tempLName
        //Load the title and set the employee type based on whether or not they have a title
        if let tempTitle = _json["jobTitle"].string
        {
            title = tempTitle
            type = .current
        }
        else
        {
            type = .former
        }
        //Get the image url. Filter out the test1.png because you can't see who they are anyways
        guard let tempImageURL = _json["headshot"]["url"].string, tempImageURL.suffix(9) != "TEST1.png" else
        {
            print("No image found: " + fName + lName)
            return false
            
        }
        imageURL = "https:" + tempImageURL
        
        //I don't like doing this but I spent too long trying to fix you Whitney
        if(self.id == "336esrta1WmIOqa06m0qog")
        {
            return false
        }
        
        return true
    }
    
    func getName() -> String
    {
        return fName + " " + lName
    }
    
}
