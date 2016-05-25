//
//  xs_common_inc.h
//  BDLive
//
//  Created by Khanh Le on 12/9/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#ifndef BDLive_xs_common_inc_h
#define BDLive_xs_common_inc_h

#include "xs_notification_inc.h"
#include "xs_message_inc.h"
#import "../Utils/XSUtils.h"

#define IS_DEBUG    0

// define console log for zapp
#ifndef ZLog
#if IS_DEBUG
#   define ZLog(...) NSLog(__VA_ARGS__)
#else
#   define ZLog(...) { }
#endif
#endif /** ZLog */


//#define SOAP_URL  @"http://210.245.94.14:84/Services/wsfootball.asmx"
//#define SOAP_URL  @"http://210.245.94.14:84/services/wsfootball.asmx"
//#define REG_SOAP_URL  @"http://210.211.100.171/ebank/Services/wsusers.asmx"

//#define SOAP_URL  @"http://117.103.192.91/footballws/Services/wsfootball.asmx"
#define SOAP_URL @"http://livescore007.com/services/wsfootball.asmx"
//#define REG_SOAP_URL  @"http://117.103.192.91/ebank/Services/wsusers.asmx"
#define REG_SOAP_URL  @"http://ebank.livescore007.com/Services/wsusers.asmx"



#define AUTO_REFRESH_MATCH_DETAIL   15.0f

#define AUTO_REFRESH_LIVESCORE   30.0f

#define DEVICE_TOKEN_KEY        @"TySo24_DeviceToken"

#define REGISTRATION_DEVICE_TOKEN_KEY        @"TySo24_DeviceToken_Registration"
#define REGISTRATION_ACOUNT_KEY        @"REGISTRATION_ACOUNT_KEY"
#define REGISTRATION_ACOUNT_PASSWORD        @"REGISTRATION_ACOUNT_PASSWORD"
#define ACOUNT_BALANCE        @"ACOUNT_BALANCE"
#define ACOUNT_DISPLAY_NAME        @"ACOUNT_DISPLAY_NAME"

#define TYSO24H_FIRST_USE        @"TYSO24H_FIRST_USE"




#define FB_ACOUNT_KEY_ID_SUBMITTED        @"FB_ACOUNT_KEY_ID_SUBMITTED"
#define FB_ACOUNT_KEY_ID        @"FB_ACOUNT_KEY_ID"
#define FB_ACOUNT_KEY_BIRTHDAY        @"FB_ACOUNT_KEY_BIRTHDAY"
#define FB_ACOUNT_KEY_EMAIL       @"FB_ACOUNT_KEY_EMAIL"
#define FB_ACOUNT_KEY_GENDER        @"FB_ACOUNT_KEY_GENDER"
#define FB_ACOUNT_KEY_NAME       @"FB_ACOUNT_KEY_NAME"
#define FB_ACOUNT_KEY_FNAME       @"FB_ACOUNT_KEY_FNAME"
#define FB_ACOUNT_KEY_LNAME       @"FB_ACOUNT_KEY_LNAME"



// ----------------------------------
// Admob
#define ADMOB_ID_BANNER         @"ca-app-pub-5258267629624470/9583873549"
#define ADMOB_ID_INTER          @"ca-app-pub-5258267629624470/2060606748"
// ----------------------------------




#define ROOT_IMAGE_URL      @"http://117.103.192.91/footballws"


#define IOS_VERSION_RELEASE 5


// ----------------------------------
// Viettel config
#define VIETTEL_PUB_ID      121399
#define VIETTEL_APP_ID      11480
// ----------------------------------


#endif




/*

./configure --disable-option-checking '--prefix=/Users/khanhle/Documents/viettelsdk_ios/Data/protobuf-555'  '--build=x86_64-apple-darwin13.0.0' '--host=armv7-apple-darwin13.0.0' '--with-protoc=/usr/local/bin/protoc' '--disable-shared' '--exec-prefix=/Users/khanhle/Documents/viettelsdk_ios/Data/protobuf/platform/armv7' 'CC=clang' 'CFLAGS=-DNDEBUG -g -O0 -pipe -fPIC -fcxx-exceptions -miphoneos-version-min=6.1 -arch armv7 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iphoneos8.1.sdk' 'CXX=clang' 'CXXFLAGS=-DNDEBUG -g -O0 -pipe -fPIC -fcxx-exceptions -std=c++11 -stdlib=libc++ -arch armv7 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iphoneos8.1.sdk' 'LDFLAGS=-arch armv7 -miphoneos-version-min=6.1 -stdlib=libc++' 'LIBS=-lc++ -lc++abi' 'build_alias=x86_64-apple-darwin13.0.0' 'host_alias=armv7-apple-darwin13.0.0'*/
