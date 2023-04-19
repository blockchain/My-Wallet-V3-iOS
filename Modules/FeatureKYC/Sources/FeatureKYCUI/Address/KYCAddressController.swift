// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureKYCDomain
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit
import UIKit

class KYCAddressController: KYCBaseViewController, ValidationFormView, ProgressableView {

    // MARK: ProgressableView

    var barColor: UIColor = .green
    var startingValue: Float = 0.6
    @IBOutlet var progressView: UIProgressView!

    // MARK: - Private IBOutlets

    @IBOutlet fileprivate var searchBar: UISearchBar!
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var activityIndicator: UIActivityIndicatorView!
    @IBOutlet fileprivate var labelFooter: UILabel!
    @IBOutlet fileprivate var requiredLabel: UILabel!

    // MARK: Private IBOutlets (ValidationTextField)

    @IBOutlet fileprivate var addressTextField: ValidationTextField!
    @IBOutlet fileprivate var apartmentTextField: ValidationTextField!
    @IBOutlet fileprivate var cityTextField: ValidationTextField!
    @IBOutlet fileprivate var stateTextField: ValidationPickerField!
    @IBOutlet fileprivate var regionTextField: ValidationPickerField!
    @IBOutlet fileprivate var postalCodeTextField: ValidationTextField!
    @IBOutlet fileprivate var primaryButtonContainer: PrimaryButtonContainer!

    private let notificationCenter = NotificationCenter.default
    private let webViewService: WebViewServiceAPI = resolve()
    private let analyticsRecorder: AnalyticsEventRecorderAPI = resolve()

    // MARK: - Public IBOutlets

    @IBOutlet var scrollView: UIScrollView!

    // MARK: - Private ivars

    private var userAddress: UserAddress?

    // MARK: Factory

    override class func make(with coordinator: KYCRouter) -> KYCAddressController {
        let controller = makeFromStoryboard(in: .module)
        controller.router = coordinator
        controller.pageType = .address
        return controller
    }

    // MARK: - KYCOnboardingNavigation

    weak var searchDelegate: SearchControllerDelegate?

    /// `validationFields` are all the fields listed below in a collection.
    /// This is just for convenience purposes when iterating over the fields
    /// and checking validation etc.
    var validationFields: [ValidationTextField] {
        [
            addressTextField,
            apartmentTextField,
            cityTextField,
            stateTextField,
            regionTextField,
            postalCodeTextField
        ]
    }

    var keyboard: KeyboardObserver.Payload?

    // MARK: Private Properties

    fileprivate var locationCoordinator: LocationSuggestionCoordinator!
    fileprivate var dataProvider: LocationDataProvider!

    private static let restrictedCountryIdentifiers: Set<String> = ["CU", "IR", "KP", "SY"]
    private static let countries: [ValidationPickerField.PickerItem] = Locale.isoRegionCodes
        .filter { !restrictedCountryIdentifiers.contains($0) }
        .compactMap { code -> ValidationPickerField.PickerItem? in
            guard let countryName = Locale.current.localizedString(forRegionCode: code) else {
                return nil
            }
            return ValidationPickerField.PickerItem(
                id: code,
                title: countryName
            )
        }
        .sorted {
            $0.title.localizedCompare($1.title) == .orderedAscending
        }

    // MARK: KYCRouterDelegate

    override func apply(model: KYCPageModel) {
        guard case .address(let user, let country, _) = model else { return }
        let countryCode: String? = user.address?.countryCode ?? country?.code
        let state: String? = user.address?.state

        // Disable state and country fields if we already know that information
        // The reason for disabling the fields is that the our APIs don't allow users to change their country and state
        // once initially set. This will change in the future, but not soon.
        userAddress = user.address
        if userAddress?.countryCode != nil {
            regionTextField.isEnabled = false

            if userAddress?.state != nil {
                stateTextField.isEnabled = false
            }
        }

        validationFieldsPlaceholderSetup(countryCode)
        updateStateAndRegionFieldsVisibility()

        regionTextField.options = KYCAddressController.countries
        regionTextField.onSelection = { [weak self] country in
            self?.updateStateAndRegionFieldsVisibility()
            self?.validationFieldsPlaceholderSetup(country?.id)
        }

        if let countryCode {
            regionTextField.selectedOption = regionTextField.options.first { $0.id == countryCode }
        }

        stateTextField.options = UnitedStates.states
            .map(ValidationPickerField.PickerItem.init)
            .sorted(by: { $0.title.localizedCompare($1.title) == .orderedAscending })

        if let state {
            stateTextField.selectedOption = stateTextField.options.first { $0.id == state }
        }

        // NOTE: address is not prefilled. Bug?
        guard let address = user.address else { return }
        addressTextField.text = address.lineOne
        apartmentTextField.text = address.lineTwo
        postalCodeTextField.text = address.postalCode
        cityTextField.text = address.city
    }

