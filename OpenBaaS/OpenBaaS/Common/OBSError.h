//
//  OBSError.h
//  OpenBaaS
//
/*****************************************************************************************
 Infosistema - Lib-Cocoa
 Copyright(C) 2002-2014 Infosistema, S.A.
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU Affero General Public License for more details.
 You should have received a copy of the GNU Affero General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
 www.infosistema.com
 info@openbaas.com
 Av. José Gomes Ferreira, 11 3rd floor, s.34
 Miraflores
 1495-139 Algés Portugal
 ****************************************************************************************/

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
    kOBSRemoteErrorCodeUnknown,
    kOBSRemoteErrorCodeResultDataIllFormed
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
