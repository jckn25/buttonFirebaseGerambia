//
//  LeaderboardView.swift
//  buttonFirebaseGerambia
//
//  Created by JACKSON GERAMBIA on 2/4/26.
//

import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseFirestore
import SwiftUI

struct LeaderboardView: View {

    @State var users = [User]()

    var ref = Database.database().reference()
    
    @State var didLoad = false

    var body: some View {
        VStack {
            List {
                Text("Leaderboard:")
                    .font(.largeTitle)

                ForEach(users, id: \.key) { user in
                    HStack {
                        Text("\(user.name) - Score: \(user.score)")
                    }
                    .swipeActions {
                        Button {
                            user.deleteFromFirebase()
                        } label: {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 170, height: 60)
                                .backgroundStyle(.red)

                            Text("Delete")
                                .font(.title)
                                .foregroundStyle(.white)
                        }
                    }
                }

            }
        }
        .onAppear {
            if !didLoad {
                firebaseStuff()
                didLoad = true
            }
        }
    }

    func firebaseStuff() {
        ref.child("users").observe(
            .childAdded,
            with: { (snapshot) in

                let d = snapshot.value as? [String: Any]
                let u = User(stuff: d ?? ["": ""])
                u.key = snapshot.key

                if !users.contains(where: { $0.key == u.key }) {
                    DispatchQueue.main.async {
                        users.append(u)
                    }
                }
                print("Add to array")

            }

        )

        ref.child("users").observe(
            .childChanged,
            with: { (snapshot) in
                //creating a new student object with the values
                let u = User(
                    stuff: snapshot.value as? [String: Any] ?? ["": ""]
                )
                //giving it a key
                u.key = snapshot.key

                //finding the student with the same key as the one just created and replaces it
                for i in 0..<users.count {
                    if users[i].key == snapshot.key {
                        DispatchQueue.main.async {
                            users[i] = u
                        }
                        break
                    }
                }

            }

        )

        ref.child("users").observe(
            .childRemoved,
            with: { (snapshot) in

                let k = snapshot.key

                /*for i in 0..<users.count {
                    if users[i].key == k {
                        users.remove(at: i)
                    }
                }*/
                DispatchQueue.main.async {
                    users.removeAll { $0.key == k }
                }

            }

        )

    }

}
