import ReactiveExtensions
import ReactiveCocoa
import func Foundation.NSLocalizedString
import class UIKit.UITextField
import class UIKit.UIButton
import class UIKit.UIAlertAction
import class UIKit.UIAlertController
import class UIKit.UITapGestureRecognizer
import class Library.MVVMViewController
import class Library.BorderButton
import enum Library.Color
import func Library.localizedString

internal final class LoginViewController: MVVMViewController {
  @IBOutlet internal weak var emailTextField: UITextField!
  @IBOutlet internal weak var passwordTextField: UITextField!
  @IBOutlet internal weak var loginButton: BorderButton!
  @IBOutlet internal weak var forgotPasswordButton: BorderButton!

  internal let viewModel: LoginViewModelType = LoginViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = localizedString(key: "login.navbar.title", defaultValue: "Log in")
    self.view.backgroundColor = Color.OffWhite.toUIColor()

    emailTextField.borderStyle = .None
    passwordTextField.borderStyle = .None
    emailTextField.layer.borderColor = Color.Gray.toUIColor().CGColor
    passwordTextField.layer.borderColor = Color.Gray.toUIColor().CGColor
    emailTextField.layer.borderWidth = 1.0
    passwordTextField.layer.borderWidth = 1.0

    let spacer: UIView = UIView(frame: CGRectMake(0, 0, 10, 0))
    emailTextField.leftView = spacer
    emailTextField.leftViewMode = UITextFieldViewMode.Always;

    let spacer2: UIView = UIView(frame: CGRectMake(0, 0, 10, 0))
    passwordTextField.leftView = spacer2
    passwordTextField.leftViewMode = UITextFieldViewMode.Always;

    let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
    self.view.addGestureRecognizer(tap)
  }

  override func bindViewModel() {
    self.viewModel.inputs.email <~ emailTextField.rac_text
    self.viewModel.inputs.password <~ passwordTextField.rac_text

    self.emailTextField.rac_signalForControlEvents(UIControlEvents.EditingDidEndOnExit)
      .subscribeNext { [weak self] _ in
        self?.viewModel.inputs.emailTextFieldDoneEditing()
    }

    self.passwordTextField.rac_signalForControlEvents(UIControlEvents.EditingDidEndOnExit)
      .subscribeNext { [weak self] _ in
        self?.viewModel.inputs.passwordTextFieldDoneEditing()
    }

    self.loginButton.rac_enabled <~ self.viewModel.outputs.isFormValid

    self.viewModel.outputs.passwordTextFieldBecomeFirstResponder
      .observeForUI()
      .observeNext { [weak self] _ in
        self?.passwordTextField.becomeFirstResponder()
    }

    self.viewModel.outputs.dismissKeyboard
      .observeForUI()
      .observeNext { [weak self] visible in
        self?.dismissKeyboard()
    }

    self.viewModel.outputs.isFormValid.producer
      .observeForUI()
      .startWithNext { [weak self] isValid in
        self?.loginButton.alpha = isValid ? 1.0 : 0.5
    }

    self.viewModel.outputs.logInSuccess
      .observeForUI()
      .observeNext { [weak self] _ in
        self?.onLoginSuccess()
    }

    self.viewModel.errors.invalidLogin
      .observeForUI()
      .observeNext { [weak self] message in
        self?.presentError(message)
    }

    self.viewModel.errors.genericError
      .observeForUI()
      .map { localizedString(key: "login.errors.unable_to_log_in", defaultValue: "Unable to log in.") }
      .observeNext { [weak self] message in
        self?.presentError(message)
    }
  }

  @IBAction
  internal func loginButtonPressed(sender: UIButton) {
    self.viewModel.inputs.loginButtonPressed()
  }

  internal func dismissKeyboard() {
    self.view.endEditing(true)
  }

  private func onLoginSuccess() {
    self.navigationController?.tabBarController?.selectedIndex = 0
    self.navigationController?.popToRootViewControllerAnimated(false)
  }

  private func presentError(message: String) {
    let alertController = UIAlertController.genericError(message)
    self.presentViewController(alertController, animated: true, completion: nil)
  }
}