//
//  OBSError.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSError+_.h"

#pragma mark Domains
NSString *const kOBSErrorDomainLocal = @"com.openbaas.error.domain.client";
NSString *const kOBSErrorDomainRemote = @"com.openbaas.error.domain.server";

#pragma mark UserInfo Keys
NSString *const kOBSErrorUserInfoKeyMissingRequiredParameters = @"com.openbaas.error.userinfo.key.missingrequiredparameters";
NSString *const kOBSErrorUserInfoKeyInvalidParameters = @"com.openbaas.error.userinfo.key.invalidparameters";

#pragma mark Errors
NSString *const kOBSErrorInvalidParameterBadFormat = @"com.openbaas.error.userinfo.invalidparameter.badformat";
