//
//  MainMessagesView.swift
//  LBTASwiftUIFirebaseChat
//
//  Created by Brian Voong on 11/13/21.
//

import SwiftUI
import SDWebImageSwiftUI
import UIKit
import MobileCoreServices

class MainMessagesViewModel: ObservableObject {

    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut = false

    
    init() {
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchCurrentUser()
        fetchAllUsers()
        
        
        
    }
    
    private func fetchAllUsers() {
        FirebaseManager.shared.firestore.collection("users")
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch users: \(error)"
                    print("Failed to fetch users: \(error)")
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let user = try? snapshot.data(as: ChatUser.self)
                    if user?.uid != FirebaseManager.shared.auth.currentUser?.uid {
                        self.users.append(user!)
                    }
                    
                })
//                documentsSnapshot?.documents.forEach({ snapshot in
//                    let data = snapshot.data()
//                    let user = ChatUser(data: data)
//                    if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
//                        self.users.append(.init(data: data))
//                    }
//                })
            }
        print(users)
    }
    
    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return
                
            }
            
            self.chatUser = try? snapshot?.data(as: ChatUser.self)
            FirebaseManager.shared.currentUser = self.chatUser
           // self.chatUser = .init(data: data)
        }
    }
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
        
    }
    
}



struct MainMessagesView: View {
    @EnvironmentObject var loginSignup: LoginSignup
    @State var shouldShowLogOutOptions = false
    @State var shouldNavigateToChatLogView = false
    @State private var isPhotoMode = false
    @ObservedObject private var vm = MainMessagesViewModel()
    @State var shouldShowImagePicker = false
    
    @State private var selectedFile: URL?
  //  let didSelectNewUser: (ChatUser) -> ()
    
 //   let didSelectNewUser: ChatUser
    private var imageViewModel = ImageViewModel(chatUser: nil)
    @State private var selectedPhotoURL: URL?
    
    var body: some View {
        NavigationView {
            
            VStack {
              //  customNavBar
                messagesView
                Spacer()
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ImageView(vm: imageViewModel)
                }
            }
//            .navigationTitle("Recent Shares")
//            .navigationBarTitleDisplayMode(.inline)
         //   .navigationBarHidden(true)
        }
    }
    
    private var customNavBar: some View {
        HStack {
            
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color(.label), lineWidth: 1)
                )
                .shadow(radius: 5)
            
            
            VStack(alignment: .leading, spacing: 4) {
                let email = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                Text(email)
                    .font(.system(size: 24, weight: .bold))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
                
            }
            
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("handle sign out")
                    vm.handleSignOut()
                }),
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
            ContentView(didCompleteLoginProcess: {
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
            })
        }
        
        
    }
    
    private var messagesView: some View {
        
        
        NavigationView {
            VStack {
                Text("Hi, \(vm.chatUser?.name ?? "Pods") 👋")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                        
                        
                        ForEach(vm.users) { user in
                            Menu {
                                Button("Select photo") {
                                    photoMode()
                                 //   didSelectNewUser(user)
                                    persistImageToStorage(user: user)
                                }
                                Button("Select File", action: fileMode)
                              //  shouldShowImagePicker.toggle()
                                Button {
                                   // let uid = FirebaseManager.shared.currentUser?.uid ==
                                    self.chatUser = user
                                    self.imageViewModel.chatUser = self.chatUser
                                    self.imageViewModel.fetchMessages()
                                    self.shouldNavigateToChatLogView = true
                                    
                                } label: {
                                    NavigationLink(destination: ImageView(vm: imageViewModel)) {
                                           Text("Open View")
                                       }
                                }
                                
                            } label: {
                                VStack(spacing: 6) {
                                    WebImage(url: URL(string: user.profileImageUrl))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipped()
                                        .cornerRadius(80)
                                        .shadow(radius: 5)
                                    
                                    Text(user.name)
                                        .foregroundColor(Color.black)
                                }
                                
                            }
                            //                            .contextMenu {
                            //                                Picker(selection: $isPhotoMode, label: Text("Options")) {
                            //                                    Text("Login")
                            //                                        .tag(true)
                            //                                    Text("Create Account")
                            //                                        .tag(false)
                            //                                }
                        }
                        //                        Divider()
                        // .padding(.vertical, 8)
                        
                    }
                
            
                }.navigationTitle("Swift Share")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) {
                            Button() {
                                shouldShowLogOutOptions.toggle()
                            } label: {
                                Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
                        ImagePicker(image: $image)
                    }
                
                
            }
        }
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("handle sign out")
                    vm.handleSignOut()
                }),
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
                ContentView(didCompleteLoginProcess: {
                    self.vm.isUserCurrentlyLoggedOut = false
                    self.vm.fetchCurrentUser()
                })
            
            
        }

    }
    
    @State var shouldShowNewMessageScreen = false
    @State var chatUser: ChatUser?
    @State private var image: UIImage?
    
    func photoMode() {
        shouldShowImagePicker.toggle()
        
    }
    
    func fileMode() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeItem)], in: .import)
                       documentPicker.allowsMultipleSelection = false
                   //    documentPicker.delegate = self
                       UIApplication.shared.windows.first?.rootViewController?.present(documentPicker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            selectedFile = urls.first
        }
    
    //MARK: - saving the image to the firebase
    
    private func persistImageToStorage(user: ChatUser) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
              //  self.loginStatusMessage = "Failed to push image to Storage: \(err)"
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                   // self.loginStatusMessage = "Failed to retrieve downloadURL: \(err)"
                    return
                }
                
              //  self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                print(url?.absoluteString ?? "")
                
                guard let url = url else { return }
                selectedPhotoURL = url
         //      self.storeUserInformation(imageProfileUrl: url)
                
                self.handleSend(user: user, url: selectedPhotoURL!)
            }
        }
    }
    
    //MARK: - handle send
    func handleSend(user: ChatUser, url: URL) {
        //print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let toId = user.uid //else { return }
        
        let document = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()
        
        let msg = ChatMessage(id: nil, fromId: fromId, toId: toId, timestamp: Date(), text: url)
        
        try? document.setData(from: msg) { error in
            if let error = error {
                print(error)
            //    self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            print("Successfully saved current user sending message")
            
         //   self.persistRecentMessage()
            
          //  self.selectedPhotoURL = ""
         //   self.count += 1
        }
        
        let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        try? recipientMessageDocument.setData(from: msg) { error in
            if let error = error {
                print(error)
              // self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            print("Recipient saved message as well")
        }
    }
}




struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        
        MainMessagesView()
    }
}


