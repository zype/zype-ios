//
//  ZypeAppsFlyerHelper.swift
//  Zype
//
//  Created by Anish Kumar on 12/08/20.
//  Copyright © 2020 Zype. All rights reserved.
//

import Foundation

@objc public class ZypeAppsFlyerHelper: NSObject {
    
    /// AppsFlyer params for oneLinks specified at dashboard
    private enum AppsFlyerLinkParams: String {
        case videoID, playlistID
    }

    /// get app iTunes id and app name
    @objc public static func getAppDetailsFromServer( completetion: @escaping ((String?) -> Void)) {

        var bundleIdentifier: String {
            return Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""
        }
        let baseURL: String = "http://itunes.apple.com/lookup?bundleId=\(bundleIdentifier)"
        
        // Creating URL Object
        guard let encodedURL = baseURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
            let url = URL(string: encodedURL) else {
                completetion(nil)
                return
        }

        // Creating a Mutable Request
        var request = URLRequest.init(url: url)
        
        //Setting HTTP values
        request.httpMethod = "GET"
        request.timeoutInterval = 120

        let configuration = URLSessionConfiguration.default

        let session = URLSession(configuration: configuration)

        let downloadTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in

            guard error == nil, let data = data else {
                completetion(nil)
                return
            }
            do {
                if let resultDictionary:NSDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary, resultDictionary.count > 0, (resultDictionary.object(forKey: "results") as? NSArray)?.count != 0 {
                    //let appName = "\(((resultDictionary.object(forKey: "results") as? NSArray)?.object(at: 0) as? NSDictionary)?.object(forKey: "trackCensoredName"))"
                    if let appId = (((resultDictionary.object(forKey: "results") as? NSArray)?.object(at: 0) as?  NSDictionary)?.object(forKey: "trackId")) as? String {
                        print("AppId: \(appId)")
                        completetion(appId)
                    } else {
                        print("Unable to proceed your request,Please try again")
                        completetion(nil)
                    }
                } else {
                    print("Unable to proceed your request,Please try again")
                    completetion(nil)
                }
            } catch {
                print("Unable to proceed your request,Please try again")
                completetion(nil)
            }
        })
        downloadTask.resume()
    }
    
    @objc public static func walkToScene(params: [AnyHashable:Any]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let rootViewTabController = appDelegate.window.rootViewController as? UITabBarController,
            let viewControllers = rootViewTabController.viewControllers,
            !viewControllers.isEmpty else { return }

        if isVideo(params) {
            launchVideo(params, viewControllers[rootViewTabController.selectedIndex] as? UINavigationController)
        } else if isPlaylistDetail(params) {
            launchPlaylistVideos(params, viewControllers[rootViewTabController.selectedIndex] as? UINavigationController)
        } else {
            launchHome(rootViewTabController, viewControllers[0] as? UINavigationController)
        }
    }
    
    private static func isVideo(_ params: [AnyHashable:Any]) -> Bool {
        return params[AppsFlyerLinkParams.videoID.rawValue] as? String != nil
    }
    
    private static func isPlaylistDetail(_ params: [AnyHashable:Any]) -> Bool {
        return params[AppsFlyerLinkParams.playlistID.rawValue] as? String != nil
    }
    
    private static func launchVideo(_ params: [AnyHashable:Any], _ navigationViewController: UINavigationController?) {
        guard let videoId = params[AppsFlyerLinkParams.videoID.rawValue] as? String else {
            print("ZypeAppsFlyerHelper invalid videoId")
            return
        }
        
        fetchVideo(videoId) { video in
            guard let videoDetailViewController = ViewManager.videoDetailViewController() as? VideoDetailViewController else {
                print("ZypeAppsFlyerHelper unable to create video UI")
                return
            }
            videoDetailViewController.detailItem = video
            navigationViewController?.pushViewController(videoDetailViewController, animated: true)
        }
    }
    
    private static func launchPlaylistVideos(_ params: [AnyHashable:Any], _ navigationViewController: UINavigationController?) {
        guard let playlistId = params[AppsFlyerLinkParams.playlistID.rawValue] as? String else {
            print("ZypeAppsFlyerHelper invalid playlistId")
            return
        }
        
        syncVideosInPlaylist(playlistId) {
            guard let videosViewController = ViewManager.videosViewController() as? VideosViewController else {
                print("ZypeAppsFlyerHelper unable to create playlist videos UI")
                return
            }
            
            videosViewController.playlistId = playlistId
            navigationViewController?.pushViewController(videosViewController, animated: true)
        }
        
    }
    
    private static func launchHome(_ tabController: UITabBarController, _ navigationViewController: UINavigationController?) {
        tabController.selectedIndex = 0
        navigationViewController?.popToRootViewController(animated: true)
    }
    
    private static func fetchVideo(_ videoId: String, completion: @escaping ((Video?) -> Void)) {
        if let video = ACSPersistenceManager.video(withID: videoId) {
            completion(video)
        } else {
            SVProgressHUD.show()
            RESTServiceController.sharedInstance()?.loadVideo(withId: videoId) { data, error in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    guard let dataResponse = data,
                        error == nil else {
                            print("ZypeAppsFlyerHelper fetchVideo error", error?.localizedDescription ?? "")
                            completion(nil)
                            return
                    }
                    do {
                        var videoObject: Video? = nil
                        let jsonResponse = try JSONSerialization.jsonObject(with:
                                                dataResponse, options: []) as? [String: Any]
                        if let repsonse = jsonResponse?["response"] as? [[String: Any]],
                            !repsonse.isEmpty {
                            videoObject = ACSPersistenceManager.newVideo()
                            ACSPersistenceManager.saveVideo(inDB: videoObject, withData: repsonse[0])
                        }
                        completion(videoObject)
                      } catch let parsingError {
                        print("ZypeAppsFlyerHelper fetchVideo parsing error", parsingError)
                        completion(nil)
                    }
                }
            }
        }
    }
    
    private static func syncVideosInPlaylist(_ plylistId: String, completion: @escaping (() -> Void)) {
        SVProgressHUD.show()
        RESTServiceController.sharedInstance()?.syncPlaylist(withId: plylistId) { error in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                guard error == nil else {
                    print("ZypeAppsFlyerHelper syncVideosInPlaylist error", error ?? "")
                    completion()
                    return
                }
                completion()
            }
        }
    }

    // For testing purpose, enable only for debugging purpose, must be disabled for production codebse
    @objc public static func test() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { // in half a second...
            //walkToScene(params: [:]) //home
            //walkToScene(params: ["videoID":"5f2d5022bee00a0001d677ea"]) // video
            //walkToScene(params: ["playlistID":"5d66a97a89382f5c6a52df6a"]) //playlist videos
        }
    }
}

