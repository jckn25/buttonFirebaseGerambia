//
//  User.swift
//  buttonFirebaseGerambia
//
//  Created by JACKSON GERAMBIA on 2/4/26.
//

import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseFirestore
import Foundation
import SwiftUI

class User {
    var name: String
    var score: Int
    var ref = Database.database().reference()
    var key = ""

    init(name: String, score: Int) {
        self.name = name
        self.score = score

    }

    //this will allow us to build objects from firebase
    init(stuff: [String: Any]) {
        if let n = stuff["name"] as? String {
            name = n
        } else {
            name = ""
        }

        if let s = stuff["score"] as? Int {
            score = s
        } else {
            score = 0
        }

    }

    func saveToFirebase() {
        //creating the dictionary
        let dict = ["name": name, "score": score] as [String: Any]

        //saving the dictionary to firebase
        //ref.child("users").childByAutoId().setValue(dict)
        let newRef = ref.child("users").childByAutoId()
        newRef.setValue(dict)
        self.key = newRef.key ?? ""

    }

    func deleteFromFirebase() {
        ref.child("users").child(key).removeValue()

    }

    func updateFirebase(dict: [String: Any]) {
        ref.child("users").child(key).updateChildValues(dict)
    }
}
