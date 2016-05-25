//
//  SOAPHandler.m
//  BDLive
//
//  Created by Khanh Le on 12/11/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "SOAPHandler.h"

#define REQUEST_TIMEOUT     60

@implementation SOAPHandler

@synthesize webData, soapResults;

-(void) sendPhongDoSOAPRequest:(NSString*)soapMessage soapAction:(NSString*)soapAction type:(NSUInteger)type
{
    NSLog(@"1");
    NSURL *url = [NSURL URLWithString:SOAP_URL];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: soapAction forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    [theRequest setTimeoutInterval:REQUEST_TIMEOUT];
    
    NSURLResponse *urlResponse = nil;
    NSError *requestError = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&requestError];
    
    if(requestError) {
        ZLog(@"got error from response: %@", requestError);
        if(self.delegate!=nil && [self.delegate respondsToSelector:@selector(onSoapError:)]) {
            [self.delegate onSoapError:requestError];
        }
    } else {
        if(self.delegate!=nil && [self.delegate respondsToSelector:@selector(onPhongDoDidFinishLoading:type:)]) {
            [self.delegate onPhongDoDidFinishLoading:data type:type];
        }
    }
    NSString* newStr = [NSString stringWithUTF8String:[data bytes]];
    NSLog(@"string : %@", newStr);
}

-(void) sendAutoSOAPRequest:(NSString*)soapMessage soapAction:(NSString*)soapAction
{
    ZLog(@"sending soap request: %@", soapAction);
    ZLog(@"soap message: %@", soapMessage);
    NSURL *url = [NSURL URLWithString:SOAP_URL];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: soapAction forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    [theRequest setTimeoutInterval:REQUEST_TIMEOUT];
    
    NSURLResponse *urlResponse = nil;
    NSError *requestError = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&requestError];
    
    if(requestError) {
        ZLog(@"got error from response: %@", requestError);
//        if(self.delegate!=nil && [self.delegate respondsToSelector:@selector(onSoapError:)]) {
//            [self.delegate onSoapError:requestError];
//        }
    } else {
        
        //        NSString* data = [[NSString alloc] initWithData:response1 encoding:NSUTF8StringEncoding];
        
        
        if(self.delegate!=nil && [self.delegate respondsToSelector:@selector(onAutoSoapDidFinishLoading:)]) {
            [self.delegate onAutoSoapDidFinishLoading:data];
        }
    }
    NSString* newStr = [NSString stringWithUTF8String:[data bytes]];
    NSLog(@"string 2: %@", newStr);
}

-(void) sendSOAPRequest:(NSString*)soapMessage soapAction:(NSString*)soapAction
{
    NSLog(@"3");
    [self _sendSOAPRequest:soapMessage soapAction:soapAction isReg:NO];
}


-(void) sendSOAPRequestRegistration:(NSString*)soapMessage soapAction:(NSString*)soapAction
{
    NSLog(@"4");
    [self _sendSOAPRequest:soapMessage soapAction:soapAction isReg:YES];
}

-(void) _sendSOAPRequest:(NSString*)soapMessage soapAction:(NSString*)soapAction isReg:(BOOL)isReg
{

    ZLog(@"sending soap request: %@", soapAction);
    ZLog(@"soap message: %@", soapMessage);
    NSURL *url = [NSURL URLWithString: (isReg ? REG_SOAP_URL : SOAP_URL)];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: soapAction forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    [theRequest setTimeoutInterval:REQUEST_TIMEOUT];
    
    NSURLResponse *urlResponse = nil;
    NSError *requestError = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&requestError];
    NSString* newStr = [NSString stringWithUTF8String:[data bytes]];
    NSLog(@"string 5 : %@", newStr);
    if(requestError) {
        ZLog(@"got error from response: %@", requestError);
        if(self.delegate!=nil && [self.delegate respondsToSelector:@selector(onSoapError:)]) {
            [self.delegate onSoapError:requestError];
        }
    } else {

        if(self.delegate!=nil && [self.delegate respondsToSelector:@selector(onSoapDidFinishLoading:)]) {
            [self.delegate onSoapDidFinishLoading:data];
        }
    }
    
}



@end
