//
//  OBSSettings.m
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

#import "OBSSettings+.h"

#define _obs_settings_session_token   @"com.openbaas.settings.session.token"
#define _obs_settings_session_userid   @"com.openbaas.settings.session.userid"

void _obs_settings_set_sessionInfo (NSString *sessionToken, NSString *userId)
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (sessionToken) {
        [standardUserDefaults setObject:sessionToken forKey:_obs_settings_session_token];
    } else {
        [standardUserDefaults removeObjectForKey:_obs_settings_session_token];
    }
    if (userId) {
        [standardUserDefaults setObject:userId forKey:_obs_settings_session_userid];
    } else {
        [standardUserDefaults removeObjectForKey:_obs_settings_session_userid];
    }
    [standardUserDefaults synchronize];
}
NSString *_obs_settings_get_sessionToken (void)
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:_obs_settings_session_token];
}
NSString *_obs_settings_get_userId (void)
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:_obs_settings_session_userid];
}
