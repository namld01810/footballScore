//
//  PresetSOAPMessage.m
//  BDLive
//
//  Created by Khanh Le on 12/11/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "PresetSOAPMessage.h"
#import "../Common/xs_common_inc.h"

#define SOAP_COMMON             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" \
                                "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n" \
                                "<soap:Body>\n" \
                                "%@" \
                                "</soap:Body>\n" \
                                "</soap:Envelope>"

static int iToanBo = 9999;

@implementation PresetSOAPMessage

+(NSString*)getListCountrySoapMessage:(NSString*)sLang
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Quocgia xmlns=\"http://tempuri.org/\">\n"
                             "<sLang>%@</sLang>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_Quocgia>\n"
                             "", sLang];
    
   
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    
    return soapMessage;
}
+(NSString*)getListCountrySoapAction
{
    return @"http://tempuri.org/wsFootBall_Quocgia";
}

//
+(NSString*)getListCountryLiveSoapMessage:(NSString*)sLang
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Quocgia_Live xmlns=\"http://tempuri.org/\">\n"
                             "<sLang>%@</sLang>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_Quocgia_Live>\n"
                             "", sLang];
    
    
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}
+(NSString*)getListCountryLiveSoapAction
{
    return @"http://tempuri.org/wsFootBall_Quocgia_Live";
}

//wsFootBall_Giai_Theo_QuocGia_Live
+(NSString*)getListLeagueLiveByCountrySoapMessage:(NSString*)iID_MaQuocGia sLang:(NSString*)sLang
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Giai_Theo_QuocGia_Live xmlns=\"http://tempuri.org/\">\n"
                             "<iID_MaQuocGia>%@</iID_MaQuocGia>\n"
                             "<sLang>%@</sLang>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_Giai_Theo_QuocGia_Live>\n"
                             "", iID_MaQuocGia, sLang];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}
+(NSString*)getListLeagueLiveByCountrySoapAction
{
    return @"http://tempuri.org/wsFootBall_Giai_Theo_QuocGia_Live";
}
//
//wsFootBall_Lives_Theo_GiaiResult
+(NSString*)getListLivescoreByLeagueSoapMessage:(NSString*)iID_MaGiai
{

    NSString* sLang = @"en";
    NSArray* list = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    if (list.count > 0) {
        sLang = [list objectAtIndex:0];
    }
    
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Lives_Theo_Giai xmlns=\"http://tempuri.org/\">\n"
                             "<iID_MaGiai>%@</iID_MaGiai>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "<sLang>%@</sLang>\n"
                             "</wsFootBall_Lives_Theo_Giai>\n"
                             "", iID_MaGiai, sLang];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}
+(NSString*)getListLivescoreByLeagueSoapAction
{
    return @"http://tempuri.org/wsFootBall_Lives_Theo_Giai";
}
//

+(NSString*)getListLeagueByCountrySoapMessage:(NSString*)iID_MaQuocGia sLang:(NSString*)sLang
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Giai_Theo_QuocGia xmlns=\"http://tempuri.org/\">\n"
                             "<iID_MaQuocGia>%@</iID_MaQuocGia>\n"
                             "<sLang>%@</sLang>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_Giai_Theo_QuocGia>\n"
                             "", iID_MaQuocGia, sLang];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}
+(NSString*)getListLeagueByCountrySoapAction
{
    return @"http://tempuri.org/wsFootBall_Giai_Theo_QuocGia";
}


+(NSString*) getListLivescoreSoapMessage:(NSUInteger)pageNum
{
    
    NSString* sLang = @"en";
    NSArray* list = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    if (list.count > 0) {
        sLang = [list objectAtIndex:0];
    }
//    iToanBo
    NSNumber* iToanBoObj = (NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"INTERNET_CONN"];
    
    if (iToanBoObj) {
        iToanBo = [iToanBoObj intValue];
    }
    
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Lives xmlns=\"http://tempuri.org/\">\n"
                             "<page>%lu</page>\n"
                             "<iToanBo>%d</iToanBo>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "<sLang>%@</sLang>\n"
                             "</wsFootBall_Lives>\n"
                             "", pageNum, iToanBo, sLang];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}

+(NSString*) getListLivescoreSoapAction
{
    return @"http://tempuri.org/wsFootBall_Lives";
}

//
+(NSString*) getDeviceLikeSoapMessage:(NSString*)deviceToken matran:(NSString*)matran type:(int)type
{
    
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Device_Like xmlns=\"http://tempuri.org/\">\n"
                             "<device_id>%@</device_id>\n"
                             "<matran>%@</matran>\n"
                             "<type>%d</type>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_Device_Like>\n"
                             "", deviceToken, matran, type];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}

