//
// SearchResultsViewController.swift
//  part2
//
//  Created by Josh Black on 8/16/14.
//  Copyright (c) 2014 Josh Black. All rights reserved.
//

import UIKit
import QuartzCore

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {
    @IBOutlet weak var appsTableView: UITableView!

    lazy var api: APIController = APIController(delegate: self)

    // Dictionary that takes a string as a key and stores a UIImage as a value
    var imageCache = [String : UIImage]()
    var albums = [Album]()
    let kCellIdentifier: String = "SearchResultCell"
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        api.searchItunesFor("Bob Dylan")
    }

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {

        // Gives us an already instantiated cell
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell

        let album = self.albums[indexPath.row]
        cell.textLabel.text = album.title
        cell.imageView.image = UIImage(named: "Blank52")

        // Get the formatted price string for display in the subtitle
        let formattedPrice = album.price

        // Jump in to a background thread to get the image for this item

        // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
        let urlString = album.thumbnailImageURL

        // Check our image cache for the existing key.
        var image = self.imageCache[urlString]

        if (image == nil) {
            // If the image doesn't exist let's download it
            var imgURL: NSURL = NSURL(string: urlString)

            // Download an NSData representation of the image at the URL
            let request: NSURLRequest = NSURLRequest(URL: imgURL)

            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                if error == nil {
                    image = UIImage(data: data)

                    // Store the image in our cache
                    self.imageCache[urlString] = image
                    if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                        cellToUpdate.imageView.image = image
                    }
                }
                else {
                    println("error: \(error.localizedDescription)")
                }
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                    cellToUpdate.imageView.image = image
                }
            })
        }

        cell.detailTextLabel.text = formattedPrice

        return cell
    }

    func didReceiveAPIResults(results: NSDictionary) {
        var resultsArr: NSArray = results["results"] as NSArray

        dispatch_async(dispatch_get_main_queue(), {
            self.albums = Album.albumsWithJSON(resultsArr)
            self.appsTableView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    func tableView(tableView: UITableView!, willDisplayCell cell: UITableViewCell!, forRowAtIndexPath indexPath: NSIndexPath!) {
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
            })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject) {
        var detailsViewController: DetailsViewController = segue.destinationViewController as DetailsViewController
        var albumIndex = appsTableView!.indexPathForSelectedRow().row
        var selectedAlbum = self.albums[albumIndex]
        detailsViewController.album = selectedAlbum
    }
}