    // MARK: Lifecycle

    deinit {
        notificationCenter.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationCoordinator = LocationSuggestionCoordinator(self, interface: self)
        dataProvider = LocationDataProvider(with: tableView)
        searchBar.searchTextField.accessibilityIdentifier = "kyc.address.search_bar"
        searchBar.delegate = self
        tableView.delegate = self
        scrollView.alwaysBounceVertical = true

        searchBar.barTintColor = .clear
        searchBar.placeholder = LocalizationConstants.KYC.yourHomeAddress

        progressView.tintColor = .green
        requiredLabel.text = LocalizationConstants.KYC.required + "*"

        addressTextField.accessibilityIdentifier = "kyc.address.street_field"
        apartmentTextField.accessibilityIdentifier = "kyc.address.apartment_field"
        cityTextField.accessibilityIdentifier = "kyc.address.city_field"
        stateTextField.accessibilityIdentifier = "kyc.address.state_field"
        regionTextField.accessibilityIdentifier = "kyc.address.country_field"
        postalCodeTextField.accessibilityIdentifier = "kyc.address.postcode_field"

        initFooter()
        validationFieldsSetup()
        setupNotifications()

        primaryButtonContainer.title = LocalizationConstants.KYC.submit
        primaryButtonContainer.actionBlock = { [weak self] in
            guard let self else { return }
            primaryButtonTapped()
        }

        setupProgressView()
        setupKeyboard()
    }

    private func setupKeyboard() {
        let bar = UIToolbar()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        bar.items = [flexibleSpace, doneButton]
        bar.sizeToFit()

        validationFields.forEach { $0.accessoryView = bar }

        notificationCenter.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func adjustForKeyboard(notification: Notification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
        guard let keyboardValue = keyboardFrame as? NSValue else {
            return
        }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom,
                right: 0
            )
        }

        scrollView.scrollIndicatorInsets = scrollView.contentInset

