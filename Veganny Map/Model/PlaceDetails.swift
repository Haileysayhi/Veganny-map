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
    
    var placeId: String
    var name: String
    var photos: [PhotosResults]
    var reviews: [Reviews]
    var currentOpeningHours: CurrentOpeningHours
    var rating: Double
    var internationalPhoneNumber: String
    var formattedAddress: String
    
    enum CodingKeys: String, CodingKey {
        
        case placeId = "place_id"
        case name
        case photos
        case reviews
        case currentOpeningHours = "current_opening_hours"
        case rating
        case internationalPhoneNumber = "international_phone_number"
        case formattedAddress = "formatted_address"
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
    var rating: Double
    
    enum CodingKeys: String, CodingKey {
        case authorName = "author_name"
        case profilePhotoURL = "profile_photo_url"
        case relativeTimeDescription = "relative_time_description"
        case text
        case time
        case rating
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
