//
//  CryptoAddressTextFieldViewModel.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 3/15/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public final class CryptoAddressTextFieldViewModel: TextFieldViewModel {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(validator: TextValidating,
                messageRecorder: MessageRecording) {
        super.init(
            with: .cryptoAddress,
            validator: validator,
            messageRecorder: messageRecorder
        )
        
        let content = ImageViewContent(
            imageName: "Icon-qr",
            accessibility: .none,
            bundle: .platformUIKit
        )
        let viewModel = BadgeImageViewModel(cornerRadius: .value(4))
        viewModel.sizingTypeRelay.accept(.constant(CGSize(width: 32, height: 20)))
        viewModel.marginOffsetRelay.accept(0)
        viewModel.imageContentRelay.accept(content)
        viewModel.backgroundColorRelay.accept(.white)
        
        Observable.just(.badgeImageView(viewModel))
            .bindAndCatch(to: accessoryContentTypeRelay)
            .disposed(by: disposeBag)
    }
}
