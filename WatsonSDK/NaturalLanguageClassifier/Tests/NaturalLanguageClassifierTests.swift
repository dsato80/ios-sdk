/**
 * Copyright IBM Corporation 2015
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import XCTest
@testable import WatsonSDK

class NaturalLanguageClassifierTests: XCTestCase {
    
    /// Language translation service
    private var service: NaturalLanguageClassifier?
    
    // this will change based on login instance
    private var classifierIdInstanceId = "0235B6x12-nlc-767"
    
    private static var classifierIdInstanceIdToDelete: String?
    
    /// Timeout for an asynchronous call to return before failing the unit test
    private let timeout: NSTimeInterval = 60.0
    
    override func setUp() {
        super.setUp()
        if let url = NSBundle(forClass: self.dynamicType).pathForResource("Credentials", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: url) as? Dictionary<String, String> {
                let username = dict["NaturalLanguageClassifierUsername"]!
                let password = dict["NaturalLanguageClassifierPassword"]!
                service = NaturalLanguageClassifier(username: username, password: password)
            } else {
                XCTFail("Unable to extract dictionary from plist")
            }
        } else {
            XCTFail("Plist file not found")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetClassifiers() {
        let positiveExpectation = expectationWithDescription("Get All Classifiers")
        
        service!.getClassifiers({(classifiers:[NaturalLanguageClassifier.Classifier]?, error) in
            XCTAssertGreaterThan((classifiers!.count),0,"Expected at least 1 model to be returned")
            positiveExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in XCTAssertNil(error, "Timeout") })
    }
    
    func testDeleteClassifier() {
        let authorizedDeleteExpectation = expectationWithDescription("Unauthorized expectation")
        let missingDeleteExpectation = expectationWithDescription("Missing delete expectation")
        
        service!.deleteClassifier("Non-existance", completionHandler:{ error in
            XCTAssertNotNil(error, "Expected missing delete exception when trying to delete a nonexistent model")
            missingDeleteExpectation.fulfill()
        })
        
        service!.deleteClassifier(NaturalLanguageClassifierTests.classifierIdInstanceIdToDelete!, completionHandler:{ error in
            XCTAssertNil(error, "Expected missing delete exception when trying to delete a nonexistent model")
            NaturalLanguageClassifierTests.classifierIdInstanceIdToDelete = ""
            authorizedDeleteExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in XCTAssertNil(error, "Timeout") })
    }
    
    func testGetClassifier() {
        let expectationValid = expectationWithDescription("Valid Expected")
        let expectationInvalid = expectationWithDescription("Invalid Expect")
        
        service!.getClassifier("MISSING_CLASSIFIER_ID") { classifier, error in
            XCTAssertNil(classifier)
            XCTAssertNotNil(error)
            XCTAssertEqual(error!.code, 404, "Expect 404 error code")
            expectationInvalid.fulfill()
        }
        
        // todo use create to get id then delete the classifier afterwards.  All api calls need to be in place first
        service!.getClassifier(classifierIdInstanceId) { classifier, error in
            XCTAssertNotNil(classifier)
            XCTAssertEqual(classifier!.id, self.classifierIdInstanceId, "Expected to get id requested in classifier")
            expectationValid.fulfill()
        }
        
        waitForExpectationsWithTimeout(timeout, handler: { error in XCTAssertNil(error, "Timeout") })
    }
    
    func testClassify() {
        let expectationValid = expectationWithDescription("Valid Expectation")
        let expectationInvalid = expectationWithDescription("Invalid Expectation")
        
        service!.classify("MISSING_CLASSIFIER_ID", text: "is it sunny?", completionHandler:{(classification, error) in
            XCTAssertEqual(classification!.id, nil, "Expect classifierid to be nil")
            XCTAssertEqual(error!.code, 404, "Expect 404 error code")
            expectationInvalid.fulfill()
        })
        
        // please note this test expects the classifier to be ready
        service!.classify(self.classifierIdInstanceId, text: "is it sunny?", completionHandler:{(classification, error) in
            XCTAssertNotNil(classification,"Expected object not nil")
            XCTAssertEqual(classification!.id, self.classifierIdInstanceId,"Expected to get id requested in classifier")
            XCTAssertLessThan(1, (classification!.classes!.count) as Int,"Expected to get more than one class")
            expectationValid.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in XCTAssertNil(error, "Timeout") })
    }
    
    func testCreateClassifier() {
        let expectationValid = expectationWithDescription("Valid Expectation")
        let expectationInvalid = expectationWithDescription("Invalid Expectation")
        
        let fileURL = NSBundle(forClass: self.dynamicType).URLForResource("weather_data_train", withExtension: "csv")
        XCTAssertNotNil(fileURL)
        
        let fileMetaURL = NSBundle(forClass: self.dynamicType).URLForResource("training_meta", withExtension: "txt")
        XCTAssertNotNil(fileMetaURL)
        
        let missingFileMetaURL = NSBundle(forClass: self.dynamicType).URLForResource("missing_training_meta", withExtension: "txt")
        XCTAssertNotNil(missingFileMetaURL)
        
        service!.createClassifier(missingFileMetaURL!, trainerURL: fileURL!) { classifier, error in
            XCTAssertNil(classifier)
            XCTAssertNotNil(error)
            XCTAssertEqual(error!.code, 400, "Expect 400 error code")
            expectationInvalid.fulfill()
        }
        
        // positive test is tested using CreateClassifer in the class
        service!.createClassifier(fileMetaURL!, trainerURL: fileURL!, completionHandler:{(classifier:NaturalLanguageClassifier.Classifier?, error) in
            guard let classifier = classifier else {
                XCTFail("Expected model to be returned")
                return
            }
            NaturalLanguageClassifierTests.classifierIdInstanceIdToDelete = classifier.id
            XCTAssertNotEqual("", classifier.id, "Expected to get an id")
            expectationValid.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in XCTAssertNil(error, "Timeout") })
    }
    
    func  DeleteClassifiers() {
        let expectationValid = expectationWithDescription("Valid Expectation")
        service!.getClassifiers({(classifiers:[NaturalLanguageClassifier.Classifier]?, error) in
            for classifier in classifiers! {
                if(classifier.id !=  self.classifierIdInstanceId) {
                    self.service!.deleteClassifier(classifier.id!, completionHandler:{ error in
                        
                    })
                }
            }
            expectationValid.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in XCTAssertNil(error, "Timeout") })
    }
}
