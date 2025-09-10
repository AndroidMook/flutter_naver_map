import NMapsMap

internal struct NOverlayImage {
    let path: String
    let mode: NOverlayImageMode

    var overlayImage: NMFOverlayImage {
        switch mode {
        case .file, .temp, .widget: return makeOverlayImageWithPath()
        case .asset: return makeOverlayImageWithAssetPath()
        }
    }

    private func makeOverlayImageWithPath() -> NMFOverlayImage {
        if let image = UIImage(contentsOfFile: path),
           let data = image.pngData(),
           let scaledImage = UIImage(data: data, scale: DisplayUtil.scale) {
            return NMFOverlayImage(image: scaledImage)
        } else {
            print("==============NOverlayImage makeOverlayImageWithPath NPE===================");
            // Fallback: 빈 1x1 이미지 직접 생성
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
            let emptyImage = renderer.image { _ in
                UIColor.clear.setFill()
                UIBezierPath(rect: CGRect(x: 0, y: 0, width: 1, height: 1)).fill()
            }
            return NMFOverlayImage(image: emptyImage)
        }
    }
    
    private func makeOverlayImageWithAssetPath() -> NMFOverlayImage {
        let key = SwiftFlutterNaverMapPlugin.getAssets(path: path)
        let assetPath = Bundle.main.path(forResource: key, ofType: nil) ?? ""
        let image = UIImage(contentsOfFile: assetPath)
        let scaledImage = UIImage(data: image!.pngData()!, scale: DisplayUtil.scale)
        let overlayImg = NMFOverlayImage(image: scaledImage!, reuseIdentifier: assetPath)
        return overlayImg
    }

    func toMessageable() -> Dictionary<String, Any> {
        [
            "path": path,
            "mode": mode.rawValue
        ]
    }

    static func fromMessageable(_ v: Any) -> NOverlayImage {
        let d = asDict(v)
        return NOverlayImage(
                path: asString(d["path"]!),
                mode: NOverlayImageMode(rawValue: asString(d["mode"]!))!
        )
    }

    static let none = NOverlayImage(path: "", mode: .temp)
}
