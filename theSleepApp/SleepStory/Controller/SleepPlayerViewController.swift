//
//  SleepSleepPlayerViewController.swift
//  Music Player
//
//  Created by Brian on 23/5/2023.

import AVFoundation
import MediaPlayer
import UIKit

extension UIImageView {
    func setRounded() {
        let radius = frame.width / 2
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
}

class SleepPlayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
    // Choose background here. Between 1 - 7
    let selectedBackground = 1
    
    var audioPlayer: AVAudioPlayer!
    var currentAudio = ""
    var currentAudioPath: URL!
    var audioList: NSArray!
    var currentAudioIndex = 0
    var timer: Timer!
    var audioLength = 0.0
    var toggle = true
    var effectToggle = true
    var totalLengthOfAudio = ""
    var finalImage: UIImage!
    var isTableViewOnscreen = false
    var shuffleState = false
    var repeatState = false
    var shuffleArray = [Int]()
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var songNo: UILabel!
    @IBOutlet var lineView: UIView!
    @IBOutlet var albumArtworkImageView: UIImageView!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var albumNameLabel: UILabel!
    @IBOutlet var songNameLabel: UILabel!
    @IBOutlet var songNameLabelPlaceHolder: UILabel!
    @IBOutlet var progressTimerLabel: UILabel!
    @IBOutlet var playerProgressSlider: UISlider!
    @IBOutlet var totalLengthOfAudioLabel: UILabel!
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var listButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var blurImageView: UIImageView!
    @IBOutlet var enhancer: UIView!
    @IBOutlet var tableViewContainer: UIView!
    
    @IBOutlet var shuffleButton: UIButton!
    @IBOutlet var repeatButton: UIButton!
    
    @IBOutlet var blurView: UIVisualEffectView!
    
    @IBOutlet var tableViewContainerTopConstrain: NSLayoutConstraint!
    
    // MARK: - Lockscreen Media Control
    
