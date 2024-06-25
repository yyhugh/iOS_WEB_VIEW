//
//  ViewController.swift
//  iOS_WKWebView
//
//  Created by H on 6/25/24.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {

    var webView: WKWebView!
    var refreshControl: UIRefreshControl!

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        
        // 设置允许文件 URL 之间的跨域访问
        webConfiguration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        if #available(iOS 10.0, *) {
            webConfiguration.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        }
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.backgroundColor = UIColor(hex: "#181818")
        webView.isOpaque = false
        webView.isInspectable = true // 开启调试
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 获取本地 index.html 文件的路径
        if let filePath = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "web") {
            let fileURL = URL(fileURLWithPath: filePath)
            let directoryURL = fileURL.deletingLastPathComponent()
            webView.loadFileURL(fileURL, allowingReadAccessTo: directoryURL)
        } else {
            print("Error: Cannot find index.html file")
        }

        // 添加从左到右的滑动手势识别器
        let swipeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGestureRecognizer.edges = .left
        view.addGestureRecognizer(swipeGestureRecognizer)

        // 添加下拉刷新控件到 WKWebView 的 scrollView
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)
    }

    @objc func handleSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        if gesture.state == .recognized {
            if webView.canGoBack {
                webView.goBack()
            } else {
                print("No page to go back to")
            }
        }
    }
    
    @objc func refreshWebView() {
        webView.reload()
        refreshControl.endRefreshing()
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

