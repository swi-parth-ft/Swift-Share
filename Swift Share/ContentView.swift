//
//  ContentView.swift
//  Swift Share
//
//  Created by Parth Antala on 2023-03-13.
//

import SwiftUI
import Firebase
import Foundation


class LoginSignup: ObservableObject {
    @Published var yesLogIn = true
}


struct ContentView: View {
    @State private var isPhotoMode = false
    @State private var isLogInMode = true
    let didCompleteLoginProcess: () -> ()
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUpView = false
    
    
    @State private var name = ""
    @State private var phoneNumber = ""
//    @State private var email = ""
//    @State private var password = ""
    @EnvironmentObject var loginSignup: LoginSignup
    @ObservedObject private var vm = MainMessagesViewModel()
    @State var shouldShowImagePicker = false
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        NavigationView {
            
            ScrollView {
                VStack {
                    Text("Swift Share")
                        .font(.title)
                        .bold()
                    Text("file sharing, reimagined")
                        .foregroundColor(.orange)
                        .italic()
                }
                if isLogInMode {
                    VStack {
                        
                        Text("Welcome,")
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.secondary)
                            
                            
                        Text("Please enter your email and password to continue")
                            .foregroundColor(.secondary)
                        
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
                            
                            Button("Sign Up") {
                                withAnimation {
                                    isLogInMode.toggle()
                                }
                            }
                            .opacity(1.0)
                            .animation(.easeOut(duration: 1.5))
//                            .sheet(isPresented: $showSignUpView) {
//                                SignUpView(didCompleteSignUpProcess: {
//
//                                })
                  //          }
                            //                        NavigationLink {
                            //                            SignUpView()
                            //                        } label: {
                            //                            Text("Sign Up")
                            //                                .foregroundColor(.orange)
                            //                        }
                        }
                    }
                    .padding(33)
                } else {
                    VStack {
                        Text("Enter your details to sign up and experience the new way of sharing files!")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Button {
                                shouldShowImagePicker.toggle()
                               
                                
                            } label: {
                                VStack {
                                    if let image = self.image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 64, height: 64)
                                            .cornerRadius(32)
                                    } else {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 32))
                                            .padding()
                                            .foregroundColor(Color(.label))
                                    }
                                }
                                
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
                            createNewAccount()
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
                        
                        VStack {
                            Text("Already have an account?")
                            Button("back to Log In") {
                                withAnimation {
                                    isLogInMode.toggle()
                                }
                            }
                            .opacity(1.0)
                            .animation(.easeOut(duration: 1.5))
//                            .sheet(isPresented: $showSignUpView) {
//                                SignUpView(didCompleteSignUpProcess: {
//
//                                })
//                            }
                            //                        NavigationLink {
                            //                            SignUpView()
                            //                        } label: {
                            //                            Text("Sign Up")
                            //                                .foregroundColor(.orange)
                            //                        }
                        }
                        
                        .padding(20)
                        Spacer()
                        Spacer()
                        
                    }
                    .padding(33)
                }
            }
//            .navigationTitle("Swift Share")
            .background(Color(.init(white: 0, alpha: 0.05))
                .ignoresSafeArea())
            .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
                ImagePicker(image: $image)
            }
            //  .navigationViewStyle(StackNavigationViewStyle())
        }
        
    }
    
    @State private var image: UIImage?
        
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
                   if let err = err {
                       print("Failed to login user:", err)
                       return
                   }
                   print("Successfully logged in as user: \(result?.user.uid ?? "")")
            loginSignup.yesLogIn = true
            self.didCompleteLoginProcess()
               }
    }
    
    private func createNewAccount() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to create user:", err)
                return
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            loginSignup.yesLogIn = false
            
            self.persistImageToStorage()
        }
    }
    
    private func persistImageToStorage() {
        //        let filename = UUID().uuidString
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 1) else { return }
        print(imageData)
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                //  self.loginStatusMessage = "Failed to push image to Storage: \(err)"
                print(err)
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                    //  self.loginStatusMessage = "Failed to retrieve downloadURL: \(err)"
                    print(err)
                    return
                }
                
                //  self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                print(url?.absoluteString)

                guard let url = url else { return }
                self.storeUserInformation(imageProfileUrl: url)
            }
        }
    }
    
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["email": self.email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString, "name": name, "phoneNumber": phoneNumber]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    return
                }
                
                print("Success")
                loginSignup.yesLogIn = false
                self.didCompleteLoginProcess()
                loginSignup.yesLogIn = false
                
               
              
            }
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(didCompleteLoginProcess: {
            
        })
    }
}