        let selectedField = validationFields.first(where: \.isFirstResponder)
        scrollView.scrollRectToVisible(selectedField?.frame ?? .zero, animated: true)
    }

    // MARK: IBActions

    @IBAction func onFooterTapped(_ sender: UITapGestureRecognizer) {
        guard let text = labelFooter.text else {
            return
        }
        if let tosRange = text.range(of: LocalizationConstants.tos),
           sender.didTapAttributedText(in: labelFooter, range: NSRange(tosRange, in: text))
        {
            webViewService.openSafari(url: Constants.Url.termsOfService, from: self)
        }
        if let privacyPolicyRange = text.range(of: LocalizationConstants.privacyPolicy),
           sender.didTapAttributedText(in: labelFooter, range: NSRange(privacyPolicyRange, in: text))
        {
            webViewService.openSafari(url: Constants.Url.privacyPolicy, from: self)
        }
    }

    // MARK: Private Functions

    private func initFooter() {
        // TICKET: IOS-1436
        // Tap target is a bit off here. Refactor ActionableLabel to take in 2 CTAs
        let font = Font(.branded(.montserratRegular), size: .custom(15.0)).result
        let labelAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.gray5
        ]
        let labelText = NSMutableAttributedString(
            string: String(
                format: LocalizationConstants.KYC.termsOfServiceAndPrivacyPolicyNoticeAddress,
                LocalizationConstants.tos,
                LocalizationConstants.privacyPolicy
            ),
            attributes: labelAttributes
        )
        labelText.addForegroundColor(UIColor.brandSecondary, to: LocalizationConstants.tos)
        labelText.addForegroundColor(UIColor.brandSecondary, to: LocalizationConstants.privacyPolicy)
        labelFooter.attributedText = labelText
    }

    fileprivate func validationFieldsSetup() {

        /// Given that this is a form, we want all the fields
        /// except for the last one to prompt the user to
        /// continue to the next field.
        /// We also set the contentType that the field is expecting.
        addressTextField.returnKeyType = .next
        addressTextField.contentType = .streetAddressLine1

        apartmentTextField.returnKeyType = .next
        apartmentTextField.contentType = .streetAddressLine2

        cityTextField.returnKeyType = .next
        cityTextField.contentType = .addressCity

        stateTextField.returnKeyType = .next
        stateTextField.contentType = .addressState

        regionTextField.returnKeyType = .next
        regionTextField.contentType = .countryName

        postalCodeTextField.returnKeyType = .done
        postalCodeTextField.contentType = .postalCode

        validationFields.enumerated().forEach { index, field in
            field.returnTappedBlock = { [weak self] in
                guard let this = self else { return }
                guard this.validationFields.count > index + 1 else {
                    field.resignFocus()
                    return
                }
                let next = this.validationFields[index + 1]
                next.becomeFocused()
            }
        }

        handleKeyboardOffset()
    }

    fileprivate func validationFieldsPlaceholderSetup(_ countryCode: String?) {
        if countryCode?.lowercased() == "us" {
            addressTextField.placeholder = LocalizationConstants.KYC.streetLine + " 1"
            addressTextField.optionalField = false

            apartmentTextField.placeholder = LocalizationConstants.KYC.streetLine + " 2"
            apartmentTextField.optionalField = true

            cityTextField.placeholder = LocalizationConstants.KYC.city
            cityTextField.optionalField = false

            stateTextField.optionalField = false

            postalCodeTextField.placeholder = LocalizationConstants.KYC.zipCode
            postalCodeTextField.optionalField = false
        } else {
            addressTextField.placeholder = LocalizationConstants.KYC.addressLine + " 1"
            addressTextField.optionalField = false

            apartmentTextField.placeholder = LocalizationConstants.KYC.addressLine + " 2"
            apartmentTextField.optionalField = true

            cityTextField.placeholder = LocalizationConstants.KYC.cityTownVillage
            cityTextField.optionalField = false

            stateTextField.optionalField = true

            postalCodeTextField.placeholder = LocalizationConstants.KYC.postalCode
            postalCodeTextField.optionalField = true
        }

        stateTextField.placeholder = LocalizationConstants.KYC.state
        regionTextField.placeholder = LocalizationConstants.KYC.country
        regionTextField.optionalField = false

        validationFields.forEach { field in
            if field.optionalField == false {
                field.placeholder += "*"
            }
        }
    }

    fileprivate func setupNotifications() {
        NotificationCenter.when(UIResponder.keyboardWillHideNotification) { [weak self] _ in
            self?.scrollView.contentInset = .zero
            self?.scrollView.setContentOffset(.zero, animated: true)
        }
    }

    fileprivate func primaryButtonTapped() {
        guard checkFieldsValidity() else { return }

        analyticsRecorder.record(event: AnalyticsEvents.KYC.kycAddressDetailSet)

        validationFields.forEach { $0.resignFocus() }

        let address = UserAddress(
            lineOne: addressTextField.text,
            lineTwo: apartmentTextField.text,
            postalCode: postalCodeTextField.text,
            city: cityTextField.text,
            state: stateTextField.selectedOption?.id,
            countryCode: regionTextField.selectedOption?.id ?? ""
        )
        searchDelegate?.onSubmission(address) { [router, pageType] in
            router?.handle(event: .nextPageFromPageType(pageType, nil))
        }
    }
}

extension KYCAddressController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selection = dataProvider.locationResult.suggestions[indexPath.row]
        locationCoordinator.onSelection(selection)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard searchBar.isFirstResponder else { return }
        searchBar.resignFirstResponder()
        searchDelegate?.onSearchResigned()
    }
}

extension KYCAddressController: LocationSuggestionInterface {
    func termsOfServiceDisclaimer(_ visibility: Visibility) {
        labelFooter.alpha = visibility.defaultAlpha
    }

