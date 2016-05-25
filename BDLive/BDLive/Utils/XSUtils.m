//
//  XSUtils.m
//  BDLive
//
//  Created by Khanh Le on 12/12/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "XSUtils.h"

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation XSUtils


+(NSString*)toDayOfWeek:(NSDate*)date
{
//    //    dateStr = @"01-11-2014";//1: chu nhat
    NSString* dayOfWeek = @"";
//
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//    NSDate *date = [[NSDate alloc] init];
//    date = [dateFormatter dateFromString:dateStr];
    
    
    [dateFormatter setDateFormat:@"HH:mm, dd-MM"];
    NSString* dateStr = [dateFormatter stringFromDate:date];
    
    if(YES) {
        return dateStr;
    }
    
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
    int weekday = [comps weekday];

    
    switch(weekday) {
        case 1:
            // Sunday
            dayOfWeek = [NSString stringWithFormat:@"Chủ nhật, %@", dateStr];
            break;
        case 2:
            // Monday
            dayOfWeek = [NSString stringWithFormat:@"Thứ hai, %@", dateStr];
            break;
        case 3:
            // Tuesday
            dayOfWeek = [NSString stringWithFormat:@"Thứ ba, %@", dateStr];
            break;
        case 4:
            // Wednesday
            dayOfWeek = [NSString stringWithFormat:@"Thứ tư, %@", dateStr];
            break;
        case 5:
            // Thurday
            dayOfWeek = [NSString stringWithFormat:@"Thứ năm, %@", dateStr];
            break;
        case 6:
            // Friday
            dayOfWeek = [NSString stringWithFormat:@"Thứ sáu, %@", dateStr];
            break;
        case 7:
            // Satuday
            dayOfWeek = [NSString stringWithFormat:@"Thứ bảy, %@", dateStr];
            break;
        default:
            // default
            dayOfWeek = [NSString stringWithFormat:@"ngày %@", dateStr];
            break;
            
    }
    
    return dayOfWeek;
}


+(void)setFontFamily:(NSString*)fontFamily forView:(UIView*)view andSubViews:(BOOL)isSubViews
{
//    if(YES) {
//        return;
//    }
    fontFamily = @"VNF-FUTURA";
    if ([view isKindOfClass:[UILabel class]])
    {
        UILabel *lbl = (UILabel *)view;
        float tmp = [[lbl font] pointSize];
        UIFont *f = [UIFont fontWithName:fontFamily size:[[lbl font] pointSize]];
        [lbl setFont:f];
    } else if([view isKindOfClass:[UITextField class]]) {
        UITextField *txt = (UITextField*)view;
        UIFont *f = [UIFont fontWithName:fontFamily size:[[txt font] pointSize]];
        [txt setFont:f];
        
    } else if([view isKindOfClass:[UITextView class]]) {
        UITextView *txt = (UITextView*)view;
        UIFont *f = [UIFont fontWithName:fontFamily size:[[txt font] pointSize]];
        [txt setFont:f];
    }
    
    if (isSubViews)
    {
        for (UIView *sview in view.subviews)
        {
            [self setFontFamily:fontFamily forView:sview andSubViews:YES];
        }
    }
}

+(NSString*)translateSymbolWDL:(NSString*)wdl
{
    wdl = [wdl lowercaseString];
    if([wdl isEqualToString:@"w"]) {
        return @"W";
    }
    
    if([wdl isEqualToString:@"d"]) {
        return @"D";
    }
    
    if([wdl isEqualToString:@"l"]) {
        return @"L";
    }
    
    return @"x";
}

+(UIColor*) makeColorByWDL:(NSString*)wdl
{
    if([wdl isEqualToString:@"W"]) {
        return [UIColor colorWithRed:(0/255.f) green:(153/255.f) blue:(255/255.f) alpha:1.f];
    }
    
    if([wdl isEqualToString:@"D"]) {
        return [UIColor colorWithRed:(255/255.f) green:(254/255.f) blue:(153/255.f) alpha:1.f];
    }
    
    if([wdl isEqualToString:@"L"]) {
        return [UIColor colorWithRed:(254/255.f) green:(0/255.f) blue:(0/255.f) alpha:1.f];
    }
    
    return [UIColor blueColor];
}


// highlighted view when tyso thay doi
+(void)popupHighlightedView:(UIView*)imageView
{
    imageView.hidden = NO;
    imageView.alpha = 1.0f;
//    // Then fades it away after 2 seconds (the cross-fade animation will take 0.5s)
//    [UIView animateWithDuration:0.5 delay:20.0 options:0 animations:^{
//        // Animate the alpha value of your imageView from 1.0 to 0.0 here
//        imageView.alpha = 0.0f;
//    } completion:^(BOOL finished) {
//        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
//        imageView.hidden = YES;
//    }];
}


+(NSString*)format_iBalance:(NSUInteger) iBalance
{
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:iBalance]];
    
    
    if(YES) {
        return formatted;
        
    }
    
    
    NSString* ret = @"";
    NSString* star = [NSString stringWithFormat:@"%d", iBalance];
    
    int cnt = 0;
    for (int i=star.length-1; i >= 0; --i) {
        cnt++;
        ret = [NSString stringWithFormat:@"%C%@",[star characterAtIndex:i], ret];

        
        if (cnt%3==0 && i>0) {

            ret = [NSString stringWithFormat:@"%@%@", @",", ret];
        }
    }
    
    return ret;
}

