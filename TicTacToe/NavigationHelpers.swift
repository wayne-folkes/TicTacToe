import SwiftUI
#if canImport(UIKit)
import UIKit

struct DisableSwipeBackRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController { Controller() }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    final class Controller: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
}

struct DisableSwipeBackModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(DisableSwipeBackRepresentable())
    }
}

extension View {
    func disableSwipeBack() -> some View {
        modifier(DisableSwipeBackModifier())
    }
}
#endif