+(NSString*) getDeviceLikeSoapAction
{
    return @"http://tempuri.org/wsFootBall_Device_Like";
}
//

+(NSString*) getDeviceLikeListSoapMessage:(NSString*)deviceToken
{
    NSString* sLang = @"en";
    NSArray* list = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    if (list.count > 0) {
        sLang = [list objectAtIndex:0];
    }
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Device_Like_List xmlns=\"http://tempuri.org/\">\n"
                             "<device_id>%@</device_id>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "<sLang>%@</sLang>"
                             "</wsFootBall_Device_Like_List>\n"
                             "", deviceToken, sLang];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
    
}
+(NSString*) getDeviceLikeListSoapAction
{
    return @"http://tempuri.org/wsFootBall_Device_Like_List";
}



+(NSString*) getBxhSoapMessage:(NSString*)iID_MaGiai
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_BangXepHang xmlns=\"http://tempuri.org/\">\n"
                             "<iID_MaGiai>%@</iID_MaGiai>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_BangXepHang>\n"
                             "", iID_MaGiai];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}
+(NSString*) getBxhSoapAction
{
    return @"http://tempuri.org/wsFootBall_BangXepHang";
}



+(NSString*) getMatchDetailSoapMessage:(NSString*)iID_MaTran
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_ChiTiet_Tran xmlns=\"http://tempuri.org/\">\n"
                             "<iID_MaTran>%@</iID_MaTran>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_ChiTiet_Tran>\n"
                             "", iID_MaTran];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}
+(NSString*) getMatchDetailSoapAction
{
    return @"http://tempuri.org/wsFootBall_ChiTiet_Tran";
}


// register
+(NSString*)getRegistrationSoapMessage:(NSString*)phonenumber sMatKhau:(NSString*)sMatKhau id_Device:(NSString*)id_Device
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsUsers_Register xmlns=\"http://tempuri.org/\">\n"
                             "<sSoDienThoai>%@</sSoDienThoai>\n"
                             "<sMatKhau>%@</sMatKhau>\n"
                             "<id_Device>%@</id_Device>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsUsers_Register>\n"
                             "", phonenumber, sMatKhau, id_Device];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}
+(NSString*)getRegistrationSoapAction
{
    return @"http://tempuri.org/wsUsers_Register";
}



//

// validate phone number
+(NSString*)getValidationPhonenumberSoapMessage:(NSString*)phonenumber
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsUsers_Check_Login xmlns=\"http://tempuri.org/\">\n"
                             "<sSoDienThoai>%@</sSoDienThoai>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsUsers_Check_Login>\n"
                             "", phonenumber];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}
+(NSString*)getValidationPhonenumberSoapAction
{
    return @"http://tempuri.org/wsUsers_Check_Login";
}
//

// facebook login/register
+(NSString*)getFBRegistrationSoapMessage:(NSString*)fbID fbName:(NSString*)fbName fbEmail:(NSString*)fbEmail
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsUsers_Register_Face xmlns=\"http://tempuri.org/\">\n"
                             "<fb_id>%@</fb_id>\n"
                             "<fb_name>%@</fb_name>\n"
                             "<fb_email>%@</fb_email>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsUsers_Register_Face>\n"
                             "", fbID, fbName, fbEmail];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}
+(NSString*)getFBRegistrationSoapAction
{
    return @"http://tempuri.org/wsUsers_Register_Face";
}
//

+(NSString*)getLoginSoapAction
{
    return @"http://tempuri.org/wsUsers_Login";
}
+(NSString*)getLoginSoapMessage:(NSString*)phonenumber otp:(NSString*)otp
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsUsers_Login xmlns=\"http://tempuri.org/\">\n"
                             "<sSoDienThoai>%@</sSoDienThoai>\n"
                             "<sOTP>%@</sOTP>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsUsers_Login>\n"
                             "", phonenumber, otp];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}

// change password
+(NSString*)getChangePasswordSoapAction
{
    return @"http://tempuri.org/wsUsers_Change_Password";
}
+(NSString*)getChangePasswordSoapMessage:(NSString*)phonenumber oldPass:(NSString*)oldPass myPass:(NSString*)myPass
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsUsers_Change_Password xmlns=\"http://tempuri.org/\">\n"
                             "<sUserName>%@</sUserName>\n"
                             "<sOldPassword>%@</sOldPassword>\n"
                             "\n<sNewPassword>%@</sNewPassword>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsUsers_Change_Password>\n"
                             "", phonenumber, oldPass, myPass];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}

