//
//  AlertBasic.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 01/08/24.
//

import UIKit
import JGProgressHUD

class BasicAlert {
    
    static let shared = BasicAlert()
    private init() {
        alert.style = .dark
    }
    
    private var alert = JGProgressHUD()
    
    func showLoading(_ view: UIView) {
        alert.vibrancyEnabled = true
        alert.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        alert.textLabel.text = "Loading"
        alert.detailTextLabel.text = ""
        UIView.animate(withDuration: 0, delay: 0.2) {
            self.alert.show(in: view)
        }
    }
    
    func showError(_ view: UIView, title: String, message: String?) {
        alert.vibrancyEnabled = true
        alert.indicatorView = JGProgressHUDErrorIndicatorView()
        alert.textLabel.text = title
        alert.detailTextLabel.text = message
        alert.show(in: view)
        alert.dismiss(afterDelay: 1, animated: true)
    }
    
    func showSuccess(_ view: UIView, message: String?) {
        alert.vibrancyEnabled = true
        alert.indicatorView = JGProgressHUDSuccessIndicatorView()
        alert.textLabel.text = "Success"
        alert.detailTextLabel.text = message
        alert.show(in: view)
        alert.dismiss(afterDelay: 0.5, animated: true)
    }
    
    func dismiss() {
        alert.dismiss(afterDelay: 0.5, animated: true)
    }
}

protocol AlertHelper {}
extension AlertHelper where Self: UIViewController {
    func showBasicAlert(state: BasicUIState) {
        switch state {
        case .loading:
            BasicAlert.shared.showLoading(self.view)
        case .success(let content):
            BasicAlert.shared.showSuccess(self.view, message: content)
        case .failure(let error):
            BasicAlert.shared.showError(self.view, title: "Failure", message: error)
        case .warning(let error):
            BasicAlert.shared.showError(self.view, title: "Warning", message: error)
        case .close:
            BasicAlert.shared.dismiss()
        }
    }
    
    func showBasicAlert(title: String = "Warning", message: String? = nil, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { (_ ) in
            completion?()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showOKBasicAlert(title: String = "", message: String? = nil, onOK: (() -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        showCustomBasicAlert(title: title, message: message, onLeftHandler: {
            onOK?()
        }) {
            onCancel?()
        }
    }
    
    func showCustomBasicAlert(title: String = "", message: String? = nil, leftString: String = "OK", rightString: String = "Cancel", onLeftHandler: (() -> Void)? = nil, onRightHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let rightAction = UIAlertAction(title: rightString, style: .default) { (_ ) in
            onRightHandler?()
        }
        let leftAction = UIAlertAction(title: leftString, style: .cancel) { (_ ) in
            onLeftHandler?()
        }
        alert.addAction(leftAction)
        alert.addAction(rightAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showStackAlert(title: String, message: String?, options: [String], completion: ((Int) -> Void)?, onCancelTapped: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            let action = UIAlertAction(title: option, style: .default) { (_) in
                completion?(index)
            }
            alert.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            onCancelTapped?()
        }
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
}

extension UIViewController: AlertHelper {}
