//
//  FirestoreService.swift
//  Veganny Map
//
//  Created by Hailey on 2022/12/13.
//

import FirebaseFirestore
import FirebaseFirestoreSwift


enum VMEndpoint {
    case user
    case post
    case report

    var ref: CollectionReference {
        let db = Firestore.firestore()

        switch self {
        case .user:
            return db.collection("User")
        case .post:
            return db.collection("Post")
        case .report:
            return db.collection("Report")
        }
    }
}

class FirestoreService {
    static let shared = FirestoreService()
    var subscriptions: [ListenerRegistration] = []

    // MARK: - Methods

    func getDocument<T: Decodable>(_ docRef: DocumentReference, completion: @escaping (T?) -> Void) {
        docRef.getDocument { snapshot, error in
            completion(self.parseDocument(snapshot: snapshot, error: error))
        }
    }


    func getDocuments<T: Decodable>(_ query: Query, completion: @escaping ([T]) -> Void) {
        query.getDocuments { snapshot, error in
            completion(self.parseDocuments(snapshot: snapshot, error: error))
        }
    }

    func listen<T: Decodable>(_ docRef: DocumentReference, listener: @escaping (T?) -> Void) {
        docRef.addSnapshotListener { snapshot, error in
            listener(self.parseDocument(snapshot: snapshot, error: error))
        }
    }

    func delete(_ docRef: DocumentReference) {
        docRef.delete()
    }

    func setData(_ documentData: [String: Any], at docRef: DocumentReference) {
        docRef.setData(documentData)
    }

    func setData<T: Encodable>(_ data: T, at docRef: DocumentReference) {
        do {
            try docRef.setData(from: data)
        } catch {
            print("DEBUG: Error encoding \(data.self) data -", error.localizedDescription)
        }
    }
    
    func setDataMerge(_ documentData: [String: Any], at docRef: DocumentReference) {
        docRef.setData(documentData, merge: true)
    }
    
    func arrayRemove(_ docRef: DocumentReference, field: String, value: Any ) {
        docRef.updateData([
            field : FieldValue.arrayRemove([value])
        ])
    }
    
    func arrayUnion(_ docRef: DocumentReference, field: String, value: Any ) {
        docRef.updateData([
            field : FieldValue.arrayUnion([value])
        ])
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
