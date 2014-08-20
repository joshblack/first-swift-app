//
//  APIController.swift
//  part2
//
//  Created by Josh Black on 8/16/14.
//  Copyright (c) 2014 Josh Black. All rights reserved.
//

import Foundation

protocol APIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary)
}

class APIController {

    var delegate: APIControllerProtocol

    // Update the constructor to accept the delegate as its only argument
    init(delegate: APIControllerProtocol) {
        self.delegate = delegate
    }

    func searchItunesFor(searchTerm: String) {

        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        let itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)

        // Escape anything that isn't URl-friendly
        let escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let urlPath = "https://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music&entity=album"

        get(urlPath)

    }

    func get(path: String) {
        let url = NSURL(string: path)
        let session = NSURLSession.sharedSession()

        let task = session.dataTaskWithURL(url, completionHandler: { data, response, error -> Void in
            println("Request completed!")

            if (error) {
                println(error.localizedDescription)
            }

            var err: NSError?

            var json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary


            if (err != nil) {
                println("JSON Error \(err!.localizedDescription)")
            }

            self.delegate.didReceiveAPIResults(json)
        })
        
        // Actually make our request
        task.resume()
    }

    func lookupAlbum(collectionId: Int) {
        get("https://itunes.apple.com/lookup?id=\(collectionId)&entity=song")
    }
}