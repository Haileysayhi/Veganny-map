//
//  PlaceSearchModel.swift
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
    /// id -> 抓詳細資料使用
    var placeId: String
    /// 地址
    var vicinity: String
    /// 取得餐廳座標
    var geometry: Geometry
    
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
