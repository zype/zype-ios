//
//  ZypeAppsFlyerHelper.swift
//  Zype
//
//  Created by Anish Kumar on 12/08/20.
//  Copyright © 2020 Zype. All rights reserved.
//

import Foundation

@objc public class ZypeAppsFlyerHelper: NSObject {
    
    //MARK: To get app iTunes id and app name

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
                    let appName = "\(((resultDictionary.object(forKey: "results") as? NSArray)?.object(at: 0) as? NSDictionary)?.object(forKey: "trackCensoredName"))"
                    let appId = "\(((resultDictionary.object(forKey: "results") as? NSArray)?.object(at: 0) as?  NSDictionary)?.object(forKey: "trackId"))"
                    print("AppName : \(appName) \nAppId: \(appId)")
                    completetion(appId)
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
}