    // This shows media info on lock screen - used currently and perform controls
    func showMediaInfo() {
        let artistName = readArtistNameFromPlist(currentAudioIndex)
        let songName = readSongNameFromPlist(currentAudioIndex)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist: artistName, MPMediaItemPropertyTitle: songName]
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        if event!.type == UIEvent.EventType.remoteControl {
            switch event!.subtype {
            case UIEvent.EventSubtype.remoteControlPlay:
                play(self)
            case UIEvent.EventSubtype.remoteControlPause:
                play(self)
            case UIEvent.EventSubtype.remoteControlNextTrack:
                next(self)
            case UIEvent.EventSubtype.remoteControlPreviousTrack:
                previous(self)
            default:
                print("There is an issue with the control")
            }
        }
    }
    
    // MARK: -
    
    // Table View Part of the code. Displays Song name and Artist Name

    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var songNameDict = NSDictionary()
        songNameDict = audioList.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        let songName = songNameDict.value(forKey: "songName") as! String
        
        var albumNameDict = NSDictionary()
        albumNameDict = audioList.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        let albumName = albumNameDict.value(forKey: "albumName") as! String
        
        var albumArtworkDict = NSDictionary()
        albumArtworkDict = audioList.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        let albumArtwork = albumArtworkDict.value(forKey: "albumArtwork") as! String
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.font = UIFont(name: "BodoniSvtyTwoITCTT-BookIta", size: 25.0)
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.text = songName
        
        cell.detailTextLabel?.font = UIFont(name: "BodoniSvtyTwoITCTT-Book", size: 16.0)
        cell.detailTextLabel?.textColor = UIColor.darkGray
        cell.detailTextLabel?.text = albumName
        cell.imageView?.image = UIImage(named: albumArtwork)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.backgroundColor = UIColor.clear
        
        let backgroundView = UIView(frame: CGRect.zero)
        backgroundView.backgroundColor = UIColor.clear
        cell.backgroundView = backgroundView
        cell.backgroundColor = UIColor.clear
    }
    
    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        animateTableViewToOffScreen()
        currentAudioIndex = (indexPath as NSIndexPath).row
        prepareAudio()
        playAudio()
        effectToggle = !effectToggle
        let showList = UIImage(named: "list")
        let removeList = UIImage(named: "listS")
        listButton.setImage(effectToggle ? showList : removeList, for: UIControl.State())
        let play = UIImage(named: "play")
        let pause = UIImage(named: "pause")
        playButton.setImage(audioPlayer.isPlaying ? pause : play, for: UIControl.State())
        
        blurView.isHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    override var prefersStatusBarHidden: Bool {
        if isTableViewOnscreen {
            return true
        } else {
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sleep Story"
        // assing background
        backgroundImageView.image = UIImage(named: "background\(selectedBackground)")
        
        // this sets last listened trach number as current
        retrieveSavedTrackNumber()
        prepareAudio()
        updateLabels()
        assingSliderUI()
        setRepeatAndShuffle()
        retrievePlayerProgressSliderValue()
        // LockScreen Media control registry
        if UIApplication.shared.responds(to: #selector(UIApplication.beginReceivingRemoteControlEvents)) {
            UIApplication.shared.beginReceivingRemoteControlEvents()
            UIApplication.shared.beginBackgroundTask(expirationHandler: { () -> Void in
            })
        }
    }

    func setRepeatAndShuffle() {
        shuffleState = UserDefaults.standard.bool(forKey: "shuffleState")
        repeatState = UserDefaults.standard.bool(forKey: "repeatState")
        if shuffleState == true {
            shuffleButton.isSelected = true
        } else {
            shuffleButton.isSelected = false
        }
        
        if repeatState == true {
            repeatButton.isSelected = true
        } else {
            repeatButton.isSelected = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableViewContainerTopConstrain.constant = 1000.0
        tableViewContainer.layoutIfNeeded()
        blurView.isHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        albumArtworkImageView.setRounded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - AVAudioPlayer Delegate's Callback method

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag == true {
            if shuffleState == false, repeatState == false {
                // do nothing
                playButton.setImage(UIImage(named: "play"), for: UIControl.State())
                return
            
            } else if shuffleState == false, repeatState == true {
                // repeat same song
                prepareAudio()
                playAudio()
            
            } else if shuffleState == true, repeatState == false {
                // shuffle songs but do not repeat at the end
                // Shuffle Logic : Create an array and put current song into the array then when next song come randomly choose song from available song and check against the array it is in the array try until you find one if the array and number of songs are same then stop playing as all songs are already played.
                shuffleArray.append(currentAudioIndex)
                if shuffleArray.count >= audioList.count {
                    playButton.setImage(UIImage(named: "play"), for: UIControl.State())
                    return
                }
                
                var randomIndex = 0
                var newIndex = false
                while newIndex == false {
                    randomIndex = Int(arc4random_uniform(UInt32(audioList.count)))
                    if shuffleArray.contains(randomIndex) {
                        newIndex = false
                    } else {
                        newIndex = true
                    }
                }
                currentAudioIndex = randomIndex
                prepareAudio()
                playAudio()
            
            } else if shuffleState == true, repeatState == true {
                // shuffle song endlessly
                shuffleArray.append(currentAudioIndex)
                if shuffleArray.count >= audioList.count {
                    shuffleArray.removeAll()
                }
                
                var randomIndex = 0
                var newIndex = false
                while newIndex == false {
                    randomIndex = Int(arc4random_uniform(UInt32(audioList.count)))
                    if shuffleArray.contains(randomIndex) {
                        newIndex = false
                    } else {
                        newIndex = true
                    }
                }
                currentAudioIndex = randomIndex
                prepareAudio()
                playAudio()
            }
        }
    }
    
    // Sets audio file URL
    func setCurrentAudioPath() {
        currentAudio = readSongNameFromPlist(currentAudioIndex)
        currentAudioPath = URL(fileURLWithPath: Bundle.main.path(forResource: currentAudio, ofType: "mp3")!)
        print("\(String(describing: currentAudioPath))")
    }
    
    func saveCurrentTrackNumber() {
        UserDefaults.standard.set(currentAudioIndex, forKey: "currentAudioIndex")
        UserDefaults.standard.synchronize()
    }
    
    func retrieveSavedTrackNumber() {
        if let currentAudioIndex_ = UserDefaults.standard.object(forKey: "currentAudioIndex") as? Int {
            currentAudioIndex = currentAudioIndex_
        } else {
            currentAudioIndex = 0
        }
    }

    // Prepare audio for playing
    func prepareAudio() {
        setCurrentAudioPath()
        do {
            // keep alive audio at background
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)))
        } catch _ {}
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {}
        UIApplication.shared.beginReceivingRemoteControlEvents()
        audioPlayer = try? AVAudioPlayer(contentsOf: currentAudioPath)
        audioPlayer.delegate = self
        audioLength = audioPlayer.duration
        playerProgressSlider.maximumValue = CFloat(audioPlayer.duration)
        playerProgressSlider.minimumValue = 0.0
        playerProgressSlider.value = 0.0
        audioPlayer.prepareToPlay()
        showTotalSongLength()
        updateLabels()
        progressTimerLabel.text = "00:00"
    }
    
    // MARK: - Player Controls Methods

    func playAudio() {
        audioPlayer.play()
        startTimer()
        updateLabels()
        saveCurrentTrackNumber()
        showMediaInfo()
    }
    
    func playNextAudio() {
        currentAudioIndex += 1
        if currentAudioIndex > audioList.count-1 {
            currentAudioIndex = 0
        }
        if audioPlayer.isPlaying {
            prepareAudio()
            playAudio()
        } else {
            prepareAudio()
        }
    }
    
    func playPreviousAudio() {
        currentAudioIndex -= 1
        if currentAudioIndex < 0 {
            currentAudioIndex = audioList.count-1
        }
        if audioPlayer.isPlaying {
            prepareAudio()
            playAudio()
        } else {
            prepareAudio()
        }
    }
    
    func stopAudiplayer() {
        audioPlayer.stop()
    }
    
    func pauseAudioPlayer() {
        audioPlayer.pause()
    }
    
    // MARK: -
    
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SleepPlayerViewController.update(_:)), userInfo: nil, repeats: true)
            timer.fire()
        }
    }
    
    deinit {
        if timer != nil {
            timer.invalidate()
        }
    }
    
    func stopTimer() {
        if timer != nil {
            timer.invalidate()
        }
    }
    
    @objc func update(_ timer: Timer) {
        if !audioPlayer.isPlaying {
            return
        }
        let time = calculateTimeFromNSTimeInterval(audioPlayer.currentTime)
        progressTimerLabel.text = "\(time.minute):\(time.second)"
        playerProgressSlider.value = CFloat(audioPlayer.currentTime)
        UserDefaults.standard.set(playerProgressSlider.value, forKey: "playerProgressSliderValue")
    }
    
    func retrievePlayerProgressSliderValue() {
        let playerProgressSliderValue = UserDefaults.standard.float(forKey: "playerProgressSliderValue")
        if playerProgressSliderValue != 0 {
            playerProgressSlider.value = playerProgressSliderValue
            audioPlayer.currentTime = TimeInterval(playerProgressSliderValue)
            
            let time = calculateTimeFromNSTimeInterval(audioPlayer.currentTime)
            progressTimerLabel.text = "\(time.minute):\(time.second)"
            playerProgressSlider.value = CFloat(audioPlayer.currentTime)
            
        } else {
            playerProgressSlider.value = 0.0
            audioPlayer.currentTime = 0.0
            progressTimerLabel.text = "00:00:00"
        }
    }

    // This returns song length
    func calculateTimeFromNSTimeInterval(_ duration: TimeInterval) -> (minute: String, second: String) {
        // let hour_   = abs(Int(duration)/3600)
        let minute_ = abs(Int((duration / 60).truncatingRemainder(dividingBy: 60)))
        let second_ = abs(Int(duration.truncatingRemainder(dividingBy: 60)))
        
        // var hour = hour_ > 9 ? "\(hour_)" : "0\(hour_)"
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        return (minute, second)
    }
    
    func showTotalSongLength() {
        calculateSongLength()
        totalLengthOfAudioLabel.text = totalLengthOfAudio
    }
    
    func calculateSongLength() {
        let time = calculateTimeFromNSTimeInterval(audioLength)
        totalLengthOfAudio = "\(time.minute):\(time.second)"
    }
    
    // Read plist file and creates an array of dictionary
    func readFromPlist() {
        let path = Bundle.main.path(forResource: "list", ofType: "plist")
        audioList = NSArray(contentsOfFile: path!)
    }
    
    func readArtistNameFromPlist(_ indexNumber: Int) -> String {
        readFromPlist()
        var infoDict = NSDictionary()
        infoDict = audioList.object(at: indexNumber) as! NSDictionary
        let artistName = infoDict.value(forKey: "artistName") as! String
        return artistName
    }
    
    func readAlbumNameFromPlist(_ indexNumber: Int) -> String {
        readFromPlist()
        var infoDict = NSDictionary()
        infoDict = audioList.object(at: indexNumber) as! NSDictionary
        let albumName = infoDict.value(forKey: "albumName") as! String
        return albumName
    }

    func readSongNameFromPlist(_ indexNumber: Int) -> String {
        readFromPlist()
        var songNameDict = NSDictionary()
        songNameDict = audioList.object(at: indexNumber) as! NSDictionary
        let songName = songNameDict.value(forKey: "songName") as! String
        return songName
    }
    
    func readArtworkNameFromPlist(_ indexNumber: Int) -> String {
        readFromPlist()
        var infoDict = NSDictionary()
        infoDict = audioList.object(at: indexNumber) as! NSDictionary
        let artworkName = infoDict.value(forKey: "albumArtwork") as! String
        return artworkName
    }

    func updateLabels() {
        updateArtistNameLabel()
        updateAlbumNameLabel()
        updateSongNameLabel()
        updateAlbumArtwork()
    }
    
    func updateArtistNameLabel() {
        let artistName = readArtistNameFromPlist(currentAudioIndex)
        artistNameLabel.text = artistName
    }

    func updateAlbumNameLabel() {
        let albumName = readAlbumNameFromPlist(currentAudioIndex)
        albumNameLabel.text = albumName
    }
    
    func updateSongNameLabel() {
        let songName = readSongNameFromPlist(currentAudioIndex)
        songNameLabel.text = songName
    }
    
    func updateAlbumArtwork() {
        let artworkName = readArtworkNameFromPlist(currentAudioIndex)
        albumArtworkImageView.image = UIImage(named: artworkName)
    }
    
    // creates animation and push table view to screen
    func animateTableViewToScreen() {
        blurView.isHidden = false
        UIView.animate(withDuration: 0.15, delay: 0.01, options:
            UIView.AnimationOptions.curveEaseIn, animations: {
                self.tableViewContainerTopConstrain.constant = 0.0
                self.tableViewContainer.layoutIfNeeded()
            }, completion: { _ in
            })
    }
    
    func animateTableViewToOffScreen() {
        isTableViewOnscreen = false
        setNeedsStatusBarAppearanceUpdate()
        tableViewContainerTopConstrain.constant = 1000.0
        UIView.animate(withDuration: 0.20, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.tableViewContainer.layoutIfNeeded()
            
        }, completion: {
            (_: Bool) in
            self.blurView.isHidden = true
        })
    }
    
    func assingSliderUI() {
        let minImage = UIImage(named: "slider-track-fill")
        let maxImage = UIImage(named: "slider-track")
        let thumb = UIImage(named: "thumb")

        playerProgressSlider.setMinimumTrackImage(minImage, for: UIControl.State())
        playerProgressSlider.setMaximumTrackImage(maxImage, for: UIControl.State())
        playerProgressSlider.setThumbImage(thumb, for: UIControl.State())
    }
    
    @IBAction func play(_ sender: AnyObject) {
        if shuffleState == true {
            shuffleArray.removeAll()
        }
        let play = UIImage(named: "play")
        let pause = UIImage(named: "pause")
        if audioPlayer.isPlaying {
            pauseAudioPlayer()
        } else {
            playAudio()
        }
        playButton.setImage(audioPlayer.isPlaying ? pause : play, for: UIControl.State())
    }
    
    @IBAction func next(_ sender: AnyObject) {
        playNextAudio()
    }
    
    @IBAction func previous(_ sender: AnyObject) {
        playPreviousAudio()
    }
    
    @IBAction func changeAudioLocationSlider(_ sender: UISlider) {
        audioPlayer.currentTime = TimeInterval(sender.value)
    }
    
    @IBAction func userTapped(_ sender: UITapGestureRecognizer) {
        play(self)
    }
    
    @IBAction func userSwipeLeft(_ sender: UISwipeGestureRecognizer) {
        next(self)
    }
    
    @IBAction func userSwipeRight(_ sender: UISwipeGestureRecognizer) {
        previous(self)
    }
    
    @IBAction func userSwipeUp(_ sender: UISwipeGestureRecognizer) {
        presentListTableView(self)
    }
    
    @IBAction func shuffleButtonTapped(_ sender: UIButton) {
        shuffleArray.removeAll()
        if sender.isSelected == true {
            sender.isSelected = false
            shuffleState = false
            UserDefaults.standard.set(false, forKey: "shuffleState")
        } else {
            sender.isSelected = true
            shuffleState = true
            UserDefaults.standard.set(true, forKey: "shuffleState")
        }
    }

    @IBAction func repeatButtonTapped(_ sender: UIButton) {
        if sender.isSelected == true {
            sender.isSelected = false
            repeatState = false
            UserDefaults.standard.set(false, forKey: "repeatState")
        } else {
            sender.isSelected = true
            repeatState = true
            UserDefaults.standard.set(true, forKey: "repeatState")
        }
    }
    
    @IBAction func presentListTableView(_ sender: AnyObject) {
        if effectToggle {
            isTableViewOnscreen = true
            setNeedsStatusBarAppearanceUpdate()
            animateTableViewToScreen()
            
        } else {
            animateTableViewToOffScreen()
        }
        effectToggle = !effectToggle
        let showList = UIImage(named: "list")
        let removeList = UIImage(named: "listS")
        listButton.setImage(effectToggle ? showList : removeList, for: UIControl.State())
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}
