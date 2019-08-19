import UIKit
import Foundation

//Creates a highscore view, with UserDefaults to save the highscore

class PopoverHighscore: UIViewController {
    
    @IBOutlet var scoreView: UIView!
    @IBOutlet var playAgainView: UIView!
    @IBOutlet var highscoreLabel: UILabel!
    @IBOutlet var currentScoreLabel: UILabel!
    var senderVC : GameViewController! = nil
    let defaults = UserDefaults()
    
    
    override func viewDidLoad() {
        
        
        scoreView.clipsToBounds = true
        scoreView.layer.cornerRadius = 171.5
        scoreView.layer.shadowColor = UIColor.black.cgColor
        scoreView.layer.shadowOpacity = 0.6
        scoreView.layer.shadowRadius = 15
        scoreView.layer.shadowOffset = CGSize(width: 5, height: 5)
        
        playAgainView.clipsToBounds = true
        playAgainView.layer.cornerRadius = 15
        
        if defaults.object(forKey: "highscore") != nil
        {
            if senderVC.points > defaults.object(forKey: "highscore") as! Int
            {
                defaults.set(senderVC.points, forKey: "highscore")
            }
        }
        else
        {
            defaults.set(senderVC.points, forKey: "highscore")
        }
        
        highscoreLabel.text = "Highscore : \(defaults.object(forKey: "highscore") as! Int)"
        currentScoreLabel.text = "You earned \(senderVC.points) points!"
        
        
    }

    @IBAction func playAgainAction(_ sender: AnyObject)
    {
        self.dismiss(animated: true, completion: nil)
        senderVC.unwindFromSecondary()
        senderVC.points = 0
        senderVC.pointsLabel.text = "Points: 0"
        senderVC.round = 0
        senderVC.roundLabel.text = "Round 1/5"
        senderVC.getNewLocation()
        if senderVC.interstitial.isReady
        {
            senderVC.interstitial.present(fromRootViewController: senderVC)
            senderVC.createAndLoadInterstitial()
        }
        else
        {
            print("notready")
        }
        
    }
    
}
