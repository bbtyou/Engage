//
//  RootNavigationController.swift
//  Engage
//
//  Created by Charles Imperato on 11/21/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit

class RootNavigationController: UINavigationController {

    weak var loginPresenter: LoginPresenter? {
        didSet {
            if let loginView = self.viewControllers.first as? LoginViewController {
                loginView.presenter = self.loginPresenter
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let loginView = self.viewControllers.first as? LoginViewController {
            loginView.presenter = self.loginPresenter
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
