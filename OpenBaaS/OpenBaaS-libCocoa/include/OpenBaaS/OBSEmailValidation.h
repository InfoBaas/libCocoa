//
//  OBSEmailValidation.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This function can be use to verify that a given string is a valid e-mail.
 *
 *  @param email The string to be verified.
 *
 *  @return If `email` is a valid address, `YES` will be returned.
 *          If `email` is nil or a non-valid address, `NO` will be returned.
 */
BOOL obs_validateEmailFormat (NSString *email);
