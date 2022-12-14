//
//  FirestoreService.swift
//  Veganny Map
//
//  Created by Hailey on 2022/12/13.
//

import FirebaseFirestore
import FirebaseFirestoreSwift


enum VMEndpoint {
    case User
    case Post
    case Report

    var ref: CollectionReference {
        let db = Firestore.firestore()
        let users = db.collection("User")

        switch self {
        case .User:
            return db.collection("User")
        case .Post:
            return db.collection("Post")
        case .Report:
            return db.collection("Report")
        }
    }
}

struct FirestoreService {

    enum UserList {
        case friendList
        case invitationList
    }

    var subscriptions: [ListenerRegistration] = []

    // MARK: - Methods

//    func listenToUserList(_ userList: UserList, completion: @escaping ([User]) -> Void) {
//        var endpoint: VMEndpoint
//        switch userList {
//        case .friendList:
//            endpoint = .myFriendList
//        case .invitationList:
//            endpoint = .myInvitationList
//        }
//
//        listen(endpoint.ref) { (friends: [Friend]) in
//            guard !friends.isEmpty else {
//                completion([])
//                return
//            }
//
//            let query = FSEndpoint.users.ref.whereField("id", in: friends.map(\.id))
//            getDocuments(query) { (users: [User]) in
//                completion(users)
//            }
//        }
//    }

    func getDocument<T: Decodable>(_ docRef: DocumentReference, completion: @escaping (T?) -> Void) {
        docRef.getDocument { snapshot, error in
            completion(parseDocument(snapshot: snapshot, error: error))
        }
    }


    func getDocuments<T: Decodable>(_ query: Query, completion: @escaping ([T]) -> Void) {
        query.getDocuments { snapshot, error in
            completion(parseDocuments(snapshot: snapshot, error: error))
        }
    }

    func listen<T: Decodable>(_ query: Query, listener: @escaping ([T]) -> Void) {
        query.addSnapshotListener { snapshot, error in
            listener(parseDocuments(snapshot: snapshot, error: error))
        }
    }

    func delete(_ docRef: DocumentReference) {
        docRef.delete()
    }

    func setData(_ documentData: [String : Any], at docRef: DocumentReference) {
        docRef.setData(documentData)
    }

    func setData<T: Encodable>(_ data: T, at docRef: DocumentReference) {
        do {
            try docRef.setData(from: data)
        } catch {
            print("DEBUG: Error encoding \(data.self) data -", error.localizedDescription)
        }
    }

    // MARK: - Private

    private func parseDocument<T: Decodable>(snapshot: DocumentSnapshot?, error: Error?) -> T? {
        guard let snapshot = snapshot, snapshot.exists else {
            let errorMessage = error?.localizedDescription ?? ""
            print("DEBUG: Nil document", errorMessage)
            return nil
        }

        var model: T?
        do {
            model = try snapshot.data(as: T.self)
        } catch {
            print("DEBUG: Error decoding \(T.self) data -", error.localizedDescription)
        }
        return model
    }

    private func parseDocuments<T: Decodable>(snapshot: QuerySnapshot?, error: Error?) -> [T] {
        guard let snapshot = snapshot else {
            let errorMessage = error?.localizedDescription ?? ""
            print("DEBUG: Error fetching snapshot -", errorMessage)
            return []
        }

        var models: [T] = []
        snapshot.documents.forEach { document in
            do {
                let item = try document.data(as: T.self)
                models.append(item)
            } catch {
                print("DEBUG: Error decoding \(T.self) data -", error.localizedDescription)
            }
        }
        return models
    }
}