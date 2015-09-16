//
//  WatsonLanguage.swift
//  WatsonLanguageTranslation
//
//  Created by Karl Weinmeister on 9/16/15.
//  Copyright © 2015 IBM Mobile Innovation Lab. All rights reserved.
//

import Foundation

public struct WatsonLanguage {
    var language:String
    var name:String
    
    init(language:String,name:String)
    {
        self.language = language
        self.name = name
    }
}
