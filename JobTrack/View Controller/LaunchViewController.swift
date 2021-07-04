//
//  LaunchViewController.swift
//  JobTrack
//
//  Created by Arjun Dureja on 2020-08-08.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(named: "Logo")
        view.addSubview(imageView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.center = view.center

        // Animate after 0.3 seconds
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.animate()
        }
    }

    // Zoom in logo and fade away
    func animate() {
        // Zooming by 3x
        UIView.animate(withDuration: 1) {
            let size = self.view.frame.size.width * 3
            let diffX = size - self.view.frame.size.width
            let diffY = self.view.frame.size.height - size

            self.imageView.frame = CGRect(x: -(diffX/2), y: diffY/2, width: size, height: size)
        }

        // Fading and presenting home VC
        UIView.animate(withDuration: 1.5, animations: {
            self.imageView.alpha = 0
        }, completion: { [weak self] done in
            if done {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                    let mainST = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let vc = mainST.instantiateViewController(withIdentifier: "TabBar")
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true)
                }
            }
        })
    }

}
