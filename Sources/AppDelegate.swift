import UIKit
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ a: UIApplication, didFinishLaunchingWithOptions o: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = WebVC()
        window?.makeKeyAndVisible()
        return true
    }
}

class WebVC: UIViewController, WKUIDelegate, WKNavigationDelegate {
    var web: WKWebView!
    override var prefersStatusBarHidden: Bool { true }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1)
        let c = WKWebViewConfiguration()
        c.allowsInlineMediaPlayback = true
        c.mediaTypesRequiringUserActionForPlayback = []

        c.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        web = WKWebView(frame: view.bounds, configuration: c)
        web.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        web.uiDelegate = self; web.navigationDelegate = self
        web.scrollView.contentInsetAdjustmentBehavior = .never
        web.isOpaque = false
        web.backgroundColor = .clear
        web.scrollView.backgroundColor = .clear
        view.addSubview(web)
        if let u = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "www") {
            web.loadFileURL(u, allowingReadAccessTo: u.deletingLastPathComponent())
        }
    }
    @available(iOS 15.0, *)
    func webView(_ w: WKWebView, requestMediaCapturePermissionFor o: WKSecurityOrigin, initiatedByFrame f: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) { decisionHandler(.grant) }
    func webView(_ w: WKWebView, runJavaScriptAlertPanelWithMessage m: String, initiatedByFrame f: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let a = UIAlertController(title: nil, message: m, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        present(a, animated: true)
    }
    func webView(_ w: WKWebView, decidePolicyFor n: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let u = n.request.url, ["tel","mailto","sms"].contains(u.scheme ?? "") { UIApplication.shared.open(u); decisionHandler(.cancel); return }
        if n.navigationType == .linkActivated, let u = n.request.url, ["http","https"].contains(u.scheme ?? "") { UIApplication.shared.open(u); decisionHandler(.cancel); return }
        decisionHandler(.allow)
    }
}
