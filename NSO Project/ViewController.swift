//
//  ViewController.swift
//  NSO Project
//
//  Created by Fahmi Alfareza on 25/10/19.
//  Copyright © 2019 CV. Karya Studio Teknologi Digital. All rights reserved.
//

import UIKit
import WebKit
import NVActivityIndicatorView

class ViewController: UIViewController, WKNavigationDelegate, UIScrollViewDelegate {

    @IBOutlet weak var webView: WKWebView!
    private var activityIndicatorContainer: UIView!
    private var activityIndicator: UIActivityIndicatorView!
    private var loading: NVActivityIndicatorView!
    let refreshControl = UIRefreshControl()
    let webConfiguration = WKWebViewConfiguration()
    let source: String = "var meta = document.createElement('meta');" +
        "meta.name = 'viewport';" +
        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
        "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let url = URL(string: "https://m.nsoproject.com")
        let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_1_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.1 Mobile/15E148 Safari/604.1"
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        self.refreshControl.addTarget(self, action: #selector(reloadWebView(_:)), for: .valueChanged)
        webView.scrollView.delegate = self
        webView.scrollView.addSubview(self.refreshControl)
        webView.configuration.userContentController.addUserScript(script)
        webView.customUserAgent = userAgent
        webView.load(URLRequest(url: url!))
    }
    
    @objc func reloadWebView(_ sender: UIRefreshControl) {
        webView.reload()
        sender.endRefreshing()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
    
    fileprivate func setActivityIndicator() {
        // Configure the background containerView for the indicator
        activityIndicatorContainer = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        activityIndicatorContainer.center.x = webView.center.x
        // Need to subtract 44 because WebKitView is pinned to SafeArea
        //   and we add the toolbar of height 44 programatically
        activityIndicatorContainer.center.y = webView.center.y - 44
        activityIndicatorContainer.backgroundColor = UIColor.black
        activityIndicatorContainer.alpha = 0.8
        activityIndicatorContainer.layer.cornerRadius = 10
      
        // Configure the activity indicator
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorContainer.addSubview(activityIndicator)
        webView.addSubview(activityIndicatorContainer)
        
        // Constraints
        activityIndicator.centerXAnchor.constraint(equalTo: activityIndicatorContainer.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: activityIndicatorContainer.centerYAnchor).isActive = true
    }
    
    fileprivate func showActivityIndicator(show: Bool) {
      if show {
        activityIndicator.startAnimating()
      } else {
        activityIndicator.stopAnimating()
        activityIndicatorContainer.removeFromSuperview()
      }
    }
    
    fileprivate func startAnimation() {
        self.loading = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: .black, padding: 0)
        self.loading.translatesAutoresizingMaskIntoConstraints = false
        webView.addSubview(self.loading)
        NSLayoutConstraint.activate([
            self.loading.widthAnchor.constraint(equalToConstant: 40),
            self.loading.heightAnchor.constraint(equalToConstant: 40),
            self.loading.centerYAnchor.constraint(equalTo: webView.centerYAnchor),
            self.loading.centerXAnchor.constraint(equalTo: webView.centerXAnchor)
        ])
        
        self.loading.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        self.showActivityIndicator(show: false)
//        DispatchQueue.main.async {
//            self.loading.stopAnimating()
//        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Set the indicator everytime webView started loading
//        self.setActivityIndicator()
//        self.showActivityIndicator(show: true)
//        startAnimation()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        self.showActivityIndicator(show: false)
//        DispatchQueue.main.async {
//            self.loading.stopAnimating()
//        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//        self.showActivityIndicator(show: false)
//        DispatchQueue.main.async {
//            self.loading.stopAnimating()
//        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url?.absoluteString
        if ((url?.contains("/download/downloadPDFEvent/"))!) {
            // Do the downloading operation here
            let downloadUrl = navigationAction.request.url
            UIApplication.shared.canOpenURL(downloadUrl!)
            UIApplication.shared.open(downloadUrl!)
            // FileDownloader.loadFileSync(url: downloadUrl!) { (path, error) in
            //    print("PDF File downloaded to : \(path!)")
            // }
            
            // Block the webview to load a new url
            decisionHandler(.cancel);
            return;
        } else if ((url?.contains("gojek://"))!) {
            // Do the downloading operation here
            let gojekUrl = navigationAction.request.url
            UIApplication.shared.canOpenURL(gojekUrl!)
            UIApplication.shared.open(gojekUrl!)
            // FileDownloader.loadFileSync(url: downloadUrl!) { (path, error) in
            //    print("PDF File downloaded to : \(path!)")
            // }
            
            // Block the webview to load a new url
            decisionHandler(.cancel);
            return;
        } else if ((url?.contains("https://app.midtrans.com/snap/v1/transactions/"))! && (url?.contains("/pdf"))! ) {
            // Do the downloading operation here
            let pdfUrl = navigationAction.request.url
            UIApplication.shared.canOpenURL(pdfUrl!)
            UIApplication.shared.open(pdfUrl!)
            // FileDownloader.loadFileSync(url: downloadUrl!) { (path, error) in
            //    print("PDF File downloaded to : \(path!)")
            // }
            
            // Block the webview to load a new url
            decisionHandler(.cancel);
            return;
        } else if (!(url?.contains("nsoproject.com"))! && !(url?.contains("accounts.google.com"))!) {
            // Do the downloading operation here
            let otherUrl = navigationAction.request.url
            UIApplication.shared.canOpenURL(otherUrl!)
            UIApplication.shared.open(otherUrl!)
            // FileDownloader.loadFileSync(url: downloadUrl!) { (path, error) in
            //    print("PDF File downloaded to : \(path!)")
            // }
            
            // Block the webview to load a new url
            decisionHandler(.cancel);
            return;
        }
        decisionHandler(.allow);
    }
}