+(NSString*)getGamePredictorSoapAction
{
    return @"http://tempuri.org/wsFootBall_Lives_Co_GameDuDoan";
}
+(NSString*)getGamePredictorSoapMessage:(NSUInteger)page username:(NSString*)username
{
    NSString* sLang = @"en";
    NSArray* list = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    if (list.count > 0) {
        sLang = [list objectAtIndex:0];
    }
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Lives_Co_GameDuDoan xmlns=\"http://tempuri.org/\">\n"
                             "<page>%lu</page>\n"
                             "<UserName>%@</UserName>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "<sLang>%@</sLang>\n"
                             "</wsFootBall_Lives_Co_GameDuDoan>\n"
                             "", page, username, sLang];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}


+(NSString*)getMaytinhDudoanSoapAction
{
    return @"http://tempuri.org/wsFootBall_MayTinhDuDoan";
}
+(NSString*)getMaytinhDudoanMessage:(NSString*)sMaTran
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_MayTinhDuDoan xmlns=\"http://tempuri.org/\">\n"
                             "<iID_MaTran>%@</iID_MaTran>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_MayTinhDuDoan>\n"
                             "", sMaTran];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
    
}


+(NSString*)getPhongDoSoapAction
{
    return @"http://tempuri.org/wsFootBall_Phong_Do";
}
+(NSString*)getPhongDoSoapMessage:(NSString*)sMaTran
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Phong_Do xmlns=\"http://tempuri.org/\">\n"
                             "<sMaTran>%@</sMaTran>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_Phong_Do>\n"
                             "", sMaTran];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}
+(NSString*)getPhongDoDetailSoapAction
{
    return @"http://tempuri.org/wsFootBall_Phong_Do_ChiTiet";
}
+(NSString*)getPhongDoDetailSoapMessage:(NSString*)iID_MaTran
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Phong_Do_ChiTiet xmlns=\"http://tempuri.org/\">\n"
                             "<iID_MaTran>%@</iID_MaTran>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_Phong_Do_ChiTiet>\n"
                             "", iID_MaTran];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}


+(NSString*)getNhanDinhChuyenGiaSoapAction
{
    return @"http://tempuri.org/wsFootBall_Lives_Co_NhanDinhChuyenGia";
}
+(NSString*)getNhanDinhChuyenGiaMessage:(NSString*)page
{
    NSString* sLang = @"en";
    NSArray* list = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    if (list.count > 0) {
        sLang = [list objectAtIndex:0];
    }
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Lives_Co_NhanDinhChuyenGia xmlns=\"http://tempuri.org/\">\n"
                             "<page>%@</page>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "<sLang>%@</sLang>\n"
                             "</wsFootBall_Lives_Co_NhanDinhChuyenGia>\n"
                             "", page, sLang];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}


+(NSString*)getMaytinhDuDoanListSoapAction
{
    return @"http://tempuri.org/wsFootBall_Lives_Co_MayTinhDuDoan";
}
+(NSString*)getMaytinhDuDoanListMessage:(NSString*)page
{
    NSString* sLang = @"en";
    NSArray* list = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    if (list.count > 0) {
        sLang = [list objectAtIndex:0];
    }
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Lives_Co_MayTinhDuDoan xmlns=\"http://tempuri.org/\">\n"
                             "<page>%@</page>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "<sLang>%@</sLang>\n"
                             "</wsFootBall_Lives_Co_MayTinhDuDoan>\n"
                             "", page, sLang];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}


+(NSString*)getNhanDinhChuyenGiaChiTietSoapAction
{
    return @"http://tempuri.org/wsFootBall_Nhan_Dinh_Chuyen_Gia_ChiTiet";
}
+(NSString*)getNhanDinhChuyenGiaChiTiestMessage:(NSString*)sMaTran sMaNhanDinh:(NSString*)sMaNhanDinh
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Nhan_Dinh_Chuyen_Gia_ChiTiet xmlns=\"http://tempuri.org/\">\n"
                             "<sMaTran>%@</sMaTran>\n"
                             "<sMaNhanDinh>%@</sMaNhanDinh>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_Nhan_Dinh_Chuyen_Gia_ChiTiet>\n"
                             "", sMaTran, sMaNhanDinh];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}


