//
//  SegmentAnalyticsManager.swift
//  PeopleTV
//
//  Created by Anish Agarwal on 08/02/20.
//  Copyright © 2020 Eugene Lizhnyk. All rights reserved.
//

import Foundation
import Analytics
import AVKit

enum SegmentAnalyticsEventType: String {
    case PlayerStartEvent    = "Video Content Started"
    case PlayerPlayingEvent  = "Video Content Playing"
    case PlayerCompleteEvent = "Video Content Completed"
}

@objcMembers public class SegmentAnalyticsAttributes: NSObject {
    public static let contentCmsCategory = "contentCmsCategory" //A STRING of the CMS category attached to the piece of content, pipe separated if more than CMS category exists for the piece of content.
    public static let adType = "Ad Type" //a value of “pre-roll” “mid-roll” or “post-roll” if known
    public static let contentShownOnPlatform = "contentShownOnPlatform" //"ott" (this is hardcoded)
    public static let streaming_device = "streaming_device" // device make + model (e.g., "Roku 4400X")
    public static let videoAccountId = "videoAccountId" // this is hardcoded
    public static let videoAccountName = "videoAccountName" // "People" (this is hardcoded)
    public static let videoAdDuration = "videoAdDuration" // the total duration of an ad break, if known
    public static let videoAdVolume = "videoAdVolume" // the volume of an ad playing, if known
    public static let session_id = "session_id"   //String (au togenerated for the playback's session)
    public static let videoId = "videoId"     //String (Zype video_id)
    public static let videoName = "videoName"      //String (Zype video_title)
    public static let videoContentPosition = "videoContentPosition"     //Integer (current playhead position)
    public static let videoContentDuration = "videoContentDuration" //Integer (total duration of video in seconds)
    public static let videoContentPercentComplete = "videoContentPercentComplete"// The current  percent of video watched.
    public static let livestream = "livestream"   //Boolean (true if on_air = true)
    public static let videoPublishedAt = "videoPublishedAt"      //ISO 8601 Date String (Zype published_at date)
    public static let videoCreatedAt = "videoCreatedAt" //  A TIMESTAMP of the time of video creation
    public static let videoSyndicate = "videoSyndicate" // A STRING that passes whether the piece of content is syndicated
    public static let videoFranchise = "videoFranchise" //  A STRING that passes the video franchise. Please pass null if not available
    public static let videoTags = "videoTags"     //Array(String)
    public static let videoThumbnail = "videoThumbnail" //  thumbnail URL of the primary thumbnail image
    public static let videoUpdatedAt = "videoUpdatedAt" // A TIMESTAMP of the video's last updated date/time
}

@objc public class SegmentAnalyticsManager: NSObject {
    // MARK: - Properties
    @objc public static let sharedInstance = SegmentAnalyticsManager()
    private var isLiveStream: Bool = false
    private var isResumingPlayback: Bool = false
    private var segmentPayload: [String: Any]? = nil
    private var totalLength: Double = 0
    private var currentPosition: Double = 0
    private var progress: Double = 0
    private var timeObserverToken: Any?
    private var trackingTimer: Timer?
    private var sessionId = UUID().uuidString
    private static let playingHeartBeatInterval = 5.0
    @objc public static var segmentAnalyticsEnabled = false

    weak var zypePlayer: ZypeAVPlayer? = nil
    
    
    // MARK: - reset
    @objc public func reset() {
        removeTrackingVideoProgress()
        NotificationCenter.default.removeObserver(self)
        segmentPayload = nil
        zypePlayer = nil
        totalLength = 0
        currentPosition = 0
        progress = 0
        isLiveStream = false
        isResumingPlayback = false
    }
    
    open func setConfigurations(_ player: ZypeAVPlayer, _ payload: [String: Any], _ isLive: Bool, _ resume: Bool) {
        if !isSegmentAnalyticsEnabled() {
            return
        }
        segmentPayload = payload
        zypePlayer = player
        isLiveStream = isLive
        isResumingPlayback = resume
        segmentPayload?[SegmentAnalyticsAttributes.session_id] = sessionId
    }
    
    // MARK: - track video playback
    @objc open func trackStart(resumedByAd: Bool) {
        if !isSegmentAnalyticsEnabled() {
            return
        }
        
        if !isResumingPlayback {
            guard let event = eventData(.PlayerStartEvent) else {
                print("SegmentAnalyticsManager.trackStart event data is nil")
                return
            }
            SEGAnalytics.shared()?.track(SegmentAnalyticsEventType.PlayerStartEvent.rawValue, properties: event)
        }
        
        // start tracking video progress
        trackVideoProgress()
    }
    
    open func trackPause() {
        if !isSegmentAnalyticsEnabled() {
            return
        }
        removeTrackingVideoProgress()
    }
    
