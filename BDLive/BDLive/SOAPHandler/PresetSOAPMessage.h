//
//  PresetSOAPMessage.h
//  BDLive
//
//  Created by Khanh Le on 12/11/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PresetSOAPMessage : NSObject

+(NSString*)getListCountrySoapMessage:(NSString*)sLang;
+(NSString*)getListCountrySoapAction;

// live
+(NSString*)getListCountryLiveSoapMessage:(NSString*)sLang;
+(NSString*)getListCountryLiveSoapAction;
+(NSString*)getListLeagueLiveByCountrySoapMessage:(NSString*)iID_MaQuocGia sLang:(NSString*)sLang;
+(NSString*)getListLeagueLiveByCountrySoapAction;
+(NSString*)getListLivescoreByLeagueSoapMessage:(NSString*)iID_MaGiai;
+(NSString*)getListLivescoreByLeagueSoapAction;
+(NSString*)getListLeagueByCountrySoapMessage:(NSString*)iID_MaQuocGia sLang:(NSString*)sLang;
+(NSString*)getListLeagueByCountrySoapAction;


+(NSString*) getListLivescoreSoapMessage:(NSUInteger)pageNum;
+(NSString*) getListLivescoreSoapAction;

+(NSString*) getDeviceLikeSoapMessage:(NSString*)deviceToken matran:(NSString*)matran type:(int)type;
+(NSString*) getDeviceLikeSoapAction;

+(NSString*) getDeviceLikeListSoapMessage:(NSString*)deviceToken;
+(NSString*) getDeviceLikeListSoapAction;



+(NSString*) getBxhSoapMessage:(NSString*)iID_MaGiai;
+(NSString*) getBxhSoapAction;


+(NSString*) getMatchDetailSoapMessage:(NSString*)iID_MaTran;
+(NSString*) getMatchDetailSoapAction;

//register
+(NSString*)getRegistrationSoapAction;
+(NSString*)getRegistrationSoapMessage:(NSString*)phonenumber sMatKhau:(NSString*)sMatKhau id_Device:(NSString*)id_Device;

// facebook login/register
+(NSString*)getFBRegistrationSoapMessage:(NSString*)fbID fbName:(NSString*)fbName fbEmail:(NSString*)fbEmail;
+(NSString*)getFBRegistrationSoapAction;

+(NSString*)getValidationPhonenumberSoapMessage:(NSString*)phonenumber;
+(NSString*)getValidationPhonenumberSoapAction;

// change password api
+(NSString*)getChangePasswordSoapAction;
+(NSString*)getChangePasswordSoapMessage:(NSString*)phonenumber oldPass:(NSString*)oldPass myPass:(NSString*)myPass;

+(NSString*)getLoginSoapAction;
+(NSString*)getLoginSoapMessage:(NSString*)phonenumber otp:(NSString*)otp;


+(NSString*)getGamePredictorSoapAction;
+(NSString*)getGamePredictorSoapMessage:(NSUInteger)page username:(NSString*)username;

+(NSString*)getPhongDoSoapAction;
+(NSString*)getPhongDoSoapMessage:(NSString*)sMaTran;
+(NSString*)getPhongDoDetailSoapAction;
+(NSString*)getPhongDoDetailSoapMessage:(NSString*)iID_MaTran;

+(NSString*)getMaytinhDudoanSoapAction;
+(NSString*)getMaytinhDudoanMessage:(NSString*)sMaTran;

+(NSString*)getNhanDinhChuyenGiaSoapAction;
+(NSString*)getNhanDinhChuyenGiaMessage:(NSString*)page;


// expert detail review
+(NSString*)getNhanDinhChuyenGiaChiTietSoapAction;
+(NSString*)getNhanDinhChuyenGiaChiTiestMessage:(NSString*)sMaTran sMaNhanDinh:(NSString*)sMaNhanDinh;


+(NSString*)getNhanDinhChuyenGiaTheoTranSoapAction;
+(NSString*)getNhanDinhChuyenGiaTheoTranMessage:(NSString*)sMaTran;