///
+(NSString*)getNhanDinhChuyenGiaTheoTranSoapAction
{
    return @"http://tempuri.org/wsFootBall_Nhan_Dinh_Chuyen_Gia_Theo_Tran";
}
+(NSString*)getNhanDinhChuyenGiaTheoTranMessage:(NSString*)sMaTran
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Nhan_Dinh_Chuyen_Gia_Theo_Tran xmlns=\"http://tempuri.org/\">\n"
                             "<sMaTran>%@</sMaTran>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_Nhan_Dinh_Chuyen_Gia_Theo_Tran>\n"
                             "", sMaTran];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}


//
+(NSString*)getAccountInfoSoapAction
{
    return @"http://tempuri.org/wsUsers_ThongTin";
}
+(NSString*)getAccountInfoMessage:(NSString*)sUserName
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsUsers_ThongTin xmlns=\"http://tempuri.org/\">\n"
                             "<sUserName>%@</sUserName>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsUsers_ThongTin>\n"
                             "", sUserName];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}


+(NSString*)getTopCaoThuSoapAction
{
    return @"http://tempuri.org/wsUsers_Top_Xu";
}
+(NSString*)getTopCaoThuMessage
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsUsers_Top_Xu xmlns=\"http://tempuri.org/\">\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsUsers_Top_Xu>\n"
                             ""];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}

// ls du doan
+(NSString*)get_wsFootBall_List_TopCaoThu_DuDoan_SoapAction
{
    return @"http://tempuri.org/wsFootBall_List_TopCaoThu_DuDoan";
}
+(NSString*)get_wsFootBall_List_TopCaoThu_DuDoan_Message
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_List_TopCaoThu_DuDoan xmlns=\"http://tempuri.org/\">\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_List_TopCaoThu_DuDoan>\n"
                             ""];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}

+(NSString*)get_wsFootBall_List_LichSu_DuDoan_SoapAction
{
    return @"http://tempuri.org/wsFootBall_List_LichSu_DuDoan";
}
+(NSString*)get_wsFootBall_List_LichSu_DuDoan_Message:(NSString*)username
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_List_LichSu_DuDoan xmlns=\"http://tempuri.org/\">\n"
                             "<sUserName>%@</sUserName>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_List_LichSu_DuDoan>\n"
                             "", username];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}
//


//wsFootBall_Lives_Co_GameDuDoan_SetBet
+(NSString*)get_wsFootBall_Lives_Co_GameDuDoan_SetBet_SoapAction
{
    return @"http://tempuri.org/wsFootBall_Lives_Co_GameDuDoan_SetBet";
}
+(NSString*)get_wsFootBall_Lives_Co_GameDuDoan_SetBet_Message:(NSString*)iID_MaTran iID_MaDoi:(NSString*)iID_MaDoi sSoDienThoai:(NSString*)sSoDienThoai iBet:(NSUInteger)iBet iKeo:(float)iKeo sKeo:(NSString*)sKeo iBetSelect:(int)iBetSelect iTyLeTien:(float)iTyLeTien iLoaiBet:(int)iLoaiBet
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Lives_Co_GameDuDoan_SetBet xmlns=\"http://tempuri.org/\">\n"
                             "<iID_MaTran>%@</iID_MaTran> \n"
                             "<iID_MaDoi>%@</iID_MaDoi>\n"
                             "<sSoDienThoai>%@</sSoDienThoai>\n"
                             "<iBet>%d</iBet>\n"
                             "<iKeo>%f</iKeo>\n"
                             "<sKeo>%@</sKeo>\n"
                             "<iBetSelect>%d</iBetSelect>\n"
                             "<iTyLeTien>%f</iTyLeTien>\n"
                             "<iLoaiBet>%d</iLoaiBet>"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_Lives_Co_GameDuDoan_SetBet>\n"
                             "", iID_MaTran, iID_MaDoi, sSoDienThoai, iBet, iKeo, sKeo, iBetSelect, iTyLeTien, iLoaiBet];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}



+(NSString*)get_wsAdd_List_Chat_SoapAction
{
    return @"http://tempuri.org/Add_List_Chat";
}
+(NSString*)get_wsAdd_List_Chat_Message:(NSString*)user message:(NSString*)message avatar:(NSString*)avatar name:(NSString*)dispName hash:(NSString*)hashMsg
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<Add_List_Chat xmlns=\"http://tempuri.org/\">\n"
                             "<user>%@</user>\n"
                             "<msg>%@</msg>\n"
                             "<key>%@</key>\n"
                             "<avatar>%@</avatar>\n"
                             "<name>%@</name>\n"
                             "<sHash>%@</sHash>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</Add_List_Chat>\n"
                             "", user, message, SKEY_CHAT_ZONE, avatar, dispName, hashMsg];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}


