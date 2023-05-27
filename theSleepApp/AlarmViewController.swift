//
//  ViewController.swift
//  AlarmFunction
//
//  Created by Wenjun An on 24/5/2023.
//
import UserNotifications
import UIKit

class AlarmViewController: UIViewController {
    
    @IBOutlet var table: UITableView!
    var models = [MyAlarm]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        // Do any additional setup after loading the view.
    }
    @IBAction func returnToMainViewController() {
        navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func didTapAdd(){
        //display add viewcontroller
        guard let vc = storyboard?.instantiateViewController(identifier: "add") as? AddViewController else{
            return
        }
        vc.title = "New Alarm"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = {title, body, date in
            DispatchQueue.main.async {
                //convert date to string
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let dateString = dateFormatter.string(from: date)
                
                //Encapsulate the objects in the alarm clock list
                let new = MyAlarm(title: dateString, time: body, identifier: "id_\(title)")
                self.models.append(new)
                self.table.reloadData()
                
                // create a custom alert sound
                let soundName = UNNotificationSoundName("alarmSound")
                let alarmMusic = UNNotificationSound(named: soundName)
                
                //Initialize the reminder, add parameters to fill in the Notification object
                let content = UNMutableNotificationContent()
                content.title = "Your Alarm at: \(title)" //The title of the Notification
                content.sound = alarmMusic //The sound of the Notification
                content.body = "Good morning, hope you can have a beautiful day!" //The body of the Notification
                
                //Reminder time setting
                let targetDate = date
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],from: targetDate),
                                    repeats: false)
                let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request,withCompletionHandler: {error in
                    if error != nil {
                        print("something going wrong")
                    }
                })
                
            }
        }
        //display of the Notification
        navigationController? .pushViewController(vc, animated: true)
    }
    @IBAction func didTapTest(){
        //testing notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {success, error in
            if success{
                    //schedule test
                self.scheduleTest()
            }
            else if error != nil {
                print("user didn't agree the authority")
            }
        })
    }
    
    func scheduleTest() {
        let soundName = UNNotificationSoundName("alarmSound.mp3")
        let alarmMusic = UNNotificationSound(named: soundName)
        
        
        let content = UNMutableNotificationContent()
        content.title = "The Alarm"
        content.sound = alarmMusic
        content.body = "Good morning, hope you can have a beautiful day!"
    
        let targetDate = Date().addingTimeInterval(5)
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],from: targetDate),
                            repeats: false)
        let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request,withCompletionHandler: {error in
            if error != nil {
                print("something going wrong")
            }
        })
    }
    
}

extension AlarmViewController: UITableViewDelegate {
    
    func tableView(_ tablevView: UITableView,didSelectRowAt indexPath: IndexPath){
        tablevView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                // Delete the corresponding data item from the data source
                models.remove(at: indexPath.row)
                
                // delete the cell in the table
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    
}
    
extension AlarmViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tablevView: UITableView,cellForRowAt indexPath: IndexPath) ->UITableViewCell{
        
        //retrieve data
        let cell = tablevView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let alarm = models[indexPath.row]
        
        //Add data to the label of the table
        cell.textLabel?.text = alarm.title
        cell.detailTextLabel?.text = alarm.time

        return cell
    }
    

}

    
struct MyAlarm {
        let title: String
        let time: String
        let identifier: String
}



    

