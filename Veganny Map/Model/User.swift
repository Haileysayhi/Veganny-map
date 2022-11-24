//
//  User.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/7.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth


var userID = getUserID() // 存放登入後的userID

func getUserID() -> String {
    guard let userID = Auth.auth().currentUser?.uid else {
        return ""
    }
    return userID
}

// 使用App的人的資料
struct User: Codable {
    var name: String
    var userPhotoURL: String
    var userId: String // firebase給的 UID
    var email: String
    var postIds: [String] // postIds 等於Post中的很多個postId，使用者可以看全部自己發過的文
    var savedRestaurants: [String] // 存餐廳的placeId
    var blockId: [String] // 儲存使用者封鎖的人的id
}

// 使用App + 有發文的資料
struct Post: Codable {
    var authorId: String // 抓userId，用來抓取發文者的name & photo，利用id資料就不用重複存入
    var postId: String // firebase給的--> 如果按讚人數有改變用id去抓是哪一篇貼文更改
    var content: String
    var mediaType: String // photo, video
    var mediaURL: [String]
    var time: Timestamp // 發文時間
    var likes: [String] // 按讚人的id -->為了讓按讚的人畫面可以顯示已按過讚
    var comments: [Comment]
    var location: String // 存地點
}

enum MediaType: String {
    case photo
    case video
}

struct Comment: Codable {
    var content: String
    var contentType: String
    var userId: String // 用userId 來抓取留言人的name & photo，利用id資料就不用重複存入
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