+(NSString*)get_wsGet_List_Chat_SoapAction
{
    return @"http://tempuri.org/Get_List_Chat";
}
+(NSString*)get_wsGet_List_Chat_Message
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<Get_List_Chat xmlns=\"http://tempuri.org/\">\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</Get_List_Chat>\n"
                             ""];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}



//
+(NSString*)get_wsFootBall_ThongBao_SoapAction
{
    return @"http://tempuri.org/wsFootBall_ThongBao";
}
+(NSString*)get_wsFootBall_ThongBao_Message
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_ThongBao xmlns=\"http://tempuri.org/\">\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_ThongBao>\n"
                             ""];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}
//



//
+(NSString*)get_wsUsers_Change_Title_SoapAction
{
    return @"http://tempuri.org/wsUsers_Change_Title";
}
+(NSString*)get_wsUsers_Change_Title_Message:(NSString*)sUserName dispName:(NSString*)dispName
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsUsers_Change_Title xmlns=\"http://tempuri.org/\">\n"
                             "<sUserName>%@</sUserName>\n"
                             "<sTitle>%@</sTitle>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsUsers_Change_Title>\n"
                             "", sUserName, dispName];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}




+(NSString*)get_wsUsers_TangSao_SoapAction
{
    return @"http://tempuri.org/wsUsers_TangSao";
}
+(NSString*)get_wsUsers_TangSao_Message:(NSString*)sUserName sLang:(NSString*)sLang
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsUsers_TangSao xmlns=\"http://tempuri.org/\">\n"
                             "<sUserName>%@</sUserName>\n"
                             "<sLang>%@</sLang>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsUsers_TangSao>\n"
                             "", sUserName, sLang];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}



+(NSString*)get_wsFootBall_ThongTinDuDoan_SoapAction
{
    return @"http://tempuri.org/wsFootBall_ThongTinDuDoan";
}
+(NSString*)get_wsFootBall_ThongTinDuDoan_Message:(NSString*)sUserName
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_ThongTinDuDoan xmlns=\"http://tempuri.org/\">\n"
                             "<sUserName>%@</sUserName>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_ThongTinDuDoan>\n"
                             "", sUserName];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}



+(NSString*)get_wsFootBall_Livescore_SuKien_SoapAction
{
    return @"http://tempuri.org/wsFootBall_Livescore_SuKien";
}
+(NSString*)get_wsFootBall_Livescore_SuKien_Message
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Livescore_SuKien xmlns=\"http://tempuri.org/\">\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_Livescore_SuKien>\n"
                             ""];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}



//
+(NSString*)get_wsFootBall_Livescore_TyLe_SoapAction
{
    return @"http://tempuri.org/wsFootBall_Livescore_TyLe";
}
+(NSString*)get_wsFootBall_Livescore_TyLe_Message
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Livescore_TyLe xmlns=\"http://tempuri.org/\">\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_Livescore_TyLe>\n"
                             ""];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}


//
+(NSString*) get_Add_List_MatchComment_SoapMessage:(NSUInteger)iID_MaTran username:(NSString*)username message:(NSString*)message disp:(NSString*)disp sHash:(NSString*)sHash
{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<Add_List_MatchComment xmlns=\"http://tempuri.org/\">\n"
                             "<iID_MaTran>%lu</iID_MaTran>\n"
                             "<userName>%@</userName>\n"
                             "<msg>%@</msg>\n"
                             "<avatar></avatar>\n"
                             "<display_Name>%@</display_Name>\n"
                             "<key>%@</key>\n"
                             "<sHash>%@</sHash>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</Add_List_MatchComment>\n"
                             "", iID_MaTran, username, message, disp, SKEY_CHAT_ZONE, sHash];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}
+(NSString*) get_Add_List_MatchComment_SoapAction
{
    return @"http://tempuri.org/Add_List_MatchComment";
}


+(NSString*) get_Get_List_MatchComment_SoapMessage:(NSUInteger)iID_MaTran {
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<Get_List_MatchComment xmlns=\"http://tempuri.org/\">\n"
                             "<iID_MaTran>%lu</iID_MaTran>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</Get_List_MatchComment>\n"
                             "", iID_MaTran];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}
+(NSString*) get_Get_List_MatchComment_SoapAction {
    return @"http://tempuri.org/Get_List_MatchComment";
}


