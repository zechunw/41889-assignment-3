//
//  ViewController.swift
//  signin_signup
//
//  Created by Zechun Wang on 2023/5/7.
//

import UIKit
import CoreData

class SignViewController: UIViewController {

    @IBOutlet weak var accountTF: UITextField!

    @IBOutlet weak var pwdTF: UITextField!
    var UserDataAry: NSMutableArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        pwdTF.isSecureTextEntry = true
    }

    @IBAction func clickLogIn(_ sender: Any) {
        self.view.endEditing(true)
        //Check if the text content of the mailbox and password input box is empty
        if accountTF.text == "" || pwdTF.text == "" {
            //Create a UIAlertController prompt box
            let alert: UIAlertController = UIAlertController(title: "Tips", message: "Please enter your email, and password", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }

        if validateEmail(email: accountTF.text!) {
            // If the email is valid
            if pwdTF.text!.count < 8 {
                //If the password has less than 8 characters
                let alert: UIAlertController = UIAlertController(title: "Tips", message: "Please enter a password with more than 8 characters", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .cancel))
                present(alert, animated: true)
                return
            } else {
                // If the password has 8 or more characters
                UpdateData()
            }
        } else {
            // If the email is invalid
            let alert: UIAlertController = UIAlertController(title: "Tips", message: "The email format is incorrect. Please enter it again", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }

    }

    @IBAction func clickResign(_ sender: Any) {
        self.performSegue(withIdentifier: "signUp", sender: nil)
    }

    func validateEmail(email: String) -> Bool {
        // Check if the email string is empty
        if email.count == 0 {
            return false
        }
        // Regular expression pattern for validating email format
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        // Create a predicate with the email regex pattern
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        //Evaluate the predicate with the email string
        return emailTest.evaluate(with: email)
    }

    func UpdateData()
    {
        //Get the managed data context
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext

        //Request for declaration data
        let fetchRequest = NSFetchRequest<Myuser>(entityName: "Myuser")
        //Limit the number of search results
        fetchRequest.fetchLimit = 30
        //Offset of the query
        fetchRequest.fetchOffset = 0

        //Set the search criteria
        let name = accountTF.text! as String
        let chaxun = "userAccount=" + "'" + name + "'"
        let predicate = NSPredicate(format: chaxun, "")
        fetchRequest.predicate = predicate
        UserDataAry = NSMutableArray()
        //Enquiry operations
        do {
            // Trying to execute a query request from Core Data
            let fetchedObjects = try context.fetch(fetchRequest)

            // Add the query results to the UserDataAry array
            UserDataAry.addObjects(from: fetchedObjects)

            // Check the number of query results
            if UserDataAry.count > 0 {
                // Get the first user data object
                let indexData: Myuser = UserDataAry[0] as! Myuser

                // Check that the password entered by the user matches the password in the database
                if indexData.userPwd == pwdTF.text {
                    loginSuccess()
                } else {
                    // Incorrect password, prompt message displayed
                    remindtipWithStr(remindTip: "The password is incorrect, please re-enter it")
                }
            } else {
                // The query result is empty and a message is displayed
                remindtipWithStr(remindTip: "The account is not registered, please register first")
            }
        }
        catch {
            fatalError("not Save：\(error)")
        }
    }

    func loginSuccess() {
        // Create an instance of UIAlertController as a prompt box
        let alert: UIAlertController = UIAlertController(title: "Tips", message: "Login success", preferredStyle: .alert)

        let sureAction = UIAlertAction.init(title: "OK", style: .default) { action in

            self.performSegue(withIdentifier: "showHomeVC", sender: nil)
        }
        alert.addAction(sureAction)

        present(alert, animated: true)
    }

    func remindtipWithStr(remindTip: String) {
        let alert: UIAlertController = UIAlertController(title: "Tips", message: remindTip, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel))
        present(alert, animated: true)
    }

}

