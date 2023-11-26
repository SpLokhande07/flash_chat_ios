//
//  WelcomeViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import CLTypingLabel
import FirebaseAuth

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: CLTypingLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = K.appName;
        Auth.auth().addStateDidChangeListener(
            { auth, user in
                let userData = user
                if userData != nil {
                    self.performSegue(withIdentifier: "IsAlreadyLoggedIn", sender: self)
                }
            }
                                            )
    }
}