+(NSString*)get_wsFootBall_Config_IOS_SoapMessage {
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Config_IOS xmlns=\"http://tempuri.org/\">\n"
                             "<Version>%d</Version>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_Config_IOS>\n"
                             "", IOS_VERSION_RELEASE];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}
+(NSString*)get_wsFootBall_Config_IOS_SoapAction {
    return @"http://tempuri.org/wsFootBall_Config_IOS";
}


+(NSString*)get_wsFootBall_Tran_Co_GameDuDoan_SoapMessage:(NSString*)matran username:(NSString*)username {
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Tran_Co_GameDuDoan xmlns=\"http://tempuri.org/\">\n"
                             "<MaTran>%@</MaTran>\n"
                             "<UserName>%@</UserName>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_Tran_Co_GameDuDoan>\n"
                             "", matran, username];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}
+(NSString*)get_wsFootBall_Tran_Co_GameDuDoan_SoapAction {
    return @"http://tempuri.org/wsFootBall_Tran_Co_GameDuDoan";
}
//
+(NSString*)get_wsFootBall_GetLichThiDau_TheoNgay_SoapMessage:(NSString*)MaGiai datetimelocal:(NSString*)datetimelocal HH:(NSString*)HH MM:(NSString*)MM {
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_GetLichThiDau_TheoNgay xmlns=\"http://tempuri.org/\">\n"
                             "<MaGiai>%@</MaGiai>\n"
                             "<datetimelocal>%@</datetimelocal>\n"
                             "<hh>%@</hh>\n"
                             "<MM>%@</MM>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_GetLichThiDau_TheoNgay>\n"
                             "", MaGiai, datetimelocal, HH, MM];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}
+(NSString*)get_wsFootBall_GetLichThiDau_TheoNgay_SoapAction {
    return @"http://tempuri.org/wsFootBall_GetLichThiDau_TheoNgay";
}


+(NSString*)get_wsFootBall_GetLichThiDau_LiveScore_SoapMessage:(NSString*)datetimelocal HH:(NSString*)HH MM:(NSString*)MM getdate:(NSString*)getdate today:(NSString*)today{
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_GetLichThiDau_LiveScore xmlns=\"http://tempuri.org/\">\n"
                             "<datetimelocal>%@</datetimelocal>\n"
                             "<hh>%@</hh>\n"
                             "<MM>%@</MM>\n"
                             "<getdate>%@</getdate>\n"
                             "<today>%@</today>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_GetLichThiDau_LiveScore>\n"
                             "", datetimelocal, HH, MM, getdate, today];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}
+(NSString*)get_wsFootBall_GetLichThiDau_LiveScore_SoapAction {
    return @"http://tempuri.org/wsFootBall_GetLichThiDau_LiveScore";
}



+(NSString*)get_wsFootBall_ChuyenKhoan_SoapAction {
    return @"http://tempuri.org/wsFootBall_ChuyenKhoan";
}
+(NSString*)get_wsFootBall_ChuyenKhoan_SoapMessage:(NSString*)UserName_Chuyen UserName_Nhan:(NSString*)UserName_Nhan SoTien:(long)SoTien {
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_ChuyenKhoan xmlns=\"http://tempuri.org/\">\n"
                             "<UserName_Chuyen>%@</UserName_Chuyen>\n"
                             "<UserName_Nhan>%@</UserName_Nhan>\n"
                             "<SoTien>%ld</SoTien>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_ChuyenKhoan>\n"
                             "", UserName_Chuyen, UserName_Nhan, SoTien];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}


+(NSString*)get_wsFootBall_Get_GoiMuaSao_SoapAction {
    return @"http://tempuri.org/wsFootBall_Get_GoiMuaSao";
}
+(NSString*)get_wsFootBall_Get_GoiMuaSao_SoapMessage:(int)LoaiOS bLoaiTheCao:(int)bLoaiTheCao {
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Get_GoiMuaSao xmlns=\"http://tempuri.org/\">\n"
                             "<LoaiOS>%d</LoaiOS>\n"
                             "<bLoaiTheCao>%d</bLoaiTheCao>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_Get_GoiMuaSao>\n"
                             "", LoaiOS, bLoaiTheCao];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}


