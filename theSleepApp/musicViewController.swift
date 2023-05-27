import UIKit
import AVFoundation

class musicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var table: UITableView!

    var songs = [Song]()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSongs()
        table.delegate = self
        table.dataSource = self
    }

    func configureSongs() {
        songs.append(Song(name: "1",
                          albumName: "Light Music",
                          artistName: "Good Night",
                          imageName: "cover1",
                          trackName: "1"))
        songs.append(Song(name: "2",
                          albumName: "Light Music",
                          artistName: "Good Night",
                          imageName: "cover2",
                          trackName: "2"))
        songs.append(Song(name: "3",
                          albumName: "Light Music",
                          artistName: "Good Night",
                          imageName: "cover3",
                          trackName: "3"))
        songs.append(Song(name: "4",
                          albumName: "Light Music",
                          artistName: "Good Night",
                          imageName: "cover1",
                          trackName: "4"))
        songs.append(Song(name: "5",
                          albumName: "Light Music",
                          artistName: "Good Night",
                          imageName: "cover2",
                          trackName: "5"))
        songs.append(Song(name: "6",
                          albumName: "Light Music",
                          artistName: "Good Night",
                          imageName: "cover3",
                          trackName: "6"))
        songs.append(Song(name: "7",
                          albumName: "Light Music",
                          artistName: "Good Night",
                          imageName: "cover1",
                          trackName: "7"))
    }

    // Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let song = songs[indexPath.row]
        // configure
        cell.textLabel?.text = song.name
        cell.detailTextLabel?.text = song.albumName
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = UIImage(named: song.imageName)
        cell.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 18)
        cell.detailTextLabel?.font = UIFont(name: "Helvetica", size: 17)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // present the player
        let position = indexPath.row
        guard let vc = storyboard?.instantiateViewController(identifier: "player") as? PlayerViewController else {
            return
        }
        vc.songs = songs
        vc.position = position
        present(vc, animated: true)
    }


}

struct Song {
    let name: String
    let albumName: String
    let artistName: String
    let imageName: String
    let trackName: String
}
