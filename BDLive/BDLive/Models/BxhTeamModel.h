//
//  BxhTeamModel.h
//  BDLive
//
//  Created by Khanh Le on 12/12/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BxhTeamModel : NSObject

//[0]	(null)	@"sTenDoi" : @"Arminia Bielefeld"
//[1]	(null)	@"sViTri" : @"1"
//[2]	(null)	@"sHeSo" : @"14"
//[3]	(null)	@"sSoTranDau" : @"20"
//[4]	(null)	@"sSoTranHoa" : @"4"
//[5]	(null)	@"sDiem" : @"37"
//[6]	(null)	@"sBanThang" : @"37"
//[7]	(null)	@"iID_MaBXH" : (long)10278
//[8]	(null)	@"iThoiGian" : (long)1417814006
//[9]	(null)	@"iChiSoBXH" : (long)0
//[10]	(null)	@"sTenGiai" : @"VDQG DUC Hang 3"
//[11]	(null)	@"sMaDoi" : @"BIE"
//[12]	(null)	@"bDangActive" : @"1"
//[13]	(null)	@"sSoTranThua" : @"5"
//[14]	(null)	@"sTongHop" : @"558;Arminia Bielefeld;1;20;37;11;4;5;37;23;14;w,w,w,d,l"
//[15]	(null)	@"iSTT" : (long)0
//[16]	(null)	@"sSoTranThang" : @"11"
//[17]	(null)	@"iID_MaDoi" : (long)369
//[18]	(null)	@"sLast5Match" : @"w,w,w,d,l"
//[19]	(null)	@"iID_MaBXH_ChiTiet" : (long)147893
//[20]	(null)	@"iID_MaGiai" : (long)2422223
//[21]	(null)	@"sMaGiai" : @"DUC3"
//[22]	(null)	@"sTieuDeBXH" : @""
//[23]	(null)	@"sBanThua" : @"23"

@property(nonatomic, strong) NSString* sTenDoi;
@property(nonatomic, strong) NSString* sViTri;
@property(nonatomic, strong) NSString* sHeSo;
@property(nonatomic, strong) NSString* sSoTranDau;
@property(nonatomic, strong) NSString* sSoTranHoa;
@property(nonatomic, strong) NSString* sSoTranThua;
@property(nonatomic, strong) NSString* sDiem;
@property(nonatomic, strong) NSString* sBanThang;
@property(nonatomic, strong) NSString* sBanThua;
@property(nonatomic) NSUInteger iID_MaBXH;
@property(nonatomic) NSUInteger iThoiGian;
@property(nonatomic) int iChiSoBXH;
@property(nonatomic, strong) NSString* sTieuDeBXH;

@property(nonatomic, strong) NSString* sTenGiai;
@property(nonatomic, strong) NSString* sMaDoi;
@property(nonatomic, strong) NSString* sSoTranThang;
@property(nonatomic) NSUInteger iID_MaDoi;
@property(nonatomic, strong) NSString* sLast5Match;

@property(nonatomic) BOOL isHighlighted;

@property(nonatomic, strong) NSString* sLogo;

@end