+(NSString*)get_wsFootBall_MuaSao_SoapAction {
    return @"http://tempuri.org/wsFootBall_MuaSao";
}
+(NSString*)get_wsFootBall_MuaSao_SoapMessage:(int)LoaiOS MaGoi:(int)MaGoi Transaction_ID:(NSString*)Transaction_ID UserName:(NSString*)UserName real_price:(float)real_price so_sao:(NSUInteger)so_sao {
    
    
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_MuaSao xmlns=\"http://tempuri.org/\">\n"
                             "<LoaiOS>%d</LoaiOS>\n"
                             "<MaGoi>%d</MaGoi>\n"
                             "<Transaction_ID>%@</Transaction_ID>\n"
                             "<UserName>%@</UserName>\n"
                             "<real_price>%0.2f</real_price>\n"
                             "<so_sao>%ld</so_sao>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_MuaSao>\n"
                             "", LoaiOS, MaGoi, Transaction_ID, UserName, real_price, so_sao];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}


+(NSString*)get_wsFootBall_NapSao_SoapAction {
    return @"http://tempuri.org/wsFootBall_NapSao";
}
+(NSString*)get_wsFootBall_NapSao_SoapMessage:(NSString*)TelcoCode CardCode:(NSString*)CardCode UserName:(NSString*)UserName CardID:(NSString*)CardID {
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_NapSao xmlns=\"http://tempuri.org/\">\n"
                             "<TelcoCode>%@</TelcoCode>\n"
                             "<CardCode>%@</CardCode>\n"
                             "<CardID>%@</CardID>\n"
                             "<sUserName>%@</sUserName>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_NapSao>\n"
                             "", TelcoCode, CardCode, CardID, UserName];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}



+(NSString*)get_wsFootBall_VongDau_SoapAction {
    return @"http://tempuri.org/wsFootBall_VongDau";
}
+(NSString*)get_wsFootBall_VongDau_SoapMessage:(int)MaGiai {
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_VongDau xmlns=\"http://tempuri.org/\">\n"
                             "<MaGiai>%d</MaGiai>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_VongDau>\n"
                             "", MaGiai];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;

}


+(NSString*)get_wsFootBall_GetLichThiDau_TheoBang_SoapAction {
    return @"http://tempuri.org/wsFootBall_GetLichThiDau_TheoBang";
}
+(NSString*)get_wsFootBall_GetLichThiDau_TheoBang_SoapMessage:(int)MaGiai sBang:(NSString*)sBang {
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_GetLichThiDau_TheoBang xmlns=\"http://tempuri.org/\">\n"
                             "<MaGiai>%d</MaGiai>\n"
                             "<sBang>%@</sBang>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_GetLichThiDau_TheoBang>\n"
                             "", MaGiai, sBang];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}

+(NSString*)get_wsFootBall_LiveScore_Euro_SoapAction {
    return @"http://tempuri.org/wsFootBall_LiveScore_Euro";
}
+(NSString*)get_wsFootBall_LiveScore_Euro_SoapMessage:(int)MaGiai sBang:(NSString*)sBang {
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_LiveScore_Euro xmlns=\"http://tempuri.org/\">\n"
                             "<MaGiai>%d</MaGiai>\n"
                             "<sBang>%@</sBang>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_LiveScore_Euro>\n"
                             "", MaGiai, sBang];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}

+(NSString*)get_wsFootBall_SVD_SoapAction {
    return @"http://tempuri.org/wsFootBall_SVD";
}
+(NSString*)get_wsFootBall_SVD_SoapMessage:(int)MaGiai {
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_SVD xmlns=\"http://tempuri.org/\">\n"
                             "<iID_MaGiai>%d</iID_MaGiai>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_SVD>\n"
                             "", MaGiai];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}

+(NSString*)get_wsFootBall_Ad_Network_SoapAction {
    return @"http://tempuri.org/wsFootBall_Ad_Network";
}
+(NSString*)get_wsFootBall_Ad_Network_SoapMessage {
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Ad_Network xmlns=\"http://tempuri.org/\">\n"
                             "<OS_Type>1</OS_Type>\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_Ad_Network>\n"
                             ""];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}



+(NSString*)get_wsFootBall_wsFootBall_Menu_ChonNhanh_SoapAction {
    return @"http://tempuri.org/wsFootBall_Menu_ChonNhanh";
}
+(NSString*)get_wsFootBall_wsFootBall_Menu_ChonNhanh_SoapMessage {
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_Menu_ChonNhanh xmlns=\"http://tempuri.org/\">\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "</wsFootBall_Menu_ChonNhanh>\n"
                             ""];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}



