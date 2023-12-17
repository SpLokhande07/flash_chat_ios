//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    var db = Firestore.firestore()
    var messages : [Message] = [
//    Message(sender: "test1@gmail.com", body: "Hi"),
//    Message(sender: "test2@gmail.com", body: "Hello"),
//    Message(sender: "test1@gmail.com", body: "What's up?")
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        title = K.appName
        navigationItem.hidesBackButton = true;
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

          //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
          //tap.cancelsTouchesInView = false
          view.addGestureRecognizer(tap)
        loadMessage()
      }
    
    
    func loadMessage(){
      
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { querySnapshot, error in
                self.messages = []
            if let e = error {
                print("Something went wrong while retriving data \(e)")
            }
            else{
               
                if let snapshotDocument = querySnapshot?.documents{
                   
                    for doc in snapshotDocument {
                        let data = doc.data()
                        if let messageSender = data[K.FStore.senderField] as?  String , let messageBody = data[K.FStore.bodyField] as?  String {
                            let newMessage = Message(sender: messageSender, body: messageBody )
                            self.messages.append(newMessage)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count-1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)

                            }
                            
                        }
                    }
                }
            }
        }
    }

      //Calls this function when the tap is recognized.
      @objc func dismissKeyboard() {
          //Causes the view (or one of its embedded text fields) to resign the first responder status.
          view.endEditing(true)
      }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
       if let messsageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email
        {
           db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField: messageSender, K.FStore.bodyField: messsageBody,
                                                                     K.FStore.dateField: Date().timeIntervalSince1970
                                                                    ]){(error) in
               if let e = error {
                   print("There was an error \(e)")
               }else{
                   print("Successfully save data")
                   DispatchQueue.main.async {
                       self.messageTextfield.text = ""
            
                   }
               }
           }}
    }
    @IBAction func logoutPresed(_ sender: UIBarButtonItem) {
        let auth = Auth.auth()
        do {
            try auth.signOut()
            Auth.auth().removeStateDidChangeListener(self)
            navigationController?.popToRootViewController(animated: true)
        }catch let signOutError as NSError {
            print("Error",signOutError);
        }
        
    }
}
 
extension ChatViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label?.text = message.body
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageLabel.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        } else{
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageLabel.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
            }
//        let indexPath = IndexPath(row: messages.count-1, section: 0)
//        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
return cell
    }
}

extension ChatViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
