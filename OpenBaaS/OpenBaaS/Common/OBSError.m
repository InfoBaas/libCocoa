//
//  OBSError.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSError+.h"

@implementation OBSError @end

#pragma mark Domains
NSString *const kOBSErrorDomainLocal = @"com.openbaas.error.domain.client";
NSString *const kOBSErrorDomainRemote = @"com.openbaas.error.domain.server";

#pragma mark UserInfo Keys
NSString *const kOBSErrorUserInfoKeyMissingRequiredParameters = @"kOBSErrorUserInfoKeyMissingRequiredParameters";
NSString *const kOBSErrorUserInfoKeyInvalidParameters = @"kOBSErrorUserInfoKeyInvalidParameters";

#pragma mark Invalid Parameter Error Reasons
NSString *const kOBSErrorInvalidParameterReasonBadFormat = @"kOBSErrorInvalidParameterReasonBadFormat";
