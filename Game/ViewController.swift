//
//  ViewController.swift
//  Game
//
//  Created by Abby Allen on 4/3/20.
//  Copyright © 2020 Seth Palmer. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var resume: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resume.isEnabled = false
    }
    
}
