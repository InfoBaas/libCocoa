//
//  OBSError.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBSError : NSError @end

#pragma mark Domains
extern NSString *const kOBSErrorDomainLocal;
extern NSString *const kOBSErrorDomainRemote;

#pragma mark Codes
typedef enum {
    kOBSLocalErrorCodeMissingRequiredParameters,
    kOBSLocalErrorCodeInvalidParameters
} OBSLocalErrorCode;
typedef enum {
    kOBSRemoteErrorCodeUnknown
} OBSRemoteErrorCode;

#pragma mark UserInfo Keys
// The value for this key is an array with the names of the required parameters
// that are missing. E.g., @[@"param1", @"param2"].
extern NSString *const kOBSErrorUserInfoKeyMissingRequiredParameters;
// The value for this key is an array with the names of the invalid parameters
// followed by the reason of invalidation. E.g., @[@"param1", @"reason1a",
// @"param1", @"reason1b", @"param2", @"reason2a"].
extern NSString *const kOBSErrorUserInfoKeyInvalidParameters;

#pragma mark Invalid Parameter Error Reasons
extern NSString *const kOBSErrorInvalidParameterReasonBadFormat;
