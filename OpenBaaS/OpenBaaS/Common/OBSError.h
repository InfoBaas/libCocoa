//
//  OBSError.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSError OBSError;

#pragma mark Domains
extern NSString *const kOBSErrorDomainLocal;
extern NSString *const kOBSErrorDomainRemote;

#pragma mark Codes
typedef enum {
    kOBSErrorCodeMissingRequiredParameters,
    kOBSErrorCodeInvalidParameters
} kOBSErrorCode;

#pragma mark UserInfo Keys
// The value for this key is an array with the names of the required parameters
// that are missing. E.g., @[@"param1", @"param2"].
extern NSString *const kOBSErrorUserInfoKeyMissingRequiredParameters;
// The value for this key is an array with the names of the invalid parameters
// followed by the reason of invalidation. E.g., @[@"param1", @"reason1a",
// @"param1", @"reason1b", @"param2", @"reason2a"].
extern NSString *const kOBSErrorUserInfoKeyInvalidParameters;

#pragma mark Errors
extern NSString *const kOBSErrorInvalidParameterBadFormat;
