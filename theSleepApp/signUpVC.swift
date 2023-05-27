//
//  signUpVC.swift
//  signin&signup
//
//  Created by Zechun Wang on 2023/5/8.
//

import UIKit
import CoreData

class signUpVC: UIViewController {

    @IBOutlet weak var accountTF: UITextField!

    @IBOutlet weak var PwdTF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func clickResign(_ sender: Any) {
        // Check if the account number and password are empty
        if accountTF.text == "" || PwdTF.text == "" {
            // Create an instance of UIAlertController as a prompt box
            let alert: UIAlertController = UIAlertController(title: "Tips", message: "Please enter your email, and password", preferredStyle: .alert)

            alert.addAction(UIAlertAction.init(title: "OK", style: .cancel))

            present(alert, animated: true)
            return
        }

        if validateEmail(email: accountTF.text!) {
            // Password length less than 8
            if PwdTF.text!.count < 8 {
                let alert: UIAlertController = UIAlertController(title: "Tips", message: "Please enter a password with more than 8 characters", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .cancel))
                present(alert, animated: true)
                return
            } else {
                // Password length greater than or equal to 8, perform data update operation
                UpdateData()
            }
        } else {
            // Mailbox format verification did not pass
            let alert: UIAlertController = UIAlertController(title: "Tips", message: "The email format is incorrect. Please enter it again", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }

    }

    @IBAction func clickLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func validateEmail(email: String) -> Bool {
        if email.count == 0 {
            return false
        }
        // Define regular expressions for mailbox validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        // Create an instance of NSPredicate for regular expression matching
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        // Regular expression matching via the evaluate(with:) method, and return the matching result
        return emailTest.evaluate(with: email)
    }

    func validatePwd(password: String) -> Bool {
        if password.count == 0 {
            return false
        }
        let pwdRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
        let pwdTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", pwdRegex)
        return pwdTest.evaluate(with: password)
    }

    func UpdateData()
    {
        //Get managed data contexts
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext

        //Request for declaration data
        let fetchRequest = NSFetchRequest<Myuser>(entityName: "Myuser")
        // Limit the number of search results
        fetchRequest.fetchLimit = 30
        // Offset of the query
        fetchRequest.fetchOffset = 0

        // Set the search criteria
        let name = accountTF.text! as String
        let chaxun = "userAccount=" + "'" + name + "'"
        let predicate = NSPredicate(format: chaxun, "")
        fetchRequest.predicate = predicate

        var have = false
        // Query operations
        do {
            let fetchedObjects = try context.fetch(fetchRequest)

            // traverse the results of the query
            for _ in fetchedObjects {
                have = true
            }
            if have {
                alertHaveResign()
            } else {
                // Create the User object
                let user = NSEntityDescription.insertNewObject(forEntityName: "Myuser",
                    into: context) as! Myuser

                // Object assignment
                user.userAccount = name
                user.userPwd = PwdTF.text
                user.userType = "email"
                do {
                    try context.save()
                    resignSuccess()
                } catch {
                    fatalError("save failed：\(error)")
                }
            }
            print(have)
        }
        catch {
            fatalError("not Save：\(error)")
        }
    }

    func alertHaveResign() {
        let alert: UIAlertController = UIAlertController(title: "Tips", message: "The email address has been registered", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel))
        present(alert, animated: true)
    }

    func resignSuccess() {
        //Create an instance of UIAlertController to display a prompt message
        let alert: UIAlertController = UIAlertController(title: "Tips", message: "Account registration succeeded", preferredStyle: .alert)

        // Create an instance of UIAlertAction to indicate that the user has clicked the "OK" button
        let sureAction = UIAlertAction.init(title: "OK", style: .default) { action in
            self.view.endEditing(true)
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(sureAction)

        present(alert, animated: true)
    }
}
