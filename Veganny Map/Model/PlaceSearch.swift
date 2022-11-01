//
//  PlaceSearch.swift
//  Veganny Map
//
//  Created by Hailey on 2022/10/31.
//

import Foundation

// 最外層
struct ListResponse: Decodable {
    var results: [ItemResults]
    var status: String
}

// 裏層
struct ItemResults: Decodable {
    var name: String        // 地標名稱
    var placeId: String     // id （for 抓詳細資料使用）
    var vicinity: String    // 地址
    var geometry: Geometry  //取得餐廳座標
    
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
