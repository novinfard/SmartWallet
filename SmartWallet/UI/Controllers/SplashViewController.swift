//
//  SplashViewController.swift
//  SmartWallet
//
//  Created by Soheil on 28/04/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import UIKit
import AVFoundation

class SplashViewController: UIViewController {

	var avPlayer: AVPlayer!
	var avPlayerLayer: AVPlayerLayer!
	var paused: Bool = false

	@IBAction func startPressed(_ sender: Any) {
		UserDefaults.standard.set(true, forKey: "introduced")
		dismiss(animated: true)
	}

	override func viewDidLoad() {

		let theURL = Bundle.main.url(forResource: "intro", withExtension: "mp4")

		avPlayer = AVPlayer(url: theURL!)
		avPlayerLayer = AVPlayerLayer(player: avPlayer)
		avPlayerLayer.videoGravity = .resizeAspectFill
		avPlayer.volume = 0
		avPlayer.actionAtItemEnd = .none

		avPlayerLayer.frame = view.layer.bounds
		view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
		view.layer.insertSublayer(avPlayerLayer, at: 0)

		NotificationCenter.default.addObserver(self,
											   selector: #selector(playerItemDidReachEnd(notification:)),
											   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
											   object: avPlayer.currentItem)

		// set observer for UIApplicationWillEnterForeground
		NotificationCenter.default.addObserver(self,
											   selector: #selector(willEnterForeground),
											   name: UIApplication.willEnterForegroundNotification,
											   object: nil)

	}

	@objc func playerItemDidReachEnd(notification: Notification) {
		if let player = notification.object as? AVPlayerItem {
			player.seek(to: CMTime.zero)
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		avPlayer.play()
		paused = false
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		avPlayer.pause()
		paused = true
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		avPlayer.play()
		paused = false
	}

	@objc func willEnterForeground() {
		if self.viewIfLoaded?.window != nil {
			avPlayer.play()
			paused = false
		}
	}
}
