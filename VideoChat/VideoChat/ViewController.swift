//
//  ViewController.swift
//  VideoChat
//
//  Created by Start4me on 29/01/18.
//  Copyright © 2018 Start4me. All rights reserved.
//

import UIKit
import OpenTok
class ViewController: UIViewController {

    
    // Replace with your OpenTok API key
    var kApiKey = "46048372"
    // Replace with your generated session ID
    var kSessionId = "2_MX40NjA0ODM3Mn5-MTUxNzIxMDY1MTQ1NX5tVGJHdjY3bWdlNDNsaEJYWGdDdzJpLzV-fg"
    // Replace with your generated token
    var kToken = "T1==cGFydG5lcl9pZD00NjA0ODM3MiZzaWc9Nzc4ZTJlYWYyODhhZjQwMGMwMjAwOTE4MGIwMDg2YWFlM2MwMzdhNzpzZXNzaW9uX2lkPTJfTVg0ME5qQTBPRE0zTW41LU1UVXhOekl4TURZMU1UUTFOWDV0VkdKSGRqWTNiV2RsTkROc2FFSllXR2REZHpKcEx6Vi1mZyZjcmVhdGVfdGltZT0xNTE3MjEwNjc3Jm5vbmNlPTAuODc5MTk4MjkwNjgzNzc1NCZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNTE3MjE0Mjc2JmluaXRpYWxfbGF5b3V0X2NsYXNzX2xpc3Q9"
    
    var session: OTSession?
    var publisher: OTPublisher?
    var subscriber: OTSubscriber?


    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectToAnOpenTokSession()

        // Do any additional setup after loading the view, typically from a nib.
    }

    func connectToAnOpenTokSession() {
        session = OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)
        var error: OTError?
        session?.connect(withToken: kToken, error: &error)
        if error != nil {
            print(error!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

// MARK: - OTSessionDelegate callbacks
extension ViewController: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("The client connected to the OpenTok session.")
        
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        guard let publisher = OTPublisher(delegate: self, settings: settings) else {
            return
        }
        
        var error: OTError?
        session.publish(publisher, error: &error)
        guard error == nil else {
            print(error!)
            return
        }
        
        guard let publisherView = publisher.view else {
            return
        }
        let screenBounds = UIScreen.main.bounds
        publisherView.frame = CGRect(x: screenBounds.width - 150 - 20, y: screenBounds.height - 150 - 20, width: 150, height: 150)
        view.addSubview(publisherView)
        
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("The client disconnected from the OpenTok session.")
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("The client failed to connect to the OpenTok session: \(error).")
    }
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("A stream was created in the session.")
        subscriber = OTSubscriber(stream: stream, delegate: self as! OTSubscriberKitDelegate)
        guard let subscriber = subscriber else {
            return
        }
        
        var error: OTError?
        session.subscribe(subscriber, error: &error)
        guard error == nil else {
            print(error!)
            return
        }
        
        guard let subscriberView = subscriber.view else {
            return
        }
        subscriberView.frame = UIScreen.main.bounds
        view.insertSubview(subscriberView, at: 0)
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("A stream was destroyed in the session.")
    }
}

// MARK: - OTPublisherDelegate callbacks
extension ViewController: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("The publisher failed: \(error)")
    }
}

// MARK: - OTSubscriberDelegate callbacks
extension ViewController: OTSubscriberDelegate {
    public func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
        print("The subscriber did connect to the stream.")
    }
    
    public func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("The subscriber failed to connect to the stream.")
    }
}

