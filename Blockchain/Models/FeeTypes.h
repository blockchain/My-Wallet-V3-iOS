//
//  FeeTypes.h
//  Blockchain
//
//  Created by kevinwu on 5/22/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#ifndef FeeTypes_h
#define FeeTypes_h

typedef NS_ENUM(NSInteger, FeeType){
    FeeTypeRegular,
    FeeTypePriority,
    FeeTypeCustom
};

typedef NS_ENUM(NSInteger, FeeUpdateType){
    FeeUpdateTypeNoAction,
    FeeUpdateTypeConfirm,
    FeeUpdateTypeSweep,
};

#endif /* FeeTypes_h */
