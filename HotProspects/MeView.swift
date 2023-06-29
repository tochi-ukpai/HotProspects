//
//  MeView.swift
//  HotProspects
//
//  Created by Theós on 27/06/2023.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct MeView: View {
    @StateObject var viewModel = ViewModel()
    @State private var qrCode = UIImage()
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $viewModel.user.name)
                    .textContentType(.name)
                    .font(.title)

                TextField("Email address", text: $viewModel.user.emailAddress)
                    .textContentType(.emailAddress)
                    .font(.title)
                HStack {
                    Spacer()
                    Image(uiImage: qrCode)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                    Spacer()
                }
                .contextMenu {
                    Button {
                        let imageSaver = ImageSaver()
                        imageSaver.writeToPhotoAlbum(image: qrCode)
                    } label: {
                        Label("Save to Photos", systemImage: "square.and.arrow.down")
                    }
                }
            }
            .navigationTitle("Your code")
            .onAppear(perform: updateCode)
            .onChange(of: viewModel.user) { _ in updateCode() }
        }
    }
    
    func updateCode() {
        qrCode = generateQRCode(from: "\(viewModel.user.name)\n\(viewModel.user.emailAddress)")
    }
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
