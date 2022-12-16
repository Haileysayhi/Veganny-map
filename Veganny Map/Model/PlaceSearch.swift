//
//  PlaceSearch.swift
//  Veganny Map
//
//  Created by Hailey on 2022/10/31.
//

import Foundation


struct ListResponse: Decodable {
    var results: [ItemResult]
    var status: String
}


struct ItemResult: Decodable {
    var name: String
    var placeId: String     // id （for 抓詳細資料使用）
    var vicinity: String    // 地址
    var geometry: Geometry  // 取得餐廳座標
    
    enum CodingKeys: String, CodingKey {
        case name
        case placeId = "place_id"
        case vicinity
        case geometry
    }
}

struct Geometry: Codable {
    var location: Location
}

struct Location: Codable {
    var lat: Double
    var lng: Double
}
