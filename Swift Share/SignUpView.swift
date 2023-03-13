//
//  SignUpView.swift
//  Swift Share
//
//  Created by Parth Antala on 2023-03-13.
//

import SwiftUI

struct SignUpView: View {
    
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("Enter your details to sign up and experience the new way of sharing files!")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    HStack {
                        Button {
                            
                        } label: {
                            Image(systemName: "person.fill")
                                .font(.system(size: 64))
                                .padding()
                        }
                        
                        TextField("Name", text: $name)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(9)
                    }
                    Group {
                        TextField("Phone", text: $phoneNumber)
                            .keyboardType(.numberPad)
                        TextField("Email", text: $email)
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(9)
                    
                    Button {
                        
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign Up")
                                .foregroundColor(.white)
                                .padding(.vertical, 18)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(Color.blue)
                            .cornerRadius(9)
                    }
                    .padding(20)
                    Spacer()
                    
                }
                .padding(33)
            }
            .navigationTitle("Sign Up")
            .background(Color(.init(white: 0, alpha: 0.05))
            .ignoresSafeArea())
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
