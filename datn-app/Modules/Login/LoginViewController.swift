//
//  LoginViewController.swift
//  datn-app
//
//  Created by ThiemJason on 11/17/22.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture
import LocalAuthentication
import SVProgressHUD
import Hero

enum LoginViewControllerMode {
    case Lecture
    case Student
    case Choose
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var lblTitle             : UILabel!
    @IBOutlet weak var vContent             : UIView!
    @IBOutlet weak var lblLoginWith         : UILabel!
    
    @IBOutlet weak var vStudent             : UIView!
    @IBOutlet weak var vLecture             : UIView!
    @IBOutlet weak var lblStudent           : UILabel!
    @IBOutlet weak var lblLecture           : UILabel!
    
    @IBOutlet weak var imgUserMode          : UIImageView!
    @IBOutlet weak var vUserName            : TextFieldCustom!
    @IBOutlet weak var vPassword            : TextFieldCustom!
    @IBOutlet weak var btnLogin             : UIButton!
    
    @IBOutlet weak var vImgFastLogin        : UIView!
    @IBOutlet weak var imgFastLogin         : UIImageView!
    @IBOutlet weak var vLoginSite           : UIView!
    @IBOutlet weak var vPerson              : UIView!
    @IBOutlet weak var lblBack              : UILabel!
    @IBOutlet weak var btnBack              : UIButton!
    @IBOutlet weak var vBack                : UIView!
    