+(NSString*)getMaytinhDuDoanListSoapAction;
+(NSString*)getMaytinhDuDoanListMessage:(NSString*)page;


// acount info
+(NSString*)getAccountInfoSoapAction;
+(NSString*)getAccountInfoMessage:(NSString*)sUserName;

+(NSString*)getTopCaoThuSoapAction;
+(NSString*)getTopCaoThuMessage;


+(NSString*)get_wsFootBall_Lives_Co_GameDuDoan_SetBet_SoapAction;
+(NSString*)get_wsFootBall_Lives_Co_GameDuDoan_SetBet_Message:(NSString*)iID_MaTran iID_MaDoi:(NSString*)iID_MaDoi sSoDienThoai:(NSString*)sSoDienThoai iBet:(NSUInteger)iBet iKeo:(float)iKeo sKeo:(NSString*)sKeo iBetSelect:(int)iBetSelect iTyLeTien:(float)iTyLeTien iLoaiBet:(int)iLoaiBet;


// chat zone
+(NSString*)get_wsAdd_List_Chat_SoapAction;
+(NSString*)get_wsAdd_List_Chat_Message:(NSString*)user message:(NSString*)message avatar:(NSString*)avatar name:(NSString*)dispName hash:(NSString*)hashMsg;

+(NSString*)get_wsGet_List_Chat_SoapAction;
+(NSString*)get_wsGet_List_Chat_Message;



+(NSString*)get_wsFootBall_List_TopCaoThu_DuDoan_SoapAction;
+(NSString*)get_wsFootBall_List_TopCaoThu_DuDoan_Message;

+(NSString*)get_wsFootBall_List_LichSu_DuDoan_SoapAction;
+(NSString*)get_wsFootBall_List_LichSu_DuDoan_Message:(NSString*)username;


+(NSString*)get_wsUsers_Change_Title_SoapAction;
+(NSString*)get_wsUsers_Change_Title_Message:(NSString*)sUserName dispName:(NSString*)dispName;



+(NSString*)get_wsUsers_TangSao_SoapAction;
+(NSString*)get_wsUsers_TangSao_Message:(NSString*)sUserName sLang:(NSString*)sLang;



+(NSString*)get_wsFootBall_ThongTinDuDoan_SoapAction;
+(NSString*)get_wsFootBall_ThongTinDuDoan_Message:(NSString*)sUserName;


+(NSString*)get_wsFootBall_Livescore_SuKien_SoapAction;
+(NSString*)get_wsFootBall_Livescore_SuKien_Message;


+(NSString*)get_wsFootBall_Livescore_TyLe_SoapAction;
+(NSString*)get_wsFootBall_Livescore_TyLe_Message;


+(NSString*) get_Add_List_MatchComment_SoapMessage:(NSUInteger)iID_MaTran username:(NSString*)username message:(NSString*)message disp:(NSString*)disp sHash:(NSString*)sHash;
+(NSString*) get_Add_List_MatchComment_SoapAction;

+(NSString*) get_Get_List_MatchComment_SoapMessage:(NSUInteger)iID_MaTran;
+(NSString*) get_Get_List_MatchComment_SoapAction;


+(NSString*)get_wsFootBall_Config_IOS_SoapMessage;
+(NSString*)get_wsFootBall_Config_IOS_SoapAction;

+(NSString*)get_wsFootBall_Tran_Co_GameDuDoan_SoapMessage:(NSString*)matran username:(NSString*)username;
+(NSString*)get_wsFootBall_Tran_Co_GameDuDoan_SoapAction;



+(NSString*)get_wsFootBall_ThongBao_SoapAction;
+(NSString*)get_wsFootBall_ThongBao_Message;



+(NSString*)get_wsFootBall_GetLichThiDau_TheoNgay_SoapAction;
+(NSString*)get_wsFootBall_GetLichThiDau_TheoNgay_SoapMessage:(NSString*)MaGiai datetimelocal:(NSString*)datetimelocal HH:(NSString*)HH MM:(NSString*)MM;