+(NSString*)get_wsFootBall_wsFootBall_LiveScore_VongDau_SoapAction {
    return @"http://tempuri.org/wsFootBall_LiveScore_VongDau";
}
+(NSString*)get_wsFootBall_wsFootBall_LiveScore_VongDau_SoapMessage:(int)iID_MaGiai {
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_LiveScore_VongDau xmlns=\"http://tempuri.org/\">\n"
                             "<pkey>9a5e2bb919235fbd577ddfa6ca95bd20</pkey>\n"
                             "<iID_MaGiai>%d</iID_MaGiai\n>"
                             "</wsFootBall_LiveScore_VongDau>\n"
                             "", iID_MaGiai];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}



+(NSString*)get_wsFootBall_MuaSao_Secure_SoapAction {
    return @"http://tempuri.org/wsFootBall_MuaSao_Secure";
}


+(NSString*)get_wsFootBall_MuaSao_Secure_SoapMessage:(int)LoaiOS MaGoi:(int)MaGoi Transaction_ID:(NSString*)Transaction_ID UserName:(NSString*)UserName real_price:(float)real_price so_sao:(NSUInteger)so_sao {
    
    
    
    NSData* theData = [XSUtils hmac256ForKeyAndData:@"tmt365@123" data:UserName];
    NSString* verifyKey = [XSUtils byteToNSString:theData];
    
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_MuaSao_Secure xmlns=\"http://tempuri.org/\">\n"
                             "<LoaiOS>%d</LoaiOS>\n"
                             "<MaGoi>%d</MaGoi>\n"
                             "<Transaction_ID>%@</Transaction_ID>\n"
                             "<UserName>%@</UserName>\n"
                             "<real_price>%0.2f</real_price>\n"
                             "<so_sao>%ld</so_sao>\n"
                             "<pkey>%@</pkey>\n"
                             "</wsFootBall_MuaSao_Secure>\n"
                             "", LoaiOS, MaGoi, Transaction_ID, UserName, real_price, so_sao, verifyKey];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}



//
+(NSString*)get_wsFootBall_ChuyenKhoan_Secure_SoapAction {
    return @"http://tempuri.org/wsFootBall_ChuyenKhoan_Secure";
}
+(NSString*)get_wsFootBall_ChuyenKhoan_Secure_SoapMessage:(NSString*)UserName_Chuyen UserName_Nhan:(NSString*)UserName_Nhan SoTien:(long)SoTien {
    
    NSData* theData = [XSUtils hmac256ForKeyAndData:@"tmt365@123" data:[NSString stringWithFormat:@"%@-%@",UserName_Chuyen,UserName_Nhan]];
    NSString* verifyKey = [XSUtils byteToNSString:theData];
    
    
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<wsFootBall_ChuyenKhoan_Secure xmlns=\"http://tempuri.org/\">\n"
                             "<UserName_Chuyen>%@</UserName_Chuyen>\n"
                             "<UserName_Nhan>%@</UserName_Nhan>\n"
                             "<SoTien>%ld</SoTien>\n"
                             "<pkey>%@</pkey>\n"
                             "</wsFootBall_ChuyenKhoan_Secure>\n"
                             "", UserName_Chuyen, UserName_Nhan, SoTien, verifyKey];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}

//
+(NSString*)get_Like_DisLike_MatchComment_SoapAction {
    return @"http://tempuri.org/Like_DisLike_MatchComment";
}
+(NSString*)get_Like_DisLike_MatchComment_SoapMessage:(NSString*)UserName iID_MaTran:(NSString*)iID_MaTran Like_disLike:(int)Like_disLike sHash:(NSString*)sHash {
    NSData* theData = [XSUtils hmac256ForKeyAndData:@"tmt365@123" data:[NSString stringWithFormat:@"%@-%@", UserName, iID_MaTran]];
    NSString* verifyKey = [XSUtils byteToNSString:theData];
    
    
    NSString* soapMessage = [NSString stringWithFormat:@""
                             "<Like_DisLike_MatchComment xmlns=\"http://tempuri.org/\">\n"
                             "<UserName>%@</UserName>\n"
                             "<iID_MaTran>%@</iID_MaTran>\n"
                             "<Like_disLike>%d</Like_disLike>\n"
                             "<sHash>%@</sHash>\n"
                             "<pKey>%@</pKey>\n"
                             "</Like_DisLike_MatchComment>\n"
                             "", UserName, iID_MaTran, Like_disLike, sHash, verifyKey];
    soapMessage = [NSString stringWithFormat:SOAP_COMMON, soapMessage];
    return soapMessage;
}

@end
