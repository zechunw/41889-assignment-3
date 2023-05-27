//
//  AddViewController.swift
//  AlarmFunction
//
//  Created by Wenjun An on 24/5/2023.
//

import UIKit

class AddViewController: UIViewController {

    @IBOutlet weak var timeLeft: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    
    public var completion: ((String, String, Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))

    }
    
     @objc func didTapSaveButton(){
        let titleText = "You will wake up in:"
           let bodyText = "The Alarm will ring in: \(calculateTime())"
            let targetDate = datePicker.date
            completion?(titleText, bodyText, targetDate)
         navigationController?.popViewController(animated: true)
         
    }
    @IBAction func userinput(_ sender: UIDatePicker) {
        timeLeft.text = "\(calculateTime())"
    }
    
    func calculateTime() -> String{
        let currentDate = Date() // current time
        let targetDate = datePicker.date// Set the target time
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: currentDate, to: targetDate)
        //Set the time format to be displayed
        let remainingTime = "\(components.day ?? 0)Days \(components.hour ?? 0) Hours \(components.minute ?? 0) Mins"
        return remainingTime
        
    }
    
}
