//
//  TextViewVC.swift
//  TestLink
//
//  Created by Pritesh Pethani on 24/01/17.
//  Copyright © 2017 Pritesh Pethani. All rights reserved.
//

import UIKit

class TextViewVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate {
  
  @IBOutlet var tableTextview: UITableView!
  
  @IBOutlet var myWebView: UIWebView!
  
    @IBOutlet var nslcTopView: NSLayoutConstraint!
    @IBOutlet var topView: UIView!
    var filePath:String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableTextview.register(UINib(nibName: "TexiViewCell", bundle: nil), forCellReuseIdentifier: "TexiViewCell1")
    
    
    let targetURL = NSURL(string: filePath) // This value is force-unwrapped for the sake of a compact example, do not do this in your code
    if (targetURL != nil){
      let request = NSURLRequest(url: targetURL as! URL)
      myWebView.loadRequest(request as URLRequest)
    }
    self.view.addSubview(myWebView)
    
    // Do any additional setup after loading the view.
  }
  
    override func viewDidLayoutSubviews() {
        
        Utility.set_TopLayout_VesionRelated(nslcTopView, topView, self)
    }
    
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - UIWebView Delegate Methods
  
  func webViewDidStartLoad(_ webView: UIWebView) {
    print("webViewDidStartLoad")
  }
  
  func webViewDidFinishLoad(_ webView: UIWebView) {
    print("webViewDidFinishLoad")
  }
  
  // MARK: - UITableView Delegate Methods
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: TexiViewCell? = tableTextview.dequeueReusableCell(withIdentifier: "TexiViewCell1") as! TexiViewCell?
    return cell!
  }
  
  @IBAction func btnBackliked(_ sender: UIButton) {
    _ = self.navigationController?.popViewController(animated: true)
  }
  
}
