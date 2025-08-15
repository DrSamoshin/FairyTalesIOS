import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "background_1" asset catalog image resource.
    static let background1 = DeveloperToolsSupport.ImageResource(name: "background_1", bundle: resourceBundle)

    /// The "background_2" asset catalog image resource.
    static let background2 = DeveloperToolsSupport.ImageResource(name: "background_2", bundle: resourceBundle)

    /// The "background_3" asset catalog image resource.
    static let background3 = DeveloperToolsSupport.ImageResource(name: "background_3", bundle: resourceBundle)

    /// The "background_4" asset catalog image resource.
    static let background4 = DeveloperToolsSupport.ImageResource(name: "background_4", bundle: resourceBundle)

    /// The "background_5" asset catalog image resource.
    static let background5 = DeveloperToolsSupport.ImageResource(name: "background_5", bundle: resourceBundle)

    /// The "background_6" asset catalog image resource.
    static let background6 = DeveloperToolsSupport.ImageResource(name: "background_6", bundle: resourceBundle)

    /// The "icon_1" asset catalog image resource.
    static let icon1 = DeveloperToolsSupport.ImageResource(name: "icon_1", bundle: resourceBundle)

    /// The "icon_2" asset catalog image resource.
    static let icon2 = DeveloperToolsSupport.ImageResource(name: "icon_2", bundle: resourceBundle)

    /// The "icon_3" asset catalog image resource.
    static let icon3 = DeveloperToolsSupport.ImageResource(name: "icon_3", bundle: resourceBundle)

    /// The "icon_4" asset catalog image resource.
    static let icon4 = DeveloperToolsSupport.ImageResource(name: "icon_4", bundle: resourceBundle)

    /// The "icon_5" asset catalog image resource.
    static let icon5 = DeveloperToolsSupport.ImageResource(name: "icon_5", bundle: resourceBundle)

    /// The "icon_6" asset catalog image resource.
    static let icon6 = DeveloperToolsSupport.ImageResource(name: "icon_6", bundle: resourceBundle)

    /// The "icon_7" asset catalog image resource.
    static let icon7 = DeveloperToolsSupport.ImageResource(name: "icon_7", bundle: resourceBundle)

    /// The "icon_8" asset catalog image resource.
    static let icon8 = DeveloperToolsSupport.ImageResource(name: "icon_8", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "background_1" asset catalog image.
    static var background1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .background1)
#else
        .init()
#endif
    }

    /// The "background_2" asset catalog image.
    static var background2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .background2)
#else
        .init()
#endif
    }

    /// The "background_3" asset catalog image.
    static var background3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .background3)
#else
        .init()
#endif
    }

    /// The "background_4" asset catalog image.
    static var background4: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .background4)
#else
        .init()
#endif
    }

    /// The "background_5" asset catalog image.
    static var background5: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .background5)
#else
        .init()
#endif
    }

    /// The "background_6" asset catalog image.
    static var background6: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .background6)
#else
        .init()
#endif
    }

    /// The "icon_1" asset catalog image.
    static var icon1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .icon1)
#else
        .init()
#endif
    }

    /// The "icon_2" asset catalog image.
    static var icon2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .icon2)
#else
        .init()
#endif
    }

    /// The "icon_3" asset catalog image.
    static var icon3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .icon3)
#else
        .init()
#endif
    }

    /// The "icon_4" asset catalog image.
    static var icon4: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .icon4)
#else
        .init()
#endif
    }

    /// The "icon_5" asset catalog image.
    static var icon5: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .icon5)
#else
        .init()
#endif
    }

    /// The "icon_6" asset catalog image.
    static var icon6: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .icon6)
#else
        .init()
#endif
    }

    /// The "icon_7" asset catalog image.
    static var icon7: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .icon7)
#else
        .init()
#endif
    }

    /// The "icon_8" asset catalog image.
    static var icon8: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .icon8)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "background_1" asset catalog image.
    static var background1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .background1)
#else
        .init()
#endif
    }

    /// The "background_2" asset catalog image.
    static var background2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .background2)
#else
        .init()
#endif
    }

    /// The "background_3" asset catalog image.
    static var background3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .background3)
#else
        .init()
#endif
    }

    /// The "background_4" asset catalog image.
    static var background4: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .background4)
#else
        .init()
#endif
    }

    /// The "background_5" asset catalog image.
    static var background5: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .background5)
#else
        .init()
#endif
    }

    /// The "background_6" asset catalog image.
    static var background6: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .background6)
#else
        .init()
#endif
    }

    /// The "icon_1" asset catalog image.
    static var icon1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .icon1)
#else
        .init()
#endif
    }

    /// The "icon_2" asset catalog image.
    static var icon2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .icon2)
#else
        .init()
#endif
    }

    /// The "icon_3" asset catalog image.
    static var icon3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .icon3)
#else
        .init()
#endif
    }

    /// The "icon_4" asset catalog image.
    static var icon4: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .icon4)
#else
        .init()
#endif
    }

    /// The "icon_5" asset catalog image.
    static var icon5: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .icon5)
#else
        .init()
#endif
    }

    /// The "icon_6" asset catalog image.
    static var icon6: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .icon6)
#else
        .init()
#endif
    }

    /// The "icon_7" asset catalog image.
    static var icon7: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .icon7)
#else
        .init()
#endif
    }

    /// The "icon_8" asset catalog image.
    static var icon8: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .icon8)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