    @IBOutlet weak var vBotomImage          : UIView!
    let disposeBag                          = DisposeBag()
    let rxLoginMode                         = BehaviorRelay<LoginViewControllerMode>(value: .Choose)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializedContent()
    }
    
    private func initializedContent() {
        self.lblTitle.textColor             = .white
        self.vContent.layer.cornerRadius    = 24
        self.vContent.clipsToBounds         = true
        self.lblLoginWith.textColor         = Constant.Color.dark_blue
        self.lblLecture.textColor           = Constant.Color.dark_blue
        self.lblStudent.textColor           = Constant.Color.dark_blue
        self.lblBack.textColor              = Constant.Color.dark_blue
        
        switch LAContext.shared.biometricType {
        case .touchID:
            self.imgFastLogin.image         = UIImage(systemName: "touchid")
        case .faceID:
            self.imgFastLogin.image         = UIImage(systemName: "faceid")
        default:
            self.vImgFastLogin.isHidden     = true
        }
        
        self.lblTitle.font                  = UIFont.getOpenSansBoldFont(size: 20)
        self.lblBack.font                   = UIFont.getOpenSansBoldFont(size: 17)
        self.lblStudent.font                = UIFont.getOpenSansSemiBoldFontDefault()
        self.lblLoginWith.font              = UIFont.getOpenSansSemiBoldFontTitle()
        self.lblLecture.font                = UIFont.getOpenSansSemiBoldFontDefault()
        self.lblBack.font                   = UIFont.getOpenSansBoldFont(size: 18)
        
        self.vStudent.setShadowRadiusView()
        self.vLecture.setShadowRadiusView()
        self.vContent.backgroundColor       = Constant.Color.app_background
        self.vImgFastLogin.layer.cornerRadius   = 10
        self.vImgFastLogin.clipsToBounds    = true
        self.vImgFastLogin.layer.borderColor    = Constant.Color.hex_2D74E7.cgColor
        self.vImgFastLogin.layer.borderWidth    = 2
        self.vImgFastLogin.backgroundColor  = Constant.Color.app_background
        
        self.vUserName.isSecureTextField    = false
        self.vPassword.isSecureTextField    = true
        self.vUserName.updateUI()
        self.vPassword.updateUI()
        self.addTxtFieldDesign(textfield: self.vUserName.tfTextField, placeHolder: "T??i kho???n")
        self.addTxtFieldDesign(textfield: self.vPassword.tfTextField, placeHolder: "M???t kh???u")
        self.btnLogin.setBorderButton("????ng nh???p", 10)
        
        self.vLoginSite.isHidden    = true
        self.vPerson.isHidden       = false
        
        self.setupBinding()
        self.handlerAction()
        
        self.vStudent.hero.modifiers = [.translate(y:100)]
        self.vLecture.hero.modifiers = [.translate(y:100)]
        self.imgUserMode.hero.modifiers = [.translate(x:100)]
        
        /// L???y ra T??i kho???n tr?????c ????
        let previousUsername = UserDefaultUtils.shared.getPreviousUsername().deCryptoData()
        if !previousUsername.isEmpty {
            self.rxLoginMode.accept(.Student)
            self.vUserName.tfTextField.text    = previousUsername
        }
    }
    
    private func handlerAction() {
        self.btnLogin.rx.tap.asDriver().drive(onNext: { [weak self] (_) in
            guard let `self` = self else { return }
            
            let isValidUsername = (self.vUserName.tfTextField.text ?? "").isEmpty == false
            let isValidPass     = (self.vPassword.tfTextField.text ?? "").isEmpty == false
            if !(isValidPass && isValidUsername) {
                AppMessagesManager.shared.showMessage(messageType: .error, message: "Vui l??ng ??i???n ?????y ????? th??ng tin")
                return
            }
            
            self.startLogin()
        }).disposed(by: self.disposeBag)
        
        self.vImgFastLogin.rx.tap().asObservable().observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            guard let currentUserName = self.vUserName.tfTextField.text, !currentUserName.isEmpty else {
                AppMessagesManager.shared.showMessage(messageType: .error, message: "Vui l??ng ??i???n ?????y ????? th??ng tin")
                return
            }
            
            self.startAuthentication()
        }).disposed(by: self.disposeBag)
        
        self.btnBack.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.rxLoginMode.accept(.Choose)
        }).disposed(by: self.disposeBag)
        
        self.vStudent.rx.tap().asObservable().observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.rxLoginMode.accept(.Student)
        }).disposed(by: self.disposeBag)
        
        self.vLecture.rx.tap().asObservable().observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.rxLoginMode.accept(.Lecture)
        }).disposed(by: self.disposeBag)
        
        Provider.shared.rxLoading.observe(on: MainScheduler.instance).subscribe(onNext: {(isLoading) in
            if (isLoading ?? false) {
                DispatchQueue.main.async {
                    SVProgressHUD.show()
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        }).disposed(by: self.disposeBag)
    }
    
    private func startLogin() {
        var loginRequest                = LoginRequest()
        loginRequest.username           = self.vUserName.tfTextField.text
        loginRequest.password           = self.vPassword.tfTextField.text
        loginRequest.deviceCode         = UIDevice.current.identifierForVendor?.uuidString
        loginRequest.type               = (self.rxLoginMode.value == .Student) ? 1 : 0
        
        let isValidUsername = (self.vUserName.tfTextField.text ?? "").isEmpty == false
        let isValidPass     = (self.vPassword.tfTextField.text ?? "").isEmpty == false
        if !(isValidPass && isValidUsername) {
            AppMessagesManager.shared.showMessage(messageType: .error, message: "Vui l??ng ??i???n ?????y ????? th??ng tin")
            return
        }
        
        AuthRepository.shared.login(loginRequest: loginRequest) { [weak self] (studentResponse, errorCode) in
            guard let `self` = self else { return }
            SVProgressHUD.dismiss()
            
            /// `ERROR`
            if let errorCode = errorCode {
                switch errorCode {
                case .DeviceInuse:
                    self.showPopup(type: .Attention,
                                   title: "Thi???t b??? ??ang ???????c s??? d???ng cho t??i kho???n kh??c",
                                   content: "Vui l??ng li??n h??? Qu???n l?? ????? ???????c h??? tr???",
                                   isAutoDissmiss: 10,
                                   isDismissable: true)
                case .PasswordIncorrect:
                    self.showPopup(type: .Error,
                                   title: "????ng nh???p kh??ng th??nh c??ng",
                                   content: "Th??ng tin ????ng nh???p ch??a ch??nh x??c, li??n h??? Qu???n l?? ????? ???????c h??? tr???",
                                   isAutoDissmiss: 10,
                                   isDismissable: true)
                case .AccountInuse:
                    self.showPopup(type: .Error,
                                   title: "????ng nh???p tr??n thi???t b??? l???",
                                   content: "Vui l??ng li??n h??? Qu???n l?? ????? ???????c h??? tr???",
                                   isAutoDissmiss: 10,
                                   isDismissable: true)
                case .IDNotfound:
                    self.showPopup(type: .Attention,
                                   title: "????ng nh???p kh??ng th??nh c??ng",
                                   content: "Th??ng tin ????ng nh???p ch??a ch??nh x??c, li??n h??? Qu???n l?? ????? ???????c h??? tr???",
                                   isAutoDissmiss: 10,
                                   isDismissable: true)
                default:
                    self.showPopup(type: .Attention,
                                   title: "K???t n???i h??? th???ng th???t b???i",
                                   content: "???? c?? l???i x???y ra, xin vui l??ng th??? l???i sau",
                                   isAutoDissmiss: 10,
                                   isDismissable: true)
                }
                return;
            }
            
            /// `Th??nh c??ng` + `????ng nh???p l???n ?????u`
            self.onLoginSuccess(studentResponse: studentResponse)
        }
    }
    
    private func showPopup(type: PopupCustomType, title : String, content: String, isAutoDissmiss: Int? = nil, isDismissable: Bool? = nil) {
        let loadingPopup                        = PopupCustom()
        loadingPopup.modalPresentationStyle     = .overFullScreen
        loadingPopup.modalTransitionStyle       = .crossDissolve
        loadingPopup.isAutoDissmis              = isAutoDissmiss
        loadingPopup.isDismissable              = isDismissable
        loadingPopup.popupTitle                 = title
        loadingPopup.popupContent               = content
        loadingPopup.rxPopupCustomMode.accept(type)
        loadingPopup.rxAnimationLoopMode.accept(.playOnce)
        self.present(loadingPopup, animated: true)
    }
    
    private func startAuthentication() {
        LocalAuthenticationService.shared.startAuthentication(reason: "???ng d???ng s??? d???ng FaceID / TouchID ????? ????ng nh???p") { [weak self] (isSuccess) in
            guard let `self` = self else { return }
            if isSuccess {
                let username    = (self.vUserName.tfTextField.text ?? "").enCryptoData()
                let password    = UserDefaultUtils.shared.getAccountPassword(userName: username).deCryptoData()
                
                if password.isEmpty {
                    AppMessagesManager.shared.showMessage(messageType: .error, message: "B???n c???n ????ng nh???p l???i ????? s??? d???ng ???????c t??nh n??ng n??y")
                    return
                }
                self.vPassword.tfTextField.text = password
                self.startLogin()
            }
        }
    }
    
    private func setupBinding() {
        self.rxLoginMode.asDriver().drive(onNext: { [weak self] (mode) in
            guard let `self` = self else { return }
            switch mode {
            case .Choose:
                self.vLoginSite.isHidden    = true
                self.vPerson.isHidden       = false
                self.vBotomImage.isHidden   = false
            case .Lecture:
                self.vLoginSite.isHidden    = false
                self.vPerson.isHidden       = true
                self.vBotomImage.isHidden   = true
                self.imgUserMode.image      = UIImage(named: "teacher")
                
            case .Student:
                self.vLoginSite.isHidden    = false
                self.vPerson.isHidden       = true
                self.vBotomImage.isHidden   = true
                self.imgUserMode.image      = UIImage(named: "student")
            }
            
            /// `Clear input`
            self.vPassword.tfTextField.text = ""
            self.vPassword.rxIsShowContent.accept(false)
        }).disposed(by: self.disposeBag)
    }
}

