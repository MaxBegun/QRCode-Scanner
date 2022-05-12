import UIKit
import AVFoundation

final class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    // MARK: - Properties
    // MARK: Public
    // MARK: Private
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var qrCodeFrameView: UIView?
    private var alert = UIAlertController()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideo()
        setupQRCodeFrame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //start video capture
        if (captureSession.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //stop video capture
        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    // MARK: - Setups
    private func setupVideo() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        do {
            //get an instance of the AVCaptureDeviceInput class
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            //set the input device on the capture session
            if (captureSession.canAddInput(videoInput)) {
                captureSession.addInput(videoInput)
            } else {
                return
            }
        } catch {
            return
        }
        //init a AVCaptureMetadataOutput object and set it as the output device to the capture session
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
        //set delegate and use the default dispatch queue to execute the call back
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        //init the video preview layer and add it as a sublayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer!)
    }
    
    private func setupQRCodeFrame() {
        //init QR Code Frame to highlight the QR Code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.purple.cgColor
            qrCodeFrameView.layer.borderWidth = 4
            qrCodeFrameView.layer.cornerRadius = 10
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }
    
    internal func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //check if the metadataObjects array is not nil and it contains at least one object
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            alert.dismiss(animated: true, completion: nil)
            return
        }
        guard metadataObjects.count > 0 else { return }
        //get the metadata object
        if let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            if readableObject.type == .qr {
                //set frame
                let barCodeObject = previewLayer?.transformedMetadataObject(for: readableObject)
                qrCodeFrameView?.frame = barCodeObject!.bounds
                
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
                handleQRCode(url: stringValue)
            }
        }
    }
    //set two button to copy or follow the link
    private func handleQRCode(url: String) {
        alert = UIAlertController(title: "QR Code", message: url, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Follow", style: .default, handler: { [weak self] (action) in
            guard let qrcodeUrl = URL(string: url) else { return }
            if UIApplication.shared.canOpenURL(qrcodeUrl) {
                UIApplication.shared.open(qrcodeUrl)
                //save link
                let link = LinkModel(linkString: url)
                CoreDataManager.instance.saveLink(link)
                self?.navigationController?.popViewController(animated: true)
            } else {
                print("URL invalid")
            }
        }))
        alert.addAction(UIAlertAction(title: "Copy", style: .default, handler: { (action) in
            UIPasteboard.general.string = url
            //save link
            let link = LinkModel(linkString: url)
            CoreDataManager.instance.saveLink(link)
        }))
        present(alert, animated: true, completion: nil)
    }
    // MARK: - Helpers
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
