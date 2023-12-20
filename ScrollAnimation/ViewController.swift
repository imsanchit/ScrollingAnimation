//
//  ViewController.swift
//  ScrollAnimation
//
//  Created by Sanchit Mittal on 19/12/23.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    private var displayLink: CADisplayLink!
    private var decelerate: Bool = false
    private var startPosition: CGFloat = .zero
    private var velocity: CGFloat = .zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        for i in 0..<10 {
            let label = UILabel()
            label.text = "Test \(i)"
            label.heightAnchor.constraint(equalToConstant: 40).isActive = true
            stackView.addArrangedSubview(label)
        }
        
        displayLink = CADisplayLink(target: self, selector: #selector(step))
        displayLink.add(to: .current, forMode: .default)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        stackView.addGestureRecognizer(panGesture)
    }
    
    deinit {
        displayLink.invalidate()
    }
    
    @objc func step(displayLink: CADisplayLink) {
        decelerate(displayLink: displayLink)
    }
    
    @objc
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            decelerate = false
            displayLink.isPaused = false
            startPosition = topConstraint.constant
            
        case .changed:
            topConstraint.constant = min(startPosition + recognizer.translation(in: recognizer.view).y, 0)
            velocity = recognizer.velocity(in: recognizer.view).y
            
        case .ended:
            decelerate = true
            
        default:
            return
        }
    }
    
    func decelerate(displayLink: CADisplayLink) {
        if decelerate {
            let friction: CGFloat = 0.9
            let delayTime = displayLink.targetTimestamp - displayLink.timestamp
            let fps = 1 / delayTime

            let updatedValue = topConstraint.constant + self.velocity / CGFloat(fps)
            topConstraint.constant = min(0, updatedValue)
            self.velocity *= friction
        }
    }
}

