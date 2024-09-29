import SwiftUI
import CoreML
import Vision
import SwiftUI
import AVFoundation

struct CameraFeedView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var takePhoto: Bool
    

    func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // If takePhoto is true, call the capturePhoto method on the CameraViewController
        if takePhoto {
            uiViewController.capturePhoto()
            takePhoto = false // Reset the flag after capturing photo
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CameraViewControllerDelegate {
        var parent: CameraFeedView

        init(_ parent: CameraFeedView) {
            self.parent = parent
        }

        func didCapturePhoto(_ image: UIImage) {
            parent.capturedImage = image
        }
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func didCapturePhoto(_ image: UIImage)
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoOutput: AVCapturePhotoOutput!
    weak var delegate: CameraViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the capture session
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        // Get the default camera
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Error setting up camera input: \(error.localizedDescription)")
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Could not add video input to session")
            return
        }

        // Set up the photo output
        photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        // Create and add the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Start the capture session on a background thread
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    /*override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        previewLayer.frame = view.bounds
    }
*/
    override var shouldAutorotate: Bool {
        return false
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // Method to capture a photo
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    // Delegate method called when the photo is captured
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Error capturing photo: \(error?.localizedDescription ?? "Unknown error")")
            return
        }

        delegate?.didCapturePhoto(image)
    }
}
struct CameraSearchView: View {
    @Binding var capturedImage: UIImage?
    @State var takePhoto: Bool = false
    @Binding var recognizedItem: String
    @Binding var generatedRecipe: String
    @Binding var isNewScreen:Bool
    
    var body: some View {
        NavigationStack{
            ZStack {
                // Assuming CameraFeedView handles the live camera feed and photo capture
                if !isNewScreen {
                    CameraFeedView(capturedImage: $capturedImage, takePhoto: $takePhoto)
                        .edgesIgnoringSafeArea(.all)
                    
                    // Display the captured image if available
                    if let image = capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .ignoresSafeArea(.all)
                    }
                }
                
                // Bottom-centered capture button or progress view
                VStack {
                    Spacer()
                    
                    if !takePhoto {
                        // Capture button
                        Button(action: {
                            takePhoto = true
                        }, label: {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 70, height: 70)
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .padding()
                        })
                        .padding()
                    } else {
                        // Show the spinner while capturing
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(2.0) // Increase the size of the spinner
                            .padding()
                    }
                    
                    if !recognizedItem.isEmpty {
                        Text("Recognized Item: \(recognizedItem)")
                            .font(.title2)
                            .padding()
                    }
                    
                }
            }
            .onChange(of: capturedImage) { newValue in
                if let image = newValue {
                    // Call the recognition function when a new image is captured
                    recognizeAndGenerateRecipe(from: image)
                    isNewScreen = true
                }
            }
            .navigationDestination(isPresented: $isNewScreen, destination: {
                Text("Recognized Food: \(recognizedItem)")
                Text("Generated Recipe:")
                    .font(.title2)
                    .bold()
                    .padding(.top)
                
                ScrollView {
                    Text(generatedRecipe)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding()
                }
            })
        }
    }
    
    /// Recognize image and generate recipe in one function for better organization
    private func recognizeAndGenerateRecipe(from image: UIImage) {
        recognizeImage(image) { item in
            if let recognizedItem = item {
                self.recognizedItem = recognizedItem
                generateRecipe(for: recognizedItem)
            }
        }
    }
    
    func recognizeImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        let config = MLModelConfiguration()
        
        print("Model URL: \(Bundle.main.url(forResource: "foodClassifier5", withExtension: "mlmodelc"))")
        
        // Use the .mlmodel file instead of the .mlmodelc file
        guard let modelURL = Bundle.main.url(forResource: "foodClassifier5", withExtension: "mlmodelc") else {
            print("Model URL is nil")
            return
        }
        // Print the URL to check if it's correct

        do {
            // Load the model directly from the .mlmodel
            let model = try VNCoreMLModel(for: MLModel(contentsOf: modelURL, configuration: config))
            
            let request = VNCoreMLRequest(model: model) { request, error in
                if let results = request.results as? [VNClassificationObservation], let firstResult = results.first {
                    completion(firstResult.identifier) // grocery item name
                } else {
                    completion(nil)
                }
            }
            
            guard let ciImage = CIImage(image: image) else { return }
            let handler = VNImageRequestHandler(ciImage: ciImage)
            try handler.perform([request])
            
        } catch {
            print("Error loading model: \(error.localizedDescription)")
        }
    }
    
    /// Generate a recipe using the recognized ingredient by calling the OpenAI API
    func generateRecipe(for ingredient: String) {
       
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
                print("Invalid URL.")
                return
            }
                
        // Update the request body to match the new `chat/completions` endpoint format
            let messages: [[String: Any]] = [
                ["role": "system", "content": "You are a helpful assistant that generates recipes based on ingredients provided by the user."],
                ["role": "user", "content": "Give me multiple Latin-based recipes using \(ingredient)."]
            ]

            let body: [String: Any] = [
                "model": "gpt-3.5-turbo-0125",  // Change this to the desired model, e.g., "gpt-4" if needed
                "messages": messages,
                "max_tokens": 2000,
                "temperature": 0.7
            ]
        
      
        var apiKey = "INSERT_API_KEY"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Convert the request body to JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Error serializing request body: \(error.localizedDescription)")
            return
        }
        
        // Create the URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            // Check and print the HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                print("Response Headers: \(httpResponse.allHeaderFields)")
            }
            
            guard let data = data else {
                print("No data received from the API.")
                return
            }
            
            // Print the raw JSON response as a string to inspect
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw JSON Response: \(rawResponse)")
            } else {
                print("Unable to convert data to string.")
            }

            // Attempt to parse the response
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Parsed JSON: \(json)")  // Print the parsed JSON structure
                    if let choices = json["choices"] as? [[String: Any]],
                       let message = choices.first?["message"] as? [String: Any],
                       let recipe = message["content"] as? String {
                        DispatchQueue.main.async {
                            self.generatedRecipe = recipe
                        }
                        print("Generated Recipe: \(recipe)")
                    } else {
                        print("Unexpected response format.")
                    }
                }
            } catch {
                print("Error parsing response: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }


}


#Preview {
    CameraSearchView(capturedImage: .constant(nil), recognizedItem: .constant(""), generatedRecipe: .constant("Test Reciepe"), isNewScreen: .constant(false))
}
