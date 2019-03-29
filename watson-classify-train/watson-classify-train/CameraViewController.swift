/**
 * Copyright IBM Corporation 2017, 2018
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import UIKit
import AVFoundation
import VisualRecognitionV3

struct VisualRecognitionConstants {
    static let version = "2018-07-24"
}

class CameraViewController: UIViewController {
    
//    @IBOutlet var tempImageView: UIImageView!
//
//    @IBOutlet var classifiersButton: UIButton!
//    @IBOutlet var retakeButton: UIButton!
//    @IBOutlet var apiKeyDoneButton: UIButton!
//    @IBOutlet var apiKeySubmit: UIButton!
//    @IBOutlet var apiKeyLogOut: UIButton!
//    @IBOutlet var apiKeyTextField: UITextField!
    
//    @IBOutlet var pickerView: AKPickerView!

    // MARK: - IBOutlets
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var heatmapView: UIImageView!
    @IBOutlet weak var outlineView: UIImageView!
    @IBOutlet weak var focusView: UIImageView!
    @IBOutlet weak var simulatorTextView: UITextView!
    @IBOutlet weak var captureButton: UIButton!
//    @IBOutlet weak var updateModelButton: UIButton!
//    @IBOutlet weak var choosePhotoButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var alphaSlider: UISlider!
    
    @IBOutlet var pickerView: AKPickerView! {
        didSet {
            pickerView.delegate = self
            pickerView.dataSource = self
            pickerView.interitemSpacing = CGFloat(25.0)
            pickerView.pickerViewStyle = .flat
            pickerView.maskDisabled = true
            pickerView.font = UIFont.boldSystemFont(ofSize: 14)
            pickerView.highlightedFont = UIFont.boldSystemFont(ofSize: 14)
            pickerView.highlightedTextColor = UIColor.white
            pickerView.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
            loadClassifiers()
        }
    }
    
    // MARK: - Variable Declarations
    
    let visualRecognition: VisualRecognition? = {
//        guard let apiKey = UserDefaults.standard.string(forKey: "apikey") else {
//            return nil
//        }
        let apiKey = "vb5iWrlKorbyxYl6Hn-qKO-VLDnHUW5GisN3Fbd6uI9R"
        return VisualRecognition(version: VisualRecognitionConstants.version, apiKey: apiKey)
    }()
    
    let photoOutput = AVCapturePhotoOutput()
    lazy var captureSession: AVCaptureSession? = {
        guard let backCamera = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: backCamera) else {
                return nil
        }
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        captureSession.addInput(input)
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = CGRect(x: view.bounds.minX, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height)
            // `.resize` allows the camera to fill the screen on the iPhone X.
            previewLayer.videoGravity = .resize
            previewLayer.connection?.videoOrientation = .portrait
            cameraView.layer.addSublayer(previewLayer)
            return captureSession
        }
        return nil
    }()
    
    // Blurred effect for the API key form.
    let blurredEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    var editedImage = UIImage()
    var originalConfs = [ClassResult]()
    var heatmaps = [String: HeatmapImages]()

    var classifiers = [Classifier]()
    var select = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession?.startRunning()
        resetUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Image Classification
    
    func loadClassifiers() {
        print("loading classifiers")
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

        // Load from Watson.
        guard let visualRecognition = self.visualRecognition else {
            print("failed to get VizRec service")
//            classifiers = []
//            pickerView.selectItem(-1)
//            pickerView.reloadData()
            return
        }

        visualRecognition.listClassifiers(verbose: true) { [weak self] response, error in
            guard let `self` = self else { return }
            if let error = error {
                print(error)
            }

            guard var classifiers = response?.result?.classifiers else {
                 print("no classifiers")
//                self.classifiers = []
//                self.pickerView.selectItem(-1)
//                self.pickerView.reloadData()
                return
            }
            print("done")

            classifiers = classifiers.sorted(by: { $0.created ?? Date.distantPast > $1.created ?? Date.distantPast })
            print(classifiers)
            
            DispatchQueue.main.async {
                self.classifiers = classifiers
                self.pickerView.reloadData()
                self.pickerView.selectItem(0)
                
//                guard let oldFirstClassifier = self.classifiers.first else {
//                    self.classifiers = classifiers
//                    self.pickerView.selectItem(0)
//                    return
//                }
                
//                // If the count and head are the same nothing was deleted or added. // This is definately fake news... // jk this is legit
//                if !(oldFirstClassifier == classifiers.first && oldFirstClassifier.status == classifiers.first?.status // Ensure status
//                    && self.classifiers.count == classifiers.count) {
//                    self.classifiers = classifiers
//
//                    if self.select >= self.classifiers.count {
//                        self.pickerView.selectItem(self.classifiers.count - 1)
//                    }
//
//                    self.pickerView.reloadData()
//                    if self.select >= 0 {
//                        self.pickerView.selectItem(self.select)
//                    }
//                }
            }
        }
    }
    
    func classifyImage(_ image: UIImage, localThreshold: Double = 0.0) {
        guard let visualRecognition = self.visualRecognition, let classifierId = UserDefaults.standard.string(forKey: "classifier_id") else {
            return
        }
        
        editedImage = cropToCenter(image: image, targetSize: CGSize(width: 224, height: 224))
        
        showResultsUI(for: image)
        
        visualRecognition.classify(image: editedImage, threshold: localThreshold, classifierIDs: [classifierId]) { response, _ in

            // Make sure that an image was successfully classified.
            guard let classifier = response?.result?.images.first?.classifiers.first else {
                return
            }
            
            DispatchQueue.main.async {
                self.push(results: [classifier])
            }
        
            self.originalConfs = classifier.classes
        }
    }
    
//    func startAnalysis(classToAnalyze: String, localThreshold: Double = 0.0) {
//        if let heatmapImages = heatmaps[classToAnalyze] {
//            heatmapView.image = heatmapImages.heatmap
//            outlineView.image = heatmapImages.outline
//            return
//        }
//
//        var confidences = [[Double]](repeating: [Double](repeating: -1, count: 17), count: 17)
//
//        DispatchQueue.main.async {
//            SwiftSpinner.show("analyzing")
//        }
//
//        let chosenClasses = originalConfs.filter({ return $0.className == classToAnalyze })
//        guard let chosenClass = chosenClasses.first else {
//            return
//        }
//
//        let originalConf = chosenClass.score
//
//        let dispatchGroup = DispatchGroup()
//        dispatchGroup.enter()
//
//        DispatchQueue.global(qos: .background).async {
//            for down in 0 ..< 11 {
//                for right in 0 ..< 11 {
//                    confidences[down + 3][right + 3] = 0
//                    dispatchGroup.enter()
//                    let maskedImage = self.maskImage(image: self.editedImage, at: CGPoint(x: right, y: down))
//                    self.visualRecognition.classifyWithLocalModel(image: maskedImage, classifierIDs: VisualRecognitionConstants.modelIds, threshold: localThreshold) { [down, right] classifiedImages, _ in
//
//                        defer { dispatchGroup.leave() }
//
//                        // Make sure that an image was successfully classified.
//                        guard let classifiedImage = classifiedImages?.images.first,
//                            let classifier = classifiedImage.classifiers.first else {
//                                return
//                        }
//
//                        let usbClass = classifier.classes.filter({ return $0.className == classToAnalyze })
//
//                        guard let usbClassSingle = usbClass.first else {
//                            return
//                        }
//
//                         let score = usbClassSingle.score
//
//                        print(".", terminator:"")
//
//                        confidences[down + 3][right + 3] = score
//                    }
//                }
//            }
//            dispatchGroup.leave()
//
//            dispatchGroup.notify(queue: .main) {
//                print()
//                print(confidences)
//
//                guard let image = self.imageView.image else {
//                    return
//                }
//
//                let heatmap = self.calculateHeatmap(confidences, originalConf)
//                let heatmapImage = self.renderHeatmap(heatmap, color: .black, size: image.size)
//                let outlineImage = self.renderOutline(heatmap, size: image.size)
//
//                let heatmapImages = HeatmapImages(heatmap: heatmapImage, outline: outlineImage)
//                self.heatmaps[classToAnalyze] = heatmapImages
//
//                self.heatmapView.image = heatmapImage
//                self.outlineView.image = outlineImage
//                self.heatmapView.alpha = CGFloat(self.alphaSlider.value)
//
//                self.heatmapView.isHidden = false
//                self.outlineView.isHidden = false
//                self.alphaSlider.isHidden = false
//
//                SwiftSpinner.hide()
//            }
//        }
//    }
    
//    func maskImage(image: UIImage, at point: CGPoint) -> UIImage {
//        let size = image.size
//        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
//
//        image.draw(at: .zero)
//
//        let rectangle = CGRect(x: point.x * 16, y: point.y * 16, width: 64, height: 64)
//
//        UIColor(red: 1, green: 0, blue: 1, alpha: 1).setFill()
//        UIRectFill(rectangle)
//
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        return newImage
//    }
    
    func cropToCenter(image: UIImage, targetSize: CGSize) -> UIImage {
        let offset = abs((image.size.width - image.size.height) / 2)
        let posX = image.size.width > image.size.height ? offset : 0.0
        let posY = image.size.width < image.size.height ? offset : 0.0
        let newSize = CGFloat(min(image.size.width, image.size.height))
        
        // crop image to square
        let cropRect = CGRect(x: posX, y: posY, width: newSize, height: newSize)
        
        guard let cgImage = image.cgImage,
            let cropped = cgImage.cropping(to: cropRect) else {
                return image
        }
        
        let image = UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
        
        let resizeRect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: resizeRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func dismissResults() {
        push(results: [], position: .closed)
    }
    
    func push(results: [VisualRecognitionV3.ClassifierResult], position: PulleyPosition = .partiallyRevealed) {
        guard let drawer = pulleyViewController?.drawerContentViewController as? ResultsTableViewController else {
            return
        }
        drawer.classifications = results
        pulleyViewController?.setDrawerPosition(position: position, animated: true)
        drawer.tableView.reloadData()
    }
    
    func showResultsUI(for image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        simulatorTextView.isHidden = true
        closeButton.isHidden = false
        captureButton.isHidden = true
//        choosePhotoButton.isHidden = true
//        updateModelButton.isHidden = true
        focusView.isHidden = true
    }
    
    func resetUI() {
        heatmaps = [String: HeatmapImages]()
        if captureSession != nil {
            simulatorTextView.isHidden = true
            imageView.isHidden = true
            captureButton.isHidden = false
            focusView.isHidden = false
        } else {
            imageView.image = UIImage(named: "Background")
            simulatorTextView.isHidden = false
            imageView.isHidden = false
            captureButton.isHidden = true
            focusView.isHidden = true
        }
        heatmapView.isHidden = true
        outlineView.isHidden = true
        alphaSlider.isHidden = true
        closeButton.isHidden = true
//        choosePhotoButton.isHidden = false
//        updateModelButton.isHidden = false
        dismissResults()
    }
    
    // MARK: - IBActions
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = CGFloat(sender.value)
        self.heatmapView.alpha = currentValue
    }
    
    @IBAction func capturePhoto() {
        photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    @IBAction func reset() {
        resetUI()
    }
    
    // MARK: - Structs
    
    struct HeatmapImages {
        let heatmap: UIImage
        let outline: UIImage
    }
}

// MARK: - Error Handling

extension CameraViewController {
    func showAlert(_ alertTitle: String, alertMessage: String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func modelUpdateFail(modelId: String, error: Error) {
        let error = error as NSError
        var errorMessage = ""
        
        // 0 = probably wrong api key
        // 404 = probably no model
        // -1009 = probably no internet
        
        switch error.code {
        case 0:
            errorMessage = "Please check your Visual Recognition API key and try again."
        case 404:
            errorMessage = "We couldn't find the model with ID: \"\(modelId)\""
        case 500:
            errorMessage = "Internal server error. Please try again."
        case -1009:
            errorMessage = "Please check your internet connection."
        default:
            errorMessage = "Please try again."
        }
        
        // TODO: Do some more checks, does the model exist? is it still training? etc.
        // The service's response is pretty generic and just guesses.
        
        showAlert("Unable to download model", alertMessage: errorMessage)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension CameraViewController: AVCaptureMetadataOutputObjectsDelegate {
    // Delegate for QR Codes.
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObj = metadataObjects.first else {
            print("No QR code is detected")
            return
        }
        
        print(metadataObj)
        // testKey(key: String(metadataObj))
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let photoData = photo.fileDataRepresentation(),
            let image = UIImage(data: photoData) else {
            return
        }
        
        classifyImage(image)
    }
}

// MARK: - TableViewControllerSelectionDelegate

extension CameraViewController: TableViewControllerSelectionDelegate {
    func didSelectItem(_ name: String) {
//        startAnalysis(classToAnalyze: name)
    }
}


extension CameraViewController: AKPickerViewDataSource {
    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        return classifiers.filter({ $0.status == "ready" }).count
    }

    func pickerView(_ pickerView: AKPickerView, titleForItem item: Int) -> String {
        let readyClassifier = classifiers.filter({ $0.status == "ready" })[item]
        if readyClassifier.classifierID == UserDefaults.standard.string(forKey: "classifier_id") {
            select = item
        } else if readyClassifier.classifierID == String() && readyClassifier.name == UserDefaults.standard.string(forKey: "classifier_id") {
            select = item
        }
        return classifiers.filter({ $0.status == "ready" })[item].name
    }
}

extension CameraViewController: AKPickerViewDelegate {
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
        // This should be safe because the picker only shows ready classifiers.
        let readyClassifier = classifiers.filter({ $0.status == "ready" })[item]
        if readyClassifier.classifierID == String() {
            UserDefaults.standard.set(readyClassifier.name, forKey: "classifier_id")
        } else {
            UserDefaults.standard.set(readyClassifier.classifierID, forKey: "classifier_id")
        }
    }
}