    @objc open func trackComplete() {
        if !isSegmentAnalyticsEnabled() {
            return
        }
        guard let event = eventData(.PlayerCompleteEvent) else {
            print("SegmentAnalyticsManager.trackComplete event data is nil")
            return
        }
        SEGAnalytics.shared()?.track(SegmentAnalyticsEventType.PlayerCompleteEvent.rawValue, properties: event)
        
        // reset all parameters and remove observer after video playing finished
        reset()
    }

    private func trackPlaying() {
        guard let event = eventData(.PlayerPlayingEvent) else {
            print("SegmentAnalyticsManager.trackPlaying event data is nil")
            return
        }
        SEGAnalytics.shared()?.track(SegmentAnalyticsEventType.PlayerPlayingEvent.rawValue, properties: event)
    }

    private func eventData(_ event: SegmentAnalyticsEventType) -> [String:Any]? {
        guard var segmentPayload = segmentPayload else { return nil }
        
        if event == .PlayerCompleteEvent {
            segmentPayload[SegmentAnalyticsAttributes.videoContentPosition] = Int(self.totalLength)
            segmentPayload["videoContentPercentComplete"] = Int(100)
        } else {
            segmentPayload[SegmentAnalyticsAttributes.videoContentPosition] = Int(self.currentPosition)
            segmentPayload["videoContentPercentComplete"] = Int(self.progress)
        }
        
        segmentPayload[SegmentAnalyticsAttributes.livestream] = isLiveStream

        print("\(event.rawValue) - \(segmentPayload)")
        return segmentPayload
    }
    
    private func trackVideoProgress() {
        setupTrackingVideoProgress()
    }
    
    @objc private func updatePlayingParameters() {
        guard self.zypePlayer?.currentItem?.status == .readyToPlay else {
            print("SegmentAnalyticsManager.trackVideoProgress video item status is not readyToPlay, do nothing")
            return
        }
        
        if let duration = self.zypePlayer?.currentItem?.duration, let ctime = self.zypePlayer?.currentItem?.currentTime() {
            if isLiveStream {
                print("SegmentAnalyticsManager.trackVideoProgress detected live streaming")
                self.currentPosition = 0
            } else {
                self.totalLength = CMTimeGetSeconds(duration)
                self.currentPosition = CMTimeGetSeconds(ctime)
                if self.totalLength <= 0 {
                    print("SegmentAnalyticsManager.trackVideoProgress totalLength is zero, possible due to live streaming, don't calculate percentage")
                } else {
                    self.progress = Double(Float(self.currentPosition/self.totalLength) * 100.0)
                }
            }
            
            DispatchQueue.main.async {
                if self.progress >= 100 {
                    self.trackComplete()
                } else {
                    if self.isResumingPlayback {
                        guard let event = self.eventData(.PlayerStartEvent) else {
                            print("SegmentAnalyticsManager.trackVideoProgress event data is nil")
                            return
                        }
                        SEGAnalytics.shared()?.track(SegmentAnalyticsEventType.PlayerStartEvent.rawValue, properties: event)
                        self.isResumingPlayback = false
                    } else {
                        self.trackPlaying()
                    }
                }
            }
        }
    }
        
    private func setupTrackingVideoProgress() {
        // first cacnel previous tracking if any
        self.removeTrackingVideoProgress()
        
        self.trackingTimer = Timer.scheduledTimer(timeInterval: SegmentAnalyticsManager.playingHeartBeatInterval,
        target: self,
        selector: #selector(updatePlayingParameters),
        userInfo: nil, repeats: true)
    }
    
    private func removeTrackingVideoProgress() {
        if self.trackingTimer?.isValid == true {
            self.trackingTimer?.invalidate()
            self.trackingTimer = nil
        }
    }
    
    private func isSegmentAnalyticsEnabled() -> Bool {
        return SegmentAnalyticsManager.segmentAnalyticsEnabled
    }
}

@objc public protocol ZypePlayerDelegate: class {
    func segmentAnalyticsPaylod() -> [String: Any]
    func isLivesStream() -> Bool
    func isResumingPlayback() -> Bool
}

@objc public class ZypeAVPlayer: AVPlayer {
    @objc public weak var delegate: ZypePlayerDelegate?
    
    @objc public func resumePlay() {
        super.play()
        SegmentAnalyticsManager.sharedInstance.trackStart(resumedByAd: true)
    }
    
    override public func play() {
        super.play()
        if let delegate = delegate {
            SegmentAnalyticsManager.sharedInstance.setConfigurations(self, delegate.segmentAnalyticsPaylod(), delegate.isLivesStream(), delegate.isResumingPlayback())
        }
        SegmentAnalyticsManager.sharedInstance.trackStart(resumedByAd: false)
    }
    
    override public func pause() {
        super.pause()
        SegmentAnalyticsManager.sharedInstance.trackPause()
    }
}