+(NSString*)get_wsFootBall_GetLichThiDau_LiveScore_SoapAction;
+(NSString*)get_wsFootBall_GetLichThiDau_LiveScore_SoapMessage:(NSString*)datetimelocal HH:(NSString*)HH MM:(NSString*)MM getdate:(NSString*)getdate today:(NSString*)today;



+(NSString*)get_wsFootBall_ChuyenKhoan_SoapAction;
+(NSString*)get_wsFootBall_ChuyenKhoan_SoapMessage:(NSString*)UserName_Chuyen UserName_Nhan:(NSString*)UserName_Nhan SoTien:(long)SoTien;


+(NSString*)get_wsFootBall_Get_GoiMuaSao_SoapAction;
+(NSString*)get_wsFootBall_Get_GoiMuaSao_SoapMessage:(int)LoaiOS bLoaiTheCao:(int)bLoaiTheCao;


+(NSString*)get_wsFootBall_MuaSao_SoapAction;
+(NSString*)get_wsFootBall_MuaSao_SoapMessage:(int)LoaiOS MaGoi:(int)MaGoi Transaction_ID:(NSString*)Transaction_ID UserName:(NSString*)UserName real_price:(float)real_price so_sao:(NSUInteger)so_sao;



+(NSString*)get_wsFootBall_NapSao_SoapAction;
+(NSString*)get_wsFootBall_NapSao_SoapMessage:(NSString*)TelcoCode CardCode:(NSString*)CardCode UserName:(NSString*)UserName CardID:(NSString*)CardID;



+(NSString*)get_wsFootBall_VongDau_SoapAction;
+(NSString*)get_wsFootBall_VongDau_SoapMessage:(int)MaGiai;


+(NSString*)get_wsFootBall_GetLichThiDau_TheoBang_SoapAction;
+(NSString*)get_wsFootBall_GetLichThiDau_TheoBang_SoapMessage:(int)MaGiai sBang:(NSString*)sBang;

+(NSString*)get_wsFootBall_LiveScore_Euro_SoapAction;
+(NSString*)get_wsFootBall_LiveScore_Euro_SoapMessage:(int)MaGiai sBang:(NSString*)sBang;

+(NSString*)get_wsFootBall_SVD_SoapAction;
+(NSString*)get_wsFootBall_SVD_SoapMessage:(int)MaGiai;

+(NSString*)get_wsFootBall_Ad_Network_SoapAction;
+(NSString*)get_wsFootBall_Ad_Network_SoapMessage;

+(NSString*)get_wsFootBall_wsFootBall_Menu_ChonNhanh_SoapAction;
+(NSString*)get_wsFootBall_wsFootBall_Menu_ChonNhanh_SoapMessage;


+(NSString*)get_wsFootBall_wsFootBall_LiveScore_VongDau_SoapAction;
+(NSString*)get_wsFootBall_wsFootBall_LiveScore_VongDau_SoapMessage:(int)iID_MaGiai;



+(NSString*)get_wsFootBall_MuaSao_Secure_SoapAction;
+(NSString*)get_wsFootBall_MuaSao_Secure_SoapMessage:(int)LoaiOS MaGoi:(int)MaGoi Transaction_ID:(NSString*)Transaction_ID UserName:(NSString*)UserName real_price:(float)real_price so_sao:(NSUInteger)so_sao;


+(NSString*)get_wsFootBall_ChuyenKhoan_Secure_SoapAction;
+(NSString*)get_wsFootBall_ChuyenKhoan_Secure_SoapMessage:(NSString*)UserName_Chuyen UserName_Nhan:(NSString*)UserName_Nhan SoTien:(long)SoTien;



+(NSString*)get_Like_DisLike_MatchComment_SoapAction;
+(NSString*)get_Like_DisLike_MatchComment_SoapMessage:(NSString*)UserName iID_MaTran:(NSString*)iID_MaTran Like_disLike:(int)Like_disLike sHash:(NSString*)sHash;

@end