extension LoginViewController {
    private func onLoginSuccess( studentResponse: StudentModel? ) {
        guard var studentResponse = studentResponse else { return }
        
        /// `Save local`
        if let userName = studentResponse.studentCode,
           let password = studentResponse.password {
            print("Save: \(userName)        | \(password)")
            print("Save local: \(userName.enCryptoData())        | \(password.enCryptoData())")
            /// `L??u l???i t??i kho???n c??`
            UserDefaultUtils.shared.setPreviousUsername(value: userName.enCryptoData())
            UserDefaultUtils.shared.setAccountPassword(userName: userName.enCryptoData(), password: password.enCryptoData())
        }
        
        /// `C???p nh???t l???i tr?????ng UIUD`
        studentResponse.deviceCode  = UIDevice.current.identifierForVendor?.uuidString ?? ""
        var studentUpdate           = StudentModel()
        studentUpdate.id            = studentResponse.id
        studentUpdate.studentCode   = studentResponse.studentCode
        studentUpdate.deviceCode    = studentResponse.deviceCode
        StudentRepository.shared.updateStudent(studentRequest: studentUpdate) { _ in }
        
        /// `Chuy???n sang m??n splash`
        let splashVC        = SplashViewController()
        splashVC.username   = studentResponse.name ?? "Sinh vi??n"
        self.navigationController?.pushViewController(splashVC, animated: true)
    }
}
