//
//  PlaceDetails.swift
//  Veganny Map
//
//  Created by Hailey on 2022/10/31.
//

import Foundation

struct DetailResponse: Codable {
    var result: InfoResult
}

struct InfoResult: Codable {
    var name: String                // 餐廳名稱
    var photos: [PhotosResults]     // 照片
    var reviews: [Reviews]          // 評論
    var currentOpeningHours: CurrentOpeningHours // 營業資訊
    var rating: Double
    var internationalPhoneNumber: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case photos
        case reviews
        case currentOpeningHours = "current_opening_hours"
        case rating
        case internationalPhoneNumber = "international_phone_number"
    }
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

struct CurrentOpeningHours: Codable {
    let openNow: Bool
    let weekdayText: [String]

    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
        case weekdayText = "weekday_text"
    }
}
