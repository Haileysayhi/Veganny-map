//
//  GoogleMapListController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/10/31.
//

import Foundation
import UIKit

class GoogleMapListController {
    static let key = "AIzaSyC8IQNR378ak19gj7fEHbuQoU4txNS6jic"
    static var shared = GoogleMapListController()
    
    // Place Search - NearbySearch
    /*  location: 經緯度
     radius： 範圍(公尺)
     keyword：搜尋關鍵字
     language：語言
     key：個人的api key */
    
    func fetchNearbySearch(location: String, keyword: String, completion: @escaping (ListResponse?) -> Void) {
        print("===\(location)")
        if let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location)&radius=30000&keyword=\(keyword)&language=zh-TW&key=\(GoogleMapListController.key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                error == nil {
                    do {
                        let decoder = JSONDecoder()
                        completion(try decoder.decode(ListResponse.self, from: data))
                    } catch {
                        completion(nil)
                    }
                } else {
                    print("ERROR: \(error)")
                }
            }.resume()
        } else {
            print("URL Failed!")
        }
    }
    
    // Place Details - Place Details Requests
    func fetchPlaceDetail(placeId: String, completion: @escaping (DetailResponse?) -> Void) {
        if let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeId)&language=zh-TW&key=\(GoogleMapListController.key)") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                error == nil {
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .secondsSince1970 // 時間
                        completion(try decoder.decode(DetailResponse.self, from: data))
                    } catch {
                        print(error)
                        completion(nil)
                    }
                } else {
                    print(error)
                }
            }.resume()
        }
    }
    
    // Get profile_photo_urlImageView from Place Details
    func getPhoto(url: String, completion: @escaping (UIImage?) -> Void) {
        if let url = URL(string: url) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                error == nil {
                    completion(UIImage(data: data))
                } else {
                    print(error)
                }
            }.resume()
        }
    }
}