    func primaryButtonActivityIndicator(_ visibility: Visibility) {
        primaryButtonContainer.isLoading = visibility == .visible
    }

    func primaryButtonEnabled(_ enabled: Bool) {
        primaryButtonContainer.isEnabled = enabled
    }

    func addressEntryView(_ visibility: Visibility) {
        scrollView.alpha = visibility.defaultAlpha
    }

    func populateAddressEntryView(_ address: PostalAddress) {
        // this function is called when the user searches an address via the search bar
        // and they can search for any address. So, if they're initially selected country is the UK,
        // but they search for an address in California, when the data comes back we need to make sure that the
        // newly selected country and state match the data we already had about the user.
        // This is because our BE APIs don't currently allow editing those fields.
        let canEditState = userAddress?.state == nil || userAddress?.state?.contains(address.state ?? "") == true
        let canEditCountry = userAddress?.countryCode == nil || address.countryCode == userAddress?.countryCode
        let canEditCountryAndState = canEditState && canEditCountry
        guard regionTextField.isEnabled || canEditCountryAndState else {
            let alert = UIAlertController(
                title: LocalizationConstants.KYC.Errors.cannotEditCountryOrStateTitle,
                message: LocalizationConstants.KYC.Errors.cannotEditCountryOrStateMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: LocalizationConstants.okString, style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        if let number = address.streetNumber, let street = address.street {
            addressTextField.text = "\(number) \(street)"
        } else {
            addressTextField.text = nil
        }
        apartmentTextField.text = address.unit
        cityTextField.text = address.city
        updateStateAndRegionFieldsVisibility()

        if let state = address.state, !stateTextField.options.isEmpty {
            stateTextField.selectedOption = stateTextField.options.first(where: { option in
                if option.id == state || option.title == state {
                    return true
                }
                return String(describing: option.id)
                    .split(separator: "-")
                    .map(String.init)
                    .contains(state)
            })
        } else {
            stateTextField.selectedOption = nil
        }

        regionTextField.selectedOption = regionTextField.options
            .first(where: { $0.id.lowercased() == address.countryCode?.lowercased() })

        postalCodeTextField.text = address.postalCode
    }

    func updateActivityIndicator(_ visibility: Visibility) {
        visibility == .hidden ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
    }

    func suggestionsList(_ visibility: Visibility) {
        tableView.alpha = visibility.defaultAlpha
    }

    func primaryButton(_ visibility: Visibility) {
        primaryButtonContainer.alpha = visibility.defaultAlpha
    }

    func searchFieldActive(_ isFirstResponder: Bool) {
        switch isFirstResponder {
        case true:
            searchBar.becomeFirstResponder()
        case false:
            searchBar.resignFirstResponder()
        }
    }

    func searchFieldText(_ value: String?) {
        searchBar.text = value
    }

    private func updateStateAndRegionFieldsVisibility() {
        let shouldHideStateField = regionTextField.selectedOption?.id.lowercased() != "us"
        stateTextField.isHidden = shouldHideStateField
        stateTextField.selectedOption = shouldHideStateField ? nil : stateTextField.selectedOption
    }

    func didReceiveError(_ error: Error) {
        let alert = UIAlertController(
            title: LocalizationConstants.Errors.error,
            message: LocalizationConstants.KYC.Errors.genericErrorMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: LocalizationConstants.okString, style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension KYCAddressController: LocationSuggestionCoordinatorDelegate {
    func coordinator(_ locationCoordinator: LocationSuggestionCoordinator, generated address: PostalAddress) {
        // TODO: May not be needed depending on how we pass along the `PostalAddress`
    }

    func coordinator(_ locationCoordinator: LocationSuggestionCoordinator, updated model: LocationSearchResult) {
        dataProvider.locationResult = model
    }
}

extension KYCAddressController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchDelegate?.onStart()
        scrollView.setContentOffset(.zero, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let value = searchBar.text as NSString? {
            let current = value.replacingCharacters(in: range, with: text)
            searchDelegate?.onSearchRequest(current)
        }
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let value = searchBar.text {
            searchDelegate?.onSearchRequest(value)
        }
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchDelegate?.onSearchViewCancel()
        searchBar.text = nil
    }
}

extension KYCAddressController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        validationFields.forEach { $0.resignFocus() }
    }
}
