//
//  ContentView.swift
//  buttonFirebaseGerambia
//
//  Created by JACKSON GERAMBIA on 2/4/26.
//

import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseDatabaseInternal
import FirebaseFirestore
import SwiftUI

struct ContentView: View {

    @State private var buttonColor: Color = .blue

    @State var name = ""
    //@State var score = 0
    @State var displayName = ""

    @State var users = [User]()
    @State var currentUser: User?

    var ref = Database.database().reference()
    
    @State var didLoad = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to Button Clicker")
                    .font(.largeTitle)

                TextField("Enter name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .font(.title)
                    .frame(width: 300)

                Button {

                    login()

                    displayName = name

                } label: {

                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 170, height: 60)
                        Text("Log in")
                            .font(.title)
                            .foregroundStyle(.white)
                    }

                }

                if currentUser != nil {
                    Text("Logged in as \(currentUser?.name ?? "")")
                        .font(.title)
                } else {
                    Text("Not logged in")
                        .font(.title)
                }
                Text("Score: \(currentUser?.score ?? 0)")
                    .font(.title)

                Button {
                    buttonColor = Color(
                        red: Double.random(in: 0...1),
                        green: Double.random(in: 0...1),
                        blue: Double.random(in: 0...1)
                    )

                    guard let user = currentUser else { return }

                    user.score += 1

                    user.updateFirebase(dict: ["score": user.score])

                } label: {
                    Circle()
                        .frame(width: 300)
                        .foregroundStyle(buttonColor)
                }
                .padding(.vertical, 50)

                NavigationLink {
                    LeaderboardView()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 230, height: 60)
                        Text("See Leaderboard")
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                }

            }
        }
        .padding()
        .onAppear {
            if !didLoad {
                firebaseStuff()
                didLoad = true
            }
        }
    }

    // from chatGPT
    func login() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        ref.child("users")
            .queryOrdered(byChild: "name")
            .queryEqual(toValue: name)
            .observeSingleEvent(of: .value) { snapshot in

                if snapshot.exists() {
                    for child in snapshot.children {
                        let snap = child as! DataSnapshot
                        let data = snap.value as! [String: Any]

                        let u = User(stuff: data)
                        u.key = snap.key

                        DispatchQueue.main.async {
                            self.currentUser = u
                        }

                        self.displayName = u.name
                        print("Logged in existing user")
                        return
                    }
                } else {
                    let u = User(name: name, score: 0)
                    u.saveToFirebase()

                    DispatchQueue.main.async {
                        self.currentUser = u
                    }
                    u.score = 0
                    self.displayName = name
                    print("Created new user")
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

                DispatchQueue.main.async {
                    self.users.append(u)
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
                DispatchQueue.main.async {
                    for i in 0..<users.count {
                        if users[i].key == snapshot.key {
                            users[i] = u
                            break
                        }
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

#Preview {
    ContentView()
}

