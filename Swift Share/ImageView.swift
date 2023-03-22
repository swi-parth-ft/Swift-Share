//
//  ImageView.swift
//  Swift Share
//
//  Created by Parth Antala on 2023-03-22.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI
import PhotosUI

class ImageViewModel: ObservableObject {
    var chatUser: ChatUser?
    @Published var chatMessages = [ChatMessage]()
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    var firestoreListener: ListenerRegistration?
    
    
    func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        firestoreListener?.remove()
        chatMessages.removeAll()
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                  //  self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            if let cm = try change.document.data(as: ChatMessage?.self) {
                                self.chatMessages.append(cm)
                                print("Appending chatMessage in ChatLogView: \(Date())")
                            }
                        } catch {
                            print("Failed to decode message: \(error)")
                        }
                    }
                })
                
            
            }
    }
}

struct ImageView: View {
    
    
    @ObservedObject var vm: ImageViewModel
    @State private var image: UIImage? = nil
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(vm.chatMessages) { message in
                    
                    Text("\(message.text)")
                    WebImage(url: message.text)
                    
                    Button("save") {
                        savePhoto(url: message.text) { img in
                            self.image = img
                        }
                    }
                    
                    
                    //    print("\(message.text)")
                }
                
                
            }
        }
        
        
        
    }
    
    func savePhoto(url: URL, completion: @escaping (UIImage?) -> Void) {
       

//        do {
//            let imageData = try Data(contentsOf: url)
//            let image = UIImage(data: imageData)!
//
           
//
//        } catch {
//            print("Error downloading image: \(error.localizedDescription)")
//        }
        var image = UIImage()
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let img = UIImage(data: data) {
                completion(img)
                image = img
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            } else {
                completion(nil)
            }
        }.resume()
        
        
        let imageSaver = ImageSaver()
        imageSaver.writeToPhotoAlbum(image: image)
    }
    
    
//    func getImage(url: URL, completion: @escaping (UIImage?) -> Void) {
//            URLSession.shared.dataTask(with: url) { data, response, error in
//                if let data = data, let img = UIImage(data: data) {
//                    completion(img)
//                } else {
//                    completion(nil)
//                }
//            }.resume()
//        }
//
//    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//            if let error = error {
//                print("Error saving image: \(error.localizedDescription)")
//            } else {
//                print("Image saved to Photos library")
//            }
//        }
    
    
}

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
      //  ImageView()
        MainMessagesView()
    }
}
