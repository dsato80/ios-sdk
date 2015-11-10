/**
 * Copyright 2015 IBM Corp. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import WatsonCore

/**
 
 **CombinedResults**
 
 Returned by the AlchemyLanguage service.
 
 */
public final class CombinedResults: AlchemyLanguageGenericModel {

    // MARK: AlchemyGenericModel
    public var totalTransactions: Int!
    
    // MARK: AlchemyLanguageGenericModel
    public var language: String!
    public var url: String!
    
    // MARK: CombinedResults
    public var author: String!
    public var concepts: [Concept]! = []
    public var entities: [Entities]! = []
    public var feeds: Feeds!
    public var image: String!
    public var imageKeywords: [Keyword]! = []
    public var keywords: [Keyword]! = []
    public var publicationDate: PublicationDate!
    public var relations: [SAORelation]! = []
    public var sentiment: Sentiment!
    public var taxonomy: Taxonomy!
    public var title: String!

}