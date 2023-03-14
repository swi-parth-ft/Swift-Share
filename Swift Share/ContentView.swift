//
//  ContentView.swift
//  Swift Share
//
//  Created by Parth Antala on 2023-03-13.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    Text("Welcome to Swift Share")
                        .font(.title)
                        .foregroundColor(.blue)
                    Text("file sharing, reimagined")
                        .italic()
                        .foregroundColor(.orange)
                    
                    Group {
                        TextField("Email", text: $email)
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(9)
                    
                    Button {
                        loginUser()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign In")
                                .foregroundColor(.white)
                                .padding(.vertical, 18)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(Color.blue)
                            .cornerRadius(9)
                    }
                    .padding(20)
                    Spacer()
                    
                    HStack {
                        Text("New User?")
                        NavigationLink {
                            SignUpView()
                        } label: {
                            Text("Sign Up")
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(33)
            }
            .navigationTitle("Sign In")
            .background(Color(.init(white: 0, alpha: 0.05))
            .ignoresSafeArea())
        }
      //  .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
                   if let err = err {
                       print("Failed to login user:", err)
                       return
                   }
                   print("Successfully logged in as user: \(result?.user.uid ?? "")")
               }
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
