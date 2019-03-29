////
////  ClassifyViewController.swift
////  Visual Recognition
////
////  Created by Nicholas Bourdakos on 7/17/17.
////  Copyright © 2017 Nicholas Bourdakos. All rights reserved.
////
//
//import UIKit
//import AVFoundation
//import VisualRecognitionV3
//
//
//
//class ClassifyViewController: UIViewController, AKPickerViewDelegate, AKPickerViewDataSource {
//
//    @IBOutlet var tempImageView: UIImageView!
//
//    // All the buttons.
//    @IBOutlet var classifiersButton: UIButton!
//    @IBOutlet var retakeButton: UIButton!
//    @IBOutlet var apiKeyDoneButton: UIButton!
//    @IBOutlet var apiKeySubmit: UIButton!
//    @IBOutlet var apiKeyLogOut: UIButton!
//    @IBOutlet var apiKeyTextField: UITextField!
//    @IBOutlet var hintTextView: UITextView!
//
//    @IBOutlet var pickerView: AKPickerView!
//
//    let visualRecognition: VisualRecognition? = {
//        guard let apiKey = UserDefaults.standard.string(forKey: "api_key") else {
//            return nil
//        }
//        return VisualRecognition(version: VisualRecognitionConstants.version, apiKey: apiKey)
//    }()
//
//    // Blurred effect for the API key form.
//    let blurredEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
//
//    var classifiers = [Classifier]()
//    var select = -1
//
//    override open func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        guard let drawer = parent as? PulleyViewController else {
//            return
//        }
//
//        var apiKeyText = "🔑 API Key"
//        if let apiKey = UserDefaults.standard.string(forKey: "api_key") {
//            apiKeyText = obscureKey(key: apiKey)
//            loadClassifiers()
//        }
//
//        let apiKeyInput = UIButton()
//
//        // Set the title to be the size of the navigation bar so we can click anywhere.
//        apiKeyInput.frame.size.width = (drawer.navigationController?.navigationBar.frame.width)!
//        apiKeyInput.frame.size.height = (drawer.navigationController?.navigationBar.frame.height)!
//
//        // Style the API text.
//        apiKeyInput.layer.shadowOffset = CGSize(width: 0, height: 1)
//        apiKeyInput.layer.shadowOpacity = 0.2
//        apiKeyInput.layer.shadowRadius = 5
//        apiKeyInput.layer.masksToBounds = false
//        apiKeyInput.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
//        apiKeyInput.setAttributedTitle(NSAttributedString(string: apiKeyText, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.strokeColor : UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0), NSAttributedString.Key.strokeWidth : -0.5]), for: .normal)
//
//        let recognizer = UITapGestureRecognizer(target: self, action: #selector(addApiKey))
//        drawer.navigationItem.titleView = apiKeyInput
//        drawer.navigationItem.titleView?.isUserInteractionEnabled = true
//        drawer.navigationItem.titleView?.addGestureRecognizer(recognizer)
//    }
//
//    func loadClassifiers() {
//        print("loading classifiers")
//        let readyClassifiers = classifiers.filter({ $0.status == "ready" })
//        for (index, item) in readyClassifiers.enumerated() {
//            if item.classifierID == UserDefaults.standard.string(forKey: "classifier_id") {
//                select = index
//            } else if item.classifierID == String() && item.name == UserDefaults.standard.string(forKey: "classifier_id") {
//                select = index
//            }
//        }
//
//        pickerView.selectItem(min(select, classifiers.count - 1))
//
//        // Load from Watson.
//        guard let visualRecognition = self.visualRecognition else {
//            classifiers = []
//            pickerView.selectItem(-1)
//            pickerView.reloadData()
//            return
//        }
//
//        visualRecognition.listClassifiers(verbose: true) { [weak self] response, error in
//            guard let `self` = self else { return }
//            if let error = error {
//                print(error)
//            }
//
//            guard var classifiers = response?.result?.classifiers else {
//                self.classifiers = []
//                self.pickerView.selectItem(-1)
//                self.pickerView.reloadData()
//                return
//            }
//
//            classifiers = classifiers.sorted(by: { $0.created! > $1.created! })
//
//            // If the count and head are the same nothing was deleted or added. // This is definately fake news...
//            if !(self.classifiers.first! == classifiers.first!
//                && self.classifiers.first!.status == classifiers.first!.status // Ensure status
//                && self.classifiers.count == classifiers.count) {
//                self.classifiers = classifiers
//
//                if self.select >= self.classifiers.count {
//                    self.pickerView.selectItem(self.classifiers.count - 1)
//                }
//
//                self.pickerView.reloadData()
//                if self.select >= 0 {
//                    self.pickerView.selectItem(self.select)
//                }
//            }
//        }
//    }
//
//    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
//        return classifiers.filter({ $0.status == "ready" }).count
//    }
//
//    func pickerView(_ pickerView: AKPickerView, titleForItem item: Int) -> String {
//        let readyClassifier = classifiers.filter({ $0.status == "ready" })[item]
//        if readyClassifier.classifierId == UserDefaults.standard.string(forKey: "classifier_id") {
//            select = item
//        } else if readyClassifier.classifierId == String() && readyClassifier.name == UserDefaults.standard.string(forKey: "classifier_id") {
//            select = item
//        }
//        return classifiers.filter({ $0.status == "ready" })[item].name
//    }
//
//    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
//        // This should be safe because the picker only shows ready classifiers.
//        let readyClassifier = classifiers.filter({ $0.status == "ready" })[item]
//        if readyClassifier.classifierId == String() {
//            UserDefaults.standard.set(readyClassifier.name, forKey: "classifier_id")
//        } else {
//            UserDefaults.standard.set(readyClassifier.classifierId, forKey: "classifier_id")
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Set up PickerView.
//        pickerView.delegate = self
//        pickerView.dataSource = self
//        pickerView.interitemSpacing = CGFloat(25.0)
//        pickerView.pickerViewStyle = .flat
//        pickerView.maskDisabled = true
//        pickerView.font = UIFont.boldSystemFont(ofSize: 14)
//        pickerView.highlightedFont = UIFont.boldSystemFont(ofSize: 14)
//        pickerView.highlightedTextColor = UIColor.white
//        pickerView.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
//
//        // Give the API TextField styles and a stroke.
//        apiKeyTextField.attributedPlaceholder = NSAttributedString(string: "API Key", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)])
//        apiKeyTextField.setLeftPaddingPoints(20)
//        apiKeyTextField.setRightPaddingPoints(50)
//
//        // Retake just resets the UI.
//        retake()
//
//        // Create and hide the blur effect.
//        blurredEffectView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
//        view.addSubview(blurredEffectView)
//        blurredEffectView.isHidden = true
//
//        // Bring all the API key views to the front of the blur effect
//        view.bringSubviewToFront(apiKeyTextField)
//        view.bringSubviewToFront(apiKeyDoneButton)
//        view.bringSubviewToFront(apiKeySubmit)
//        view.bringSubviewToFront(apiKeyLogOut)
//        view.bringSubviewToFront(hintTextView)
//    }
//
//    override func captured(image: UIImage) {
//        var apiKey = UserDefaults.standard.string(forKey: "api_key")
//
//        if apiKey == nil || apiKey == "" {
//            apiKey = VISION_API_KEY
//        }
//
//        let reducedImage = image.resized(toWidth: 300)!
//
//        guard let classifierId = UserDefaults.standard.string(forKey: "classifier_id")?.lowercased() else {
//            return
//        }
//
//        classify(id: classifierId, image: reducedImage)
//
//        // Set the screen to our captured photo.
//        tempImageView.image = image
//        tempImageView.isHidden = false
//
//        photoButton.isHidden = true
//        cameraButton.isHidden = true
//        retakeButton.isHidden = false
//        classifiersButton.isHidden = true
//        pickerView.isHidden = true
//
//        if let drawer = self.parent as? PulleyViewController {
//            drawer.navigationController?.navigationBar.isHidden = true
//        }
//
//        // Show an activity indicator while its loading.
//        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
//
//        alert.view.tintColor = UIColor.black
//        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
//        loadingIndicator.hidesWhenStopped = true
//        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//        loadingIndicator.startAnimating()
//
//        alert.view.addSubview(loadingIndicator)
//        present(alert, animated: true, completion: nil)
//    }
//
//    func classify(id: String, image: UIImage) {
//        let url = URL(string: "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classify")!
//
//        let urlRequest = URLRequest(url: url)
//
//        let parameters: Parameters = [
//            "api_key": key,
//            "version": "2016-05-20",
//            "threshold": "0",
//            "classifier_ids": "\(id)"
//        ]
//
//        do {
//            let encodedURLRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)
//
//            Alamofire.upload(UIImageJPEGRepresentation(image, 0.4)!, to: encodedURLRequest.url!).responseJSON { [weak self] response in
//                guard let `self` = self else { return }
//
//                // Start parsing json, throw error popup if it messed up.
//                guard let json = response.result.value as? [String: Any],
//                    let images = json["images"] as? [Any],
//                    let image = images.first as? [String: Any],
//                    let classifiers = image["classifiers"] as? [Any],
//                    let classifier = classifiers.first as? [String: Any],
//                    let classes = classifier["classes"] as? [Any] else {
//                        print("Error: No classes returned.")
//                        self.retake()
//                        let alert = UIAlertController(title: nil, message: "No classes found.", preferredStyle: .alert)
//
//                        let cancelAction = UIAlertAction(title: "Okay", style: .cancel) { action in
//                            print("cancel")
//                        }
//
//                        alert.addAction(cancelAction)
//
//                        self.dismiss(animated: true, completion: {
//                            self.present(alert, animated: true, completion: nil)
//                        })
//                        return
//                }
//
//                var myNewData = [ClassResult]()
//
//                for case let classResult in classes {
//                    myNewData.append(ClassResult(json: classResult)!)
//                }
//
//                // Sort data by score and reload table.
//                myNewData = myNewData.sorted(by: { $0.score > $1.score })
//                self.push(data: myNewData)
//            }
//        } catch {
//            print("Error: \(error)")
//        }
//    }
//
//    // Convenience method for pushing data to the TableView.
//    func push(data: [ClassResult]) {
//        getTableController { [unowned self] tableController, drawer in
//            tableController.classes = data
//            self.dismiss(animated: false, completion: nil)
//            drawer.setDrawerPosition(position: .partiallyRevealed, animated: true)
//        }
//    }
//
//    // Convenience method for reloading the TableView.
//    func getTableController(run: @escaping (_ tableController: ResultsTableViewController, _ drawer: PulleyViewController) -> Void) {
//        if let drawer = parent as? PulleyViewController {
//            if let tableController = drawer.drawerContentViewController as? ResultsTableViewController {
//                run(tableController, drawer)
//                tableController.tableView.reloadData()
//            }
//        }
//    }
//
//    // Convenience method for obscuring the API key.
//    func obscureKey(key: String) -> String {
//        let a = key[key.index(key.startIndex, offsetBy: 0)]
//
//        let start = key.index(key.endIndex, offsetBy: -3)
//        let end = key.index(key.endIndex, offsetBy: 0)
//        let b = key[Range(start ..< end)]
//
//        return "🔑 \(a)•••••••••••••••••••••••••••••••••••••\(b)"
//    }
//
//    // Verify the API entered or scanned.
//    func testKey(key: String) {
//        // Escape if they are already logged in with this key.
//        if key == UserDefaults.standard.string(forKey: "api_key") {
//            return
//        }
//
//        apiKeyDone()
//
//        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
//
//        alert.view.tintColor = UIColor.black
//        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
//        loadingIndicator.hidesWhenStopped = true
//        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//        loadingIndicator.startAnimating()
//
//        alert.view.addSubview(loadingIndicator)
//        present(alert, animated: true, completion: nil)
//
//        let url = "https://gateway-a.watsonplatform.net/visual-recognition/api"
//        let params = [
//            "api_key": key,
//            "version": "2016-05-20"
//        ]
//        Alamofire.request(url, parameters: params).responseJSON { [weak self] response in
//            guard let `self` = self else { return }
//
//            if let json = response.result.value as? [String : Any] {
//                if json["statusInfo"] as! String == "invalid-api-key" {
//                    print("Ivalid api key!")
//                    let alert = UIAlertController(title: nil, message: "Invalid api key.", preferredStyle: .alert)
//
//                    let cancelAction = UIAlertAction(title: "Okay", style: .cancel) { action in
//                        print("cancel")
//                    }
//
//                    alert.addAction(cancelAction)
//                    self.dismiss(animated: true, completion: {
//                        self.present(alert, animated: true, completion: nil)
//                    })
//                    return
//                }
//            }
//            print("Key set!")
//            self.dismiss(animated: true, completion: nil)
//            UserDefaults.standard.set(key, forKey: "api_key")
//            self.loadClassifiers()
//
//            let key = self.obscureKey(key: key)
//
//            if let drawer = self.parent as? PulleyViewController {
//                (drawer.navigationItem.titleView as! UIButton).setAttributedTitle(NSAttributedString(string: key, attributes: [NSForegroundColorAttributeName : UIColor.white, NSStrokeColorAttributeName : UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0), NSStrokeWidthAttributeName : -0.5]), for: .normal)
//            }
//        }
//    }
//
//    @IBAction func unwindToVC(segue: UIStoryboardSegue) {
//
//    }
//
//    @objc func addApiKey() {
//        if let drawer = parent as? PulleyViewController {
//            drawer.navigationController?.navigationBar.isHidden = true
//        }
//
//        blurredEffectView.isHidden = false
//        apiKeyTextField.isHidden = false
//        apiKeyDoneButton.isHidden = false
//        apiKeySubmit.isHidden = false
//        apiKeyLogOut.isHidden = false
//        hintTextView.isHidden = false
//
//        // If the key isn't set disable the logout button.
//        apiKeyLogOut.isEnabled = UserDefaults.standard.string(forKey: "api_key") != nil
//
//        apiKeyTextField.becomeFirstResponder()
//    }
//
//    @IBAction func apiKeyDone() {
//        if let drawer = parent as? PulleyViewController {
//            drawer.navigationController?.navigationBar.isHidden = false
//        }
//
//        apiKeyTextField.isHidden = true
//        apiKeyDoneButton.isHidden = true
//        apiKeySubmit.isHidden = true
//        apiKeyLogOut.isHidden = true
//        hintTextView.isHidden = true
//        blurredEffectView.isHidden = true
//
//        view.endEditing(true)
//        apiKeyTextField.text = ""
//    }
//
//    @IBAction func submitApiKey() {
//        let key = apiKeyTextField.text
//        testKey(key: key!)
//    }
//
//    @IBAction func logOut() {
//        apiKeyDone()
//        UserDefaults.standard.set(nil, forKey: "api_key")
//        if let drawer = parent as? PulleyViewController {
//            (drawer.navigationItem.titleView as! UIButton).setAttributedTitle(NSAttributedString(string: "🔑 API Key", attributes: [NSForegroundColorAttributeName : UIColor.white, NSStrokeColorAttributeName : UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0), NSStrokeWidthAttributeName : -0.5]), for: .normal)
//        }
//        loadClassifiers()
//    }
//
//    @IBAction func retake() {
//        tempImageView.subviews.forEach({ $0.removeFromSuperview() })
//        tempImageView.isHidden = true
//        photoButton.isHidden = false
//        cameraButton.isHidden = false
//        retakeButton.isHidden = true
//        classifiersButton.isHidden = false
//        pickerView.isHidden = false
//
//        if let drawer = parent as? PulleyViewController {
//            drawer.navigationController?.navigationBar.isHidden = false
//        }
//
//        getTableController { tableController, drawer in
//            drawer.setDrawerPosition(position: .closed, animated: true)
//            tableController.classes = []
//        }
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showClassifiers",
//            let destination = segue.destination as? ClassifiersTableViewController {
//            destination.classifiers = classifiers
//        }
//    }
//}
//
//// MARK: - AVCaptureMetadataOutputObjectsDelegate
//
//extension ClassifyViewController: AVCaptureMetadataOutputObjectsDelegate {
//    // Delegate for QR Codes.
//    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
//        guard let metadataObj = metadataObjects.first else {
//            print("No QR code is detected")
//            return
//        }
//
//        print(metadataObj)
////        testKey(key: String(metadataObj))
//    }
//}
//
//// MARK: - AVCapturePhotoCaptureDelegate
//
//extension ClassifyViewController: AVCapturePhotoCaptureDelegate {
//
//}
//
//
//
//
/////////////////////////////////
//
//extension UIImage {
//    func resized(withPercentage percentage: CGFloat) -> UIImage? {
//        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
//        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
//        defer { UIGraphicsEndImageContext() }
//        draw(in: CGRect(origin: .zero, size: canvasSize))
//        return UIGraphicsGetImageFromCurrentImageContext()
//    }
//
//    func resized(toWidth width: CGFloat) -> UIImage? {
//        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
//        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
//        defer { UIGraphicsEndImageContext() }
//        draw(in: CGRect(origin: .zero, size: canvasSize))
//        return UIGraphicsGetImageFromCurrentImageContext()
//    }
//}
//
//extension UIImageView {
//    var imageScale: CGSize {
//
//        if let image = self.image {
//            let sx = Double(self.frame.size.width / image.size.width)
//            let sy = Double(self.frame.size.height / image.size.height)
//            var s = 1.0
//            switch (self.contentMode) {
//            case .scaleAspectFit:
//                s = fmin(sx, sy)
//                return CGSize (width: s, height: s)
//
//            case .scaleAspectFill:
//                s = fmax(sx, sy)
//                return CGSize(width:s, height:s)
//
//            case .scaleToFill:
//                return CGSize(width:sx, height:sy)
//
//            default:
//                return CGSize(width:s, height:s)
//            }
//        }
//
//        return CGSize.zero
//    }
//}
//
//extension UITextField {
//    func setLeftPaddingPoints(_ amount:CGFloat){
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))
//        leftView = paddingView
//        leftViewMode = .always
//    }
//
//    func setRightPaddingPoints(_ amount:CGFloat) {
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))
//        rightView = paddingView
//        rightViewMode = .always
//    }
//}
//
