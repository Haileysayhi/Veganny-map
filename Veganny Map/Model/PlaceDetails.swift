//
//  PlaceDetails.swift
//  Veganny Map
//
//  Created by Hailey on 2022/10/31.
//

import Foundation

struct DetailResponse: Codable {
    var result: InfoResults
}

struct InfoResults: Codable {
    var name: String                // 餐廳名稱
    var photos: [PhotosResults]     // 照片
    var reviews: [Reviews]          // 評論
}

struct PhotosResults: Codable {
    var photoReference: String
    
    enum CodingKeys: String, CodingKey {
        case photoReference = "photo_reference"
    }
}

struct Reviews: Codable {
    var authorName: String
    var profilePhotoURL: String
    var relativeTimeDescription: String
    var text: String
    var time: Date
    
    enum CodingKeys: String, CodingKey {
        case authorName = "author_name"
        case profilePhotoURL = "profile_photo_url"
        case relativeTimeDescription = "relative_time_description"
        case text
        case time
    }
}