+(float) convertFloatFromString_SetBet:(NSString*)sKeo
{
    float ret = 0.f;
    @try {
       NSArray* list = [sKeo componentsSeparatedByString:@" "];
        for (int i=0; i<list.count; ++i) {
            // convert now
            NSString* num = [list objectAtIndex:i];
            if ([num rangeOfString:@"/"].location != NSNotFound) {
                //
                NSArray* tmpList = [num componentsSeparatedByString:@"/"];
                NSString* num1 = [tmpList objectAtIndex:0];
                NSString* num2 = [tmpList objectAtIndex:1];
                ret += [num1 floatValue] / [num2 floatValue];
            } else {
                num = [num stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                if (num.length > 0.f) {
                    ret += [num floatValue];
                }
                
            }
        }
        
    }
    @catch (NSException *exception) {
        //
    }
    
    
    
    return ret;
}

+(float) get_tyleChapBong_SetBet:(NSString*)sKeo isHost:(BOOL)isHost
{
    float ret = 0.f;
    @try {
        NSArray* list = [sKeo componentsSeparatedByString:@":"];
        NSString* leftVal = [list objectAtIndex:0];
        NSString* rightVal = [list objectAtIndex:1];
        
        if ([leftVal rangeOfString:@"0"].location != NSNotFound) {
            // keo 0 : x
            if ([rightVal rangeOfString:@"0"].location != NSNotFound) {
                ret = 0.f;
            } else {
                ret = [XSUtils convertFloatFromString_SetBet:rightVal];
            }
            
            if (isHost) {
                ret *= -1;
            }
        } else {
            // keo x : 0
            ret = [XSUtils convertFloatFromString_SetBet:leftVal];
            if (!isHost) {
                ret *= -1;
            }
        }
        
        
    }
    @catch (NSException *exception) {
        //
    }
    
    
    
    return ret;
}


+(UIImage*)imageBaseOnResolution:(NSString*)imagedName ext:(NSString*) ext
{
    if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568)) {
        // ip5
        return [UIImage imageNamed:[NSString stringWithFormat:@"%@-568h%@.%@", imagedName, @"@2x", ext]];
    } else if(([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 480)) {
        // ip4
        return [UIImage imageNamed:[NSString stringWithFormat:@"%@%@.%@", imagedName, @"@2x", ext]];
    } else if(([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 667)) {
        // ip6
        return [UIImage imageNamed:[NSString stringWithFormat:@"%@-667h%@.%@", imagedName, @"@2x", ext]];
    } else if(([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 736)) {
        // ip6+
        return [UIImage imageNamed:[NSString stringWithFormat:@"%@-736h%@.%@", imagedName, @"@3x", ext]];
    } else {
        
    }
    
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@%@.%@", imagedName, @"@2x", ext]];
}

+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(void)adjustUIImageView:(UIImageView*)imgView image:(UIImage*)image {
    if (imgView.bounds.size.width > image.size.width && imgView.bounds.size.height > image.size.height) {
        imgView.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

+(NSString *) stringByStrippingHTML:(NSString*)s {
    NSRange r;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    }
    return s;
}


+(void)setTableFooter:(UITableView*)tableView tap:(UITapGestureRecognizer*) tap {
    UILabel* footerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44.f)];
    footerView.lineBreakMode = NSLineBreakByWordWrapping;
    footerView.numberOfLines = 0;
    footerView.textAlignment = NSTextAlignmentCenter;
    [footerView setFont:[UIFont fontWithName:@"VNF-FUTURA" size:12]];
    footerView.text = @"Copyright © 2015 LiveInfo Services.\nhttp://livescore007.com/";
    
    UIColor* bgColor = [UIColor colorWithRed:(240/255.f) green:(240/255.f) blue:(240/255.f) alpha:1.0f];
    footerView.backgroundColor = bgColor;
    tableView.tableFooterView = footerView;
    
    footerView.userInteractionEnabled = YES;
    [footerView addGestureRecognizer:tap];
    
}


+(NSDate*)getDateByGivenDateInterval:(NSDate*)date dateInterval:(int)dateInterval
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:dateInterval];
    

    return [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:date options:0];
}



+(NSString*)getDateByGivenDateInterval:(NSDate*)date dateFormat:(NSString*)dateFormat dateInterval:(int)dateInterval
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:dateInterval];
    
    NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:date options:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:dateFormat];
    return [dateFormatter stringFromDate:yesterday];
}

+(NSString*)getYesterday:(NSDate*)date dateFormat:(NSString*)dateFormat
{
    
    return [XSUtils getDateByGivenDateInterval:date dateFormat:dateFormat dateInterval:-1];
}

+(NSString*)getNextDay:(NSDate*)date dateFormat:(NSString*)dateFormat
{
    return [XSUtils getDateByGivenDateInterval:date dateFormat:dateFormat dateInterval:1];
}


+(NSData*) hmac256ForKeyAndData:(NSString*)key  data:(NSString*)data
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA512_DIGEST_LENGTH];
    
    //CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    CCHmac(kCCHmacAlgSHA512, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
}


+(NSString*) byteToNSString:(NSData*)theData {
    unsigned char* bytes = (unsigned char*)[theData bytes];
    NSMutableString *hex = [NSMutableString string];
    for (int i = 0; i < [theData length]; i++)
    {
        [hex appendFormat:@"%02X", bytes[i]];
        
    }
    
    return [NSString stringWithString:hex];
}


@end
