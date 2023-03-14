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
    
   
    @State var shouldShowImagePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("Enter your details to sign up and experience the new way of sharing files!")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    HStack {
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 124, height: 124)
                                        .cornerRadius(64)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                            }
                            //                            .overlay(RoundedRectangle(cornerRadius: 64)
                            //                                .stroke(Color.black, lineWidth: 3)
                            //                            )
                            
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
                .padding(20)
                Spacer()
                    Spacer()
                
            }
            .padding(33)
            .navigationTitle("Sign Up")
            
        }
            .navigationViewStyle(StackNavigationViewStyle())
            .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
                ImagePicker(image: $image)
            }
            .background(Color(.init(white: 0, alpha: 0.05))
                .ignoresSafeArea())
            
            
    }
       
    }
    @State private var image: UIImage?
    
    private func createNewAccount() {
         FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
             if let err = err {
                 print("Failed to create user:", err)
                 return
             }
             
             print("Successfully created user: \(result?.user.uid ?? "")")
            
             
             self.persistImageToStorage()
         }
     }
    
    private func persistImageToStorage() {
//        let filename = UUID().uuidString
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
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
                
             //   self.didCompleteLoginProcess()
            }
    }
}
    

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
