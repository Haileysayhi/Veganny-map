//
//  User.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/7.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/// 存放登入後的userID
var userID = getUserID()

func getUserID() -> String {
    guard let userID = Auth.auth().currentUser?.uid else {
        return ""
    }
    return userID
}

/// App使用者的資料
struct User: Codable {
    var name: String
    var userPhotoURL: String
    /// firebase給的 UID
    var userId: String
    var email: String
    /// 發布的貼文Id
    var postIds: [String]
    /// 存餐廳的placeId
    var savedRestaurants: [String]
    /// 存使用者封鎖的人的id
    var blockId: [String]
}

/// 使用App + 有發文的資料
struct Post: Codable {
    /// 抓userId，用來抓取發文者的name & photo，利用id資料就不用重複存入
    var authorId: String
    /// firebase給的 -> 如果按讚人數有改變用id去抓是哪一篇貼文更改
    var postId: String
    var content: String
    /// photo, video
    var mediaType: String
    var mediaURL: [String]
    /// 發文時間
    var time: Timestamp
    /// 按讚人的id -->為了讓按讚的人畫面可以顯示已按過讚
    var likes: [String]
    var comments: [Comment]
    /// 存地點名稱
    var location: String
    /// 存地點Id
    var placeId: String
}

enum MediaType: String {
    case photo
    case video
}

struct Comment: Codable {
    var content: String
    var contentType: String
    /// 用userId 來抓取留言人的name & photo，利用id資料就不用重複存入
    var userId: String
    var time: Timestamp
}

enum ContentType: String {
    case text
    case photo
    case video
}

struct Report: Codable {
    var userId: String
    var postId: String
    var time: Timestamp
}
