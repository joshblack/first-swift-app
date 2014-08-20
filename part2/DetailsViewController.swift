//
//  DetailsViewController.swift
//  part2
//
//  Created by Josh Black on 8/17/14.
//  Copyright (c) 2014 Josh Black. All rights reserved.
//

import UIKit
import MediaPlayer
import QuartzCore

class DetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsTrackView: UITableView!
    
    var mediaPlayer: MPMoviePlayerController = MPMoviePlayerController()
    var album: Album?
    var tracks = [Track]()
    lazy var api : APIController = APIController(delegate: self)

    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = self.album?.title
        albumCover.image = UIImage(data: NSData(contentsOfURL: NSURL(string: self.album?.largeImageURL)))

        if self.album != nil {
            api.lookupAlbum(self.album!.collectionId)
        }
    }

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {

        var cell: TrackCell = tableView.dequeueReusableCellWithIdentifier("TrackCell") as TrackCell

        var track = tracks[indexPath.row]

        cell.trackTitleLabel.text = track.title
        cell.playImage.image = UIImage(named: "play")

        return cell
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var track = tracks[indexPath.row]


        mediaPlayer.stop()
        mediaPlayer.contentURL = NSURL(string: track.previewUrl)
        mediaPlayer.play()

        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TrackCell {
            cell.playImage.image = UIImage(named: "stop")
        }

    }

    func tableView(tableView: UITableView!, willDisplayCell cell: UITableViewCell!, forRowAtIndexPath indexPath: NSIndexPath!) {
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
            })
    }

    func didReceiveAPIResults(results: NSDictionary) {
        var resultsArr: NSArray = results["results"] as NSArray
        dispatch_async(dispatch_get_main_queue(), {
            self.tracks = Track.tracksWithJSON(resultsArr)
            self.detailsTrackView.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
}
