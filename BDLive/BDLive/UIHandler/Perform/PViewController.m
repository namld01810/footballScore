//
//  PViewController.m
//  BDLive
//
//  Created by Khanh Le on 12/29/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "PViewController.h"
#import "PHeaderTableViewCell.h"
#import "PHeaderSectionView.h"
#import "POverMatchTableViewCell.h"
#import "AttackOverDefenseTableViewCell.h"
#import "FinalPredictorTableViewCell.h"
#import "../../Models/LivescoreModel.h"
#import "../../SOAPHandler/SOAPHandler.h"
#import "../../SOAPHandler/PresetSOAPMessage.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "../../Models/BxhTeamModel.h"
#import "../BxhTableViewCell.h"
#import "PowerTableViewCell.h"
#import "../../Utils/XSUtils.h"
#import "AsiaTableViewCell.h"
#import "Asia2TableViewCell.h"




static NSString* NIB_PDO_PHEADER_CELL = @"NIB_PDO_PHEADER_CELL";
static NSString* NIB_PDO_POverMatch_CELL = @"NIB_PDO_POverMatch_CELL";
static NSString* NIB_PDO_AttackOverDefense_CELL = @"NIB_PDO_AttackOverDefense_CELL";

static NSString* NIB_POWER_PHEADER_CELL = @"NIB_POWER_PHEADER_CELL";
static NSString* NIB_ASIA_PHEADER_CELL = @"NIB_ASIA_PHEADER_CELL";
static NSString* NIB_ASIA_PHEADER_CELL_2 = @"NIB_ASIA_PHEADER_CELL_2";


#define P_NUMBER_SECTION        7

@interface PViewController () <UITableViewDataSource, UITableViewDelegate, SOAPHandlerDelegate>

@property(nonatomic, strong) IBOutlet UITableView *tableView;

@property(nonatomic, strong) IBOutlet UIImageView *backImg;

@property(nonatomic, strong) IBOutlet UILabel *pageTitle;

@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *loadIndicatorView;
@property(nonatomic, strong) IBOutlet UIButton *loadButton;
//@property(nonatomic, strong) IBOutlet UIImageView *backImg;

@property(nonatomic, strong) NSArray *data1;
@property(nonatomic, strong) NSArray *data2;

@property(nonatomic, strong) SOAPHandler* soapHandler;
@property(atomic, strong) SDWebImageManager *manager;


@property(nonatomic, strong) NSMutableArray *bxhDatasource;
@property(nonatomic, strong) BxhTeamModel *sModel_Nha;
@property(nonatomic, strong) BxhTeamModel *sModel_Khach;

@property(nonatomic, strong) NSMutableArray *sPd_Nha1;
@property(nonatomic, strong) NSMutableArray *sPd_Nha1_1; // san khach
@property(nonatomic, strong) NSMutableArray *sPd_Nha2;

@property(nonatomic, strong) NSMutableArray *sPd_Khach1;
@property(nonatomic, strong) NSMutableArray *sPd_Khach1_1; // san khach
@property(nonatomic, strong) NSMutableArray *sPd_Khach2;

@property(nonatomic, strong) NSMutableDictionary *sMaytinh_Dudoan_Dict;

@property(nonatomic, retain) NSString* totalMatch;
@property(nonatomic, retain) NSString* sDoiNha_Tong_BanThang;
@property(nonatomic, retain) NSString* sDoiKhach_Tong_BanThang;


@property(nonatomic) NSUInteger sotran_doinha_sannha;
@property(nonatomic) NSUInteger sotran_doinha_sankhach;

@property(nonatomic) NSUInteger sotran_doikhach_sannha;
@property(nonatomic) NSUInteger sotran_doikhach_sankhach;

@property(nonatomic) float rTongDiem_DoiKhach;
@property(nonatomic) float rTongDiem_DoiNha;


@property(nonatomic, strong) NSLayoutConstraint *powerConstraint;

@property(nonatomic, strong) NSLayoutConstraint *keoConstraint1;
@property(nonatomic, strong) NSLayoutConstraint *keoConstraint2;
@property(nonatomic, strong) NSLayoutConstraint *keoConstraint3;
@property(nonatomic, strong) NSLayoutConstraint *keoConstraint4;


@end

@implementation PViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.p_type = 0;
        self.soapHandler = [SOAPHandler new];
        self.soapHandler.delegate = self;
        _manager = [SDWebImageManager sharedManager];
        _bxhDatasource = [NSMutableArray new];
        self.sPd_Khach1 = [NSMutableArray new];
        self.sPd_Khach1_1 = [NSMutableArray new];
        self.sPd_Khach2 = [NSMutableArray new];
        self.sPd_Nha1 = [NSMutableArray new];
        self.sPd_Nha1_1 = [NSMutableArray new];
        self.sPd_Nha2 = [NSMutableArray new];
        self.sMaytinh_Dudoan_Dict = [NSMutableDictionary new];
        self.sModel_Khach = nil;
        self.sModel_Nha = nil;
        
        self.totalMatch = @"tổng số";
        
        [self fetchAllInfo];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupData];
    
    [self setupTableNibFiles];
    
    
    self.backImg.userInteractionEnabled = YES;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackClick:)];
    tap.numberOfTapsRequired = 1;
    [self.backImg addGestureRecognizer:tap];
    
    if(self.p_type == 0) {
        // phong do
        NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-hdr-title", @"PHONG ĐỘ")];
        self.pageTitle.text = localizedTxt;
    } else if(self.p_type == 1) {
        // may tinh du doan
        NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-hdr-title-computer-pick", @"MÁY TÍNH DỰ ĐOÁN")];
        self.pageTitle.text = localizedTxt;

    }
    
    self.loadButton.hidden = YES;
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.view andSubViews:YES];
}

-(void)setupTableNibFiles
{
    UINib *pdHeaderCell = [UINib nibWithNibName:@"PHeaderTableViewCell" bundle:nil];
    [self.tableView registerNib:pdHeaderCell forCellReuseIdentifier:NIB_PDO_PHEADER_CELL];
    
    
    UINib *pdMatchCell = [UINib nibWithNibName:@"POverMatchTableViewCell" bundle:nil];
    [self.tableView registerNib:pdMatchCell forCellReuseIdentifier:NIB_PDO_POverMatch_CELL];
    
    UINib *pdAttackCell = [UINib nibWithNibName:@"AttackOverDefenseTableViewCell" bundle:nil];
    [self.tableView registerNib:pdAttackCell forCellReuseIdentifier:NIB_PDO_AttackOverDefense_CELL];
    
    
    
    UINib *powerAttackCell = [UINib nibWithNibName:@"PowerTableViewCell" bundle:nil];
    [self.tableView registerNib:powerAttackCell forCellReuseIdentifier:NIB_POWER_PHEADER_CELL];
    
    
    UINib *asiaAttackCell = [UINib nibWithNibName:@"AsiaTableViewCell" bundle:nil];
    [self.tableView registerNib:asiaAttackCell forCellReuseIdentifier:NIB_ASIA_PHEADER_CELL];
    
    
    
    UINib *asia2AttackCell = [UINib nibWithNibName:@"Asia2TableViewCell" bundle:nil];
    [self.tableView registerNib:asia2AttackCell forCellReuseIdentifier:NIB_ASIA_PHEADER_CELL_2];
}

-(void) onBackClick:(id)sender
{

    
    if(self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void) setupData
{
    
    NSString* d1_localizedTxt1 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section2-content-r1", @"Số trận ghi bàn sân nhà")];
    NSString* d1_localizedTxt2 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section2-content-r2", @"Tỉ lệ ghi bàn sân nhà trung bình")];
    NSString* d1_localizedTxt3 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section2-content-r3", @"Số trận không ghi bàn sân nhà")];
    NSString* d1_localizedTxt4 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section2-content-r4", @"Số trận sạch lưới sân nhà")];
    NSString* d1_localizedTxt5 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section2-content-r5", @"Số trận lọt lưới sân nhà")];
    NSString* d1_localizedTxt6 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section2-content-r6", @"Tỉ lệ lọt lưới sân nhà trung bình")];
    
    
    self.data1 = [[NSArray alloc] initWithObjects:@"", d1_localizedTxt1, d1_localizedTxt2, d1_localizedTxt3, d1_localizedTxt4, d1_localizedTxt5, d1_localizedTxt6, nil];
    
    
    
    NSString* d2_localizedTxt1 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section3-content-r1", @"Tỉ lệ ghi bàn trung bình")];
    NSString* d2_localizedTxt2 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section3-content-r2", @"Số trận không ghi bàn")];
    NSString* d2_localizedTxt3 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section3-content-r3", @"Số trận ghi bàn")];
    NSString* d2_localizedTxt4 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section3-content-r4", @"Hiệu số bàn thắng")];
    NSString* d2_localizedTxt5 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section3-content-r5", @"Tỉ lệ lọt lưới trung bình")];
    NSString* d2_localizedTxt6 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section3-content-r6", @"Số trận không lọt lưới")];
    NSString* d2_localizedTxt7 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section3-content-r7", @"Số trận lọt lưới")];
    NSString* d2_localizedTxt8 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section3-content-r8", @"Hiệu số bàn thua")];
    
    
    NSString* tancongL = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-hdr-tancong", @"Tấn công")];
    NSString* phongthuL = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-hdr-phongthu", @"Phòng thủ")];
    
    
    
    self.data2 = [[NSArray alloc] initWithObjects:tancongL,d2_localizedTxt1,d2_localizedTxt2,d2_localizedTxt3, d2_localizedTxt4,phongthuL,d2_localizedTxt5, d2_localizedTxt6, d2_localizedTxt7, d2_localizedTxt8,nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    if(self.p_type == 0) {
        return P_NUMBER_SECTION - 1;
    }
    
    return P_NUMBER_SECTION + 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0) {
        return 0;
    }
    return 27.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        return 114.0f;
    } else if(indexPath.section == (P_NUMBER_SECTION)) {
        if (indexPath.row > 0) {
            return 33.f;
        }
        return 70.0f;
    } else if(indexPath.section == (P_NUMBER_SECTION-1)) {
        return 30.0f;
    } else if(indexPath.section == 1) {
        return 25.0f;
    }
    return 35.0f;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    PHeaderSectionView *hdrView = [[[NSBundle mainBundle] loadNibNamed:@"PHeaderSectionView" owner:nil options:nil] objectAtIndex:0];
    
    if (section == 1) {
        NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section1-title", @"Bảng xếp hạng của 2 đội")];

        hdrView.colLabel1.text = localizedTxt;
        hdrView.colLabel2.hidden = YES;
    } else if(section == 2) {
//        hdrView.colLabel1.text = @"Phong độ tính trên tổng số trận";
        NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section2-title", @"Phong độ tính trên tổng số trận")];
        hdrView.colLabel1.text = [NSString stringWithFormat:localizedTxt, self.totalMatch];
        hdrView.colLabel2.text = [NSString stringWithFormat:@" %@   ", [self.model.sTenDoiNha uppercaseString] ];;
        
    } else if(section == 3) {
        hdrView.colLabel2.text = [NSString stringWithFormat:@" %@   ", [self.model.sTenDoiKhach uppercaseString] ];;
        
        NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section2-title", @"Phong độ tính trên tổng số trận")];
        hdrView.colLabel1.text = [NSString stringWithFormat:localizedTxt, self.totalMatch];
    } else if(section == 4) {
        hdrView.colLabel2.text = [NSString stringWithFormat:@" %@   ", [self.model.sTenDoiNha uppercaseString] ];;
        
        NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section3-title", @"Khả năng tấn công / phòng thủ")];

        hdrView.colLabel1.text = [NSString stringWithFormat:localizedTxt, self.totalMatch];
    } else if(section == 5) {
        hdrView.colLabel2.text = [NSString stringWithFormat:@" %@   ", [self.model.sTenDoiKhach uppercaseString] ];;
        NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-section3-title", @"Khả năng tấn công / phòng thủ")];
        hdrView.colLabel1.text = [NSString stringWithFormat:localizedTxt, self.totalMatch];;
    } else if(section == 6) {
        NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-hdr-power-title", @"SỨC MẠNH")];
        hdrView.colLabel1.text = localizedTxt;
        hdrView.colLabel2.hidden = YES;
    } else if(section == 7) {
        NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-hdr-final-title", @"DỰ ĐOÁN TỶ SỐ CHUNG CUỘC")];
        hdrView.colLabel1.text = localizedTxt;
        hdrView.colLabel2.hidden = YES;
    } else {
    }
    
    return hdrView;
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0 || section == (P_NUMBER_SECTION - 1)) {
        return 1;
    } else if(section == P_NUMBER_SECTION) {
        return 3;
    } else if(section == 1) {
        
        return (self.bxhDatasource == nil ? 0 : self.bxhDatasource.count + 1);
    } else if(section < 4) {
        return 7;
    } else {
        
        return 10;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(indexPath.section == 0) {
        cell = [self createPHeaderCell:tableView cellForRowAtIndexPath:indexPath];
    }else if(indexPath.section == 1 && self.bxhDatasource.count > 0) {
        // bxh
        cell = [self createBxhShort:tableView cellForRowAtIndexPath:indexPath];
    } else if((indexPath.section == 2 || indexPath.section == 3) && YES){
        cell = [self createDataCell1:tableView cellForRowAtIndexPath:indexPath isHost:YES];
    } else if((indexPath.section == 4 || indexPath.section == 5) && YES) {
        cell = [self createDataCell2:tableView cellForRowAtIndexPath:indexPath isHost:NO];
    }else if(indexPath.section == (P_NUMBER_SECTION - 1)) {
        cell = [self createPowerCell:tableView cellForRowAtIndexPath:indexPath];

    }
    else if(indexPath.section == (P_NUMBER_SECTION)) {
        if (indexPath.row > 0) {
            cell = [self createAsiaFinalCell:tableView cellForRowAtIndexPath:indexPath];
        } else {
            cell = [self createFinalCell:tableView cellForRowAtIndexPath:indexPath];
        }
        
    } else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    
    
    return cell;
}


- (BxhTableViewCell *)createBxhShort:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BxhTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"BxhTableViewCell" owner:nil options:nil] objectAtIndex:0];
    
    

    
    
    
    if(indexPath.row > 0) {
        @try {
            BxhTeamModel *model = [self.bxhDatasource objectAtIndex:(indexPath.row - 1)];
            if(model.isHighlighted ) {
//            if(indexPath.row == 2 || indexPath.row == 5) {
                cell.contentView.backgroundColor = [UIColor colorWithRed:(222/255.f) green:(83/255.f) blue:0.f alpha:0.1f];
            }
            
            [cell passValue:@[model.sViTri, model.sTenDoi, model.sDiem, model.sSoTranDau, model.sSoTranThang, model.sSoTranHoa, model.sSoTranThua, model.sBanThang, model.sBanThua, model.sHeSo]];
        }@catch(NSException *ex) {
            
        }
        
    }
    
    return cell;
}


- (PowerTableViewCell *)createPowerCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PowerTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:NIB_POWER_PHEADER_CELL];
    
    
    float totalScore = (self.rTongDiem_DoiNha + self.rTongDiem_DoiKhach);
    if(totalScore <= 0.f) {
        totalScore = 1.f;
    }
    float hostPower = self.rTongDiem_DoiNha / totalScore;
    float opPower = self.rTongDiem_DoiKhach / totalScore;
    
    NSUInteger hostPowerPercent = (int) (hostPower * 100);
    
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float opWidth = screenWidth * opPower;
    
    cell.leftLabel.text = [NSString stringWithFormat:@"%lu%@", hostPowerPercent, @"%"];
    cell.rightLabel.text = [NSString stringWithFormat:@"%lu%@", (100-hostPowerPercent), @"%"];
    
    
    if (self.powerConstraint) {
        [cell.contentView removeConstraint:self.powerConstraint];
    }
    
    self.powerConstraint = [NSLayoutConstraint constraintWithItem:cell.rightLabel
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:opWidth];
    
    [cell.contentView addConstraint:self.powerConstraint];
    


    
    return cell;
}



- (UITableViewCell *)createAsiaFinalCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AsiaTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NIB_ASIA_PHEADER_CELL];
    float opWidth = 200.f;
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (indexPath.row == 1) {
        BOOL isHost = YES;
        NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-asia-rate", @"Châu Á")];
        cell.leftLabel.text = localizedTxt;
        opWidth = screenWidth*2/3;
        
        
        NSString *msg = @"";
        NSString* retKeo = @"";
        NSString* tyle = [self.model get_sTyLe_ChapBong:self.model.sTyLe_ChapBong];
        
        NSUInteger rBanThang_DoiKhach = [(NSNumber*)[self.sMaytinh_Dudoan_Dict objectForKey:@"rBanThang_DoiKhach"] integerValue];
        
        NSUInteger rBanThang_DoiNha = [(NSNumber*)[self.sMaytinh_Dudoan_Dict objectForKey:@"rBanThang_DoiNha"] integerValue];
        if (rBanThang_DoiNha > rBanThang_DoiKhach) {
            msg = self.model.sTenDoiNha;
            isHost = YES;
        } else if(rBanThang_DoiKhach > rBanThang_DoiNha) {
            msg = self.model.sTenDoiKhach;
            isHost = NO;
        } else {
            isHost = YES;
            
            NSArray* list = [tyle componentsSeparatedByString:@":"];
            if (list.count > 0) {
                if ([[list objectAtIndex:0] rangeOfString:@"0"].location != NSNotFound) {
                    isHost = NO;
                } else {
                    isHost = YES;
                }
            }
            
            if (isHost) {
                msg = self.model.sTenDoiNha;
            } else {
                msg = self.model.sTenDoiKhach;
            }
            
            
            
            
        }
        
        
        
        float tmpRetKeo = [XSUtils get_tyleChapBong_SetBet:tyle isHost:isHost];
        float rawBanThang = tmpRetKeo;
        if (rawBanThang < 0.f) {
            rawBanThang = 0.f - rawBanThang;
        }
        
        
        BOOL selectedHost = NO;
        NSArray* list = [tyle componentsSeparatedByString:@":"];
        if (list.count > 0) {
            if ([[list objectAtIndex:0] rangeOfString:@"0"].location != NSNotFound) {

                
                rawBanThang = rBanThang_DoiNha - rawBanThang;
                if (rawBanThang < rBanThang_DoiKhach) {
                    msg = self.model.sTenDoiKhach;
                    selectedHost = NO;
                } else {
                    msg = self.model.sTenDoiNha;
                    selectedHost = YES;
                }
            } else {
                rawBanThang = rBanThang_DoiNha + rawBanThang;
                if (rawBanThang < rBanThang_DoiKhach) {
                    msg = self.model.sTenDoiKhach;
                    selectedHost = NO;
                } else {
                    msg = self.model.sTenDoiNha;
                    selectedHost = YES;
                }
            }
        }

        tmpRetKeo = [XSUtils get_tyleChapBong_SetBet:tyle isHost:selectedHost];
        
        if(tmpRetKeo > 0) {
            retKeo = [NSString stringWithFormat:@"+%.2f", tmpRetKeo];
        } else {
            retKeo = [NSString stringWithFormat:@"%.2f", tmpRetKeo];
        }
        msg = [NSString stringWithFormat:@"%@ %@", msg, retKeo];
        cell.rightLabel.text = msg;
        
    } else {
        Asia2TableViewCell *cell2 = [self.tableView dequeueReusableCellWithIdentifier:NIB_ASIA_PHEADER_CELL_2]
        ;
        
        [cell2 resetCellState];
        
        float cellW = screenWidth/5.f;
        
        
        if (self.keoConstraint1) {
            [cell.contentView removeConstraints:@[self.keoConstraint1, self.keoConstraint2, self.keoConstraint3]];
        }
        
        
        
        self.keoConstraint1 =[NSLayoutConstraint constraintWithItem:cell2.label1
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:cellW];
        self.keoConstraint2 = [NSLayoutConstraint constraintWithItem:cell2.label2
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0
                                                            constant:cellW];
        self.keoConstraint3 = [NSLayoutConstraint constraintWithItem:cell2.oLabel
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0
                                                            constant:cellW];
        
        
        [cell2.contentView addConstraint:self.keoConstraint1];
        [cell2.contentView addConstraint:self.keoConstraint2];
        [cell2.contentView addConstraint:self.keoConstraint3];
        
        UIColor* selectedC = [UIColor colorWithRed:(72/255.f) green:(174/255.f) blue:(34/255.f) alpha:1.0f];
        NSUInteger rBanThang_DoiKhach = [(NSNumber*)[self.sMaytinh_Dudoan_Dict objectForKey:@"rBanThang_DoiKhach"] integerValue];
        
        NSUInteger rBanThang_DoiNha = [(NSNumber*)[self.sMaytinh_Dudoan_Dict objectForKey:@"rBanThang_DoiNha"] integerValue];
        NSUInteger tongBanThang = rBanThang_DoiKhach + rBanThang_DoiNha;
        if (rBanThang_DoiNha > rBanThang_DoiKhach) {
            cell2.label1.backgroundColor = selectedC;
            
        } else if(rBanThang_DoiKhach > rBanThang_DoiNha) {
            cell2.label2.backgroundColor = selectedC;
            
        } else {
            cell2.xLabel.backgroundColor = selectedC;
        }
        
        if (tongBanThang > 2.5) {
            cell2.oLabel.backgroundColor = selectedC;
        } else {
            cell2.uLabel.backgroundColor = selectedC;
        }
        
        
        return cell2;

    }
    
    
    if (self.keoConstraint4) {
        [cell.contentView removeConstraints:@[self.keoConstraint4]];
    }
    
    self.keoConstraint4 = [NSLayoutConstraint constraintWithItem:cell.rightLabel
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1.0
                                                        constant:opWidth];
    
    [cell.contentView addConstraint:self.keoConstraint4];
    return cell;
}

- (FinalPredictorTableViewCell *)createFinalCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FinalPredictorTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FinalPredictorTableViewCell" owner:nil options:nil] objectAtIndex:0];
    
    
    cell.team1.text = self.model.sTenDoiNha;
    cell.team2.text = self.model.sTenDoiKhach;
    
    
    @try{
        if(self.sMaytinh_Dudoan_Dict.count > 0) {
            
            
            //    [0]	(null)	@"rBanThang_DoiKhach" : (long)1
            //    [1]	(null)	@"rBanThang_DoiNha" : (long)3
            //    [2]	(null)	@"rSoBanCoTheGhi_DoiNha" : (long)3
            //    [3]	(null)	@"rSoBanCoTheGhi_DoiKhach" : (double)1.5
            NSUInteger rBanThang_DoiKhach = [(NSNumber*)[self.sMaytinh_Dudoan_Dict objectForKey:@"rBanThang_DoiKhach"] integerValue];
            
            NSUInteger rBanThang_DoiNha = [(NSNumber*)[self.sMaytinh_Dudoan_Dict objectForKey:@"rBanThang_DoiNha"] integerValue];
            double rSoBanCoTheGhi_DoiNha = [(NSNumber*)[self.sMaytinh_Dudoan_Dict objectForKey:@"rSoBanCoTheGhi_DoiNha"] doubleValue];
            
            double rSoBanCoTheGhi_DoiKhach = [(NSNumber*)[self.sMaytinh_Dudoan_Dict objectForKey:@"rSoBanCoTheGhi_DoiKhach"] doubleValue];
            

            
            NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-hdr-final-msg-predict", @"Số bàn có thể ghi")];
            
            cell.predict1.text =  [NSString stringWithFormat:@"%@: %g",localizedTxt, rSoBanCoTheGhi_DoiNha];
            cell.predict2.text = [NSString stringWithFormat:@"%@: %g",localizedTxt, rSoBanCoTheGhi_DoiKhach];
            cell.finalPredict.text = [NSString stringWithFormat:@"%lu - %lu", rBanThang_DoiNha, rBanThang_DoiKhach];
            
        }
    }@catch(NSException *ex) {
        
    }
    
    return cell;
}

- (PHeaderTableViewCell *)createPHeaderCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PHeaderTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NIB_PDO_PHEADER_CELL];
    
    [self.manager downloadWithURL:[NSURL URLWithString:self.model.sLogoDoiNha]
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         // progression tracking code
     }
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             
             [XSUtils adjustUIImageView:cell.sLogoHostImg image:image];
             [cell.sLogoHostImg setImage:image];
             
             
         }
     }];
    
    [self.manager downloadWithURL:[NSURL URLWithString:self.model.sLogoDoiKhach]
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         // progression tracking code
     }
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             [XSUtils adjustUIImageView:cell.sLogoKhachImg image:image];
             
             [cell.sLogoKhachImg setImage:image];
         }
     }];
    
    if(self.sModel_Nha != nil) {
        NSArray* list = [self.sModel_Nha.sLast5Match componentsSeparatedByString:@","];
        [self passLast5MatchValue:cell list:list isHost:YES];
    }
    if(self.sModel_Khach != nil) {
        NSArray* list = [self.sModel_Khach.sLast5Match componentsSeparatedByString:@","];
        [self passLast5MatchValue:cell list:list isHost:NO];
    }
    
    
    cell.tenDoinha.text = self.model.sTenDoiNha;
    cell.tenDoikhach.text = self.model.sTenDoiKhach;
    

    
    return cell;
}




-(void)passLast5MatchValue:(PHeaderTableViewCell*)cell list:(NSArray*)list isHost:(BOOL)isHost {

    
    for(int i=0;i<list.count;i++) {
        NSString* symbol = [XSUtils translateSymbolWDL:[list objectAtIndex:i]];
        UIColor *color = [XSUtils makeColorByWDL:symbol];
        
        if(isHost) {
            if(i == 0) {
                cell.host1.text = symbol;
                cell.host1.backgroundColor = color;
            } else if(i==1) {
                cell.host2.text = symbol;
                cell.host2.backgroundColor = color;
            } else if(i==2) {
                cell.host3.text = symbol;
                cell.host3.backgroundColor = color;
            } else if(i==3) {
                cell.host4.text = symbol;
                cell.host4.backgroundColor = color;
            } else if(i==4) {
                cell.host5.text = symbol;
                cell.host5.backgroundColor = color;
            } else {

            }
        } else {
            if(i == 0) {
                cell.khach1.text = symbol;
                cell.khach1.backgroundColor = color;
            } else if(i==1) {
                cell.khach2.text = symbol;
                cell.khach2.backgroundColor = color;
            } else if(i==2) {
                cell.khach3.text = symbol;
                cell.khach3.backgroundColor = color;
            } else if(i==3) {
                cell.khach4.text = symbol;
                cell.khach4.backgroundColor = color;
            } else if(i==4) {
                cell.khach5.text = symbol;
                cell.khach5.backgroundColor = color;
            } else {
                
            }
        }
        
    }
    
}

- (POverMatchTableViewCell *)createDataCell1:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath isHost:(BOOL)isHost
{
    
    NSString* localizedBan = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-hdr-ban", @"bàn")];
    NSString* localizedTran = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-hdr-tran", @"trận")];
    
    
    POverMatchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NIB_PDO_POverMatch_CELL];
    
    if(indexPath.row %2 ==1) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:(240/255.f) green:(240/255.f) blue:(240/255.f) alpha:0.7f];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    if(indexPath.row > 0) {
        cell.colLabel1.text = [self.data1 objectAtIndex:indexPath.row];
        @try{
            if(self.sPd_Nha1.count > 0) {
                if(indexPath.section % 2 == 0) {
                    // doi nha
                    cell.colLabel3.text = [self.sPd_Nha1 objectAtIndex:(indexPath.row-1)];
                    cell.colLabel2.text = [self.sPd_Nha1_1 objectAtIndex:(indexPath.row-1)];
                } else {
                    // doi khach
                    cell.colLabel3.text = [self.sPd_Khach1 objectAtIndex:(indexPath.row-1)];
                    cell.colLabel2.text = [self.sPd_Khach1_1 objectAtIndex:(indexPath.row-1)];
                }
                
                
                if ((indexPath.row - 1) == 1 || (indexPath.row - 1) == 5) {
                    cell.colLabel3.text = [NSString stringWithFormat:@"%@ %@/%@", cell.colLabel3.text, localizedBan, localizedTran];
                    cell.colLabel2.text = [NSString stringWithFormat:@"%@ %@/%@", cell.colLabel2.text, localizedBan, localizedTran];
                } else {
                    if(indexPath.section == 3) {
                        // khach
                        cell.colLabel3.text = [NSString stringWithFormat:@"%@ / %lu %@", cell.colLabel3.text, self.sotran_doikhach_sannha, localizedTran];
                        cell.colLabel2.text = [NSString stringWithFormat:@"%@ / %lu %@", cell.colLabel2.text, self.sotran_doikhach_sankhach, localizedTran];
                    } else {
                        // nha
                        cell.colLabel3.text = [NSString stringWithFormat:@"%@ / %lu %@", cell.colLabel3.text, self.sotran_doinha_sannha, localizedTran];
                        cell.colLabel2.text = [NSString stringWithFormat:@"%@ / %lu %@", cell.colLabel2.text, self.sotran_doinha_sankhach, localizedTran];
                    }
                    
                }
                
                
            }
        }@catch(NSException *ex) {
            
        }
        
    } else {
        

        NSString* localizedTxt1 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-hdr-sannha", @"Sân nhà")];
        NSString* localizedTxt2 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-hdr-sankhach", @"Sân khách")];
        cell.colLabel1.text = @"";
        cell.colLabel2.text = localizedTxt2;;
        cell.colLabel3.text = localizedTxt1;
//        cell.colLabel2.numberOfLines = 1;
//        cell.colLabel3.numberOfLines = 1;
//        [cell.colLabel2 sizeToFit];
//        [cell.colLabel3 sizeToFit];
    }
    
    return cell;
}

- (AttackOverDefenseTableViewCell *)createDataCell2:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath isHost:(BOOL)isHost
{
 
    NSString* localizedTran = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-hdr-tran", @"trận")];
    NSString* localizedBan = [NSString stringWithFormat:@"%@", NSLocalizedString(@"pf-hdr-ban", @"bàn")];
    
    
    AttackOverDefenseTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NIB_PDO_AttackOverDefense_CELL];
    
    cell.colLabel1.textColor = [UIColor blackColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    
    NSString* text1 = [self.data2 objectAtIndex:indexPath.row];
    if([text1 isEqualToString:@"Tấn công"] || [text1 isEqualToString:@"Phòng thủ"] ||
       [text1 isEqualToString:@"Attack"] || [text1 isEqualToString:@"Defense"]) {
        if(indexPath.section % 2 == 0) {
            // doi nha
            cell.colLabel2.text = @"";
        } else {
            // doi khach
            cell.colLabel2.text = @"";
        }
        
        cell.colLabel1.textColor = [UIColor colorWithRed:(205/255.f) green:(102/255.f) blue:(1/255.f) alpha:1.0f];
    } else {
        @try{
            if(self.sPd_Khach2.count > 0) {
                if(indexPath.section % 2 == 0) {
                    // doi nha
                    cell.colLabel2.text = [self.sPd_Nha2 objectAtIndex:indexPath.row -1];
                } else {
                    // doi khach
                    cell.colLabel2.text = [self.sPd_Khach2 objectAtIndex:indexPath.row -1];
                }
                
                if(indexPath.row == 1 || indexPath.row == 6) {
                    cell.colLabel2.text = [NSString stringWithFormat:@"%@ %@ / %@", cell.colLabel2.text, localizedBan, localizedTran];
                }else if(indexPath.row == 4 || indexPath.row == 9) {
                    cell.colLabel2.text = [NSString stringWithFormat:@"%@", cell.colLabel2.text];
                } else {
                    cell.colLabel2.text = [NSString stringWithFormat:@"%@ %@", cell.colLabel2.text, localizedTran];
                }
                
                
            }
        }@catch(NSException *ex) {
            
        }
        
        
        if(indexPath.row %2 ==1) {
            cell.contentView.backgroundColor = [UIColor colorWithRed:(240/255.f) green:(240/255.f) blue:(240/255.f) alpha:0.7f];
        } else {
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
    }

    cell.colLabel1.text = [self.data2 objectAtIndex:indexPath.row];

    
    return cell;
}

-(void)onSoapError:(NSError *)error
{
    
}
-(void)onPhongDoDidFinishLoading:(NSData *)data type:(NSUInteger)type
{
    if(type == 0) {
        // phong do
        [self handlePhongDoResponse:data];
    } else if(type == 1) {
        // phong do chi tiet
        [self handlePhongDoDetailResponse:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loadButton.hidden = NO;
            [self.loadIndicatorView stopAnimating];
        });
        
    } else if(type == 2) {
        // may tinh du doan
        [self handleMaytinhDudoanResponse:data];
    }
}

-(void)handleMaytinhDudoanResponse:(NSData *)data
{
    // thong tin bang xep hang
    @try {
        NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_MayTinhDuDoanResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_MayTinhDuDoanResult>"] objectAtIndex:0];
        
        ZLog(@"jsonStr data: %@", jsonStr);
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            [self.sMaytinh_Dudoan_Dict removeAllObjects];
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                
                float rTongDiem_DoiKhach = [(NSNumber*)[dict objectForKey:@"rTongDiem_DoiKhach"] floatValue];
                float rTongDiem_DoiNha = [(NSNumber*)[dict objectForKey:@"rTongDiem_DoiNha"] floatValue];
                
                self.rTongDiem_DoiKhach = rTongDiem_DoiKhach;
                self.rTongDiem_DoiNha = rTongDiem_DoiNha;
                



                
                [self.sMaytinh_Dudoan_Dict addEntriesFromDictionary:dict];
                
            }
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }@catch(NSException *ex) {
        
    }
}


-(void)handlePhongDoResponse:(NSData *)data
{
    // thong tin bang xep hang
    @try {
        NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_Phong_DoResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_Phong_DoResult>"] objectAtIndex:0];
        
        ZLog(@"jsonStr data: %@", jsonStr);
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            NSMutableArray *tmpBxh = [NSMutableArray new];
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                BxhTeamModel *model = [BxhTeamModel new];
                model.sTenDoi = [dict objectForKey:@"sTenDoi"];
                model.sViTri = [dict objectForKey:@"sViTri"];
                model.sDiem = [dict objectForKey:@"sDiem"];
                model.sSoTranDau = [dict objectForKey:@"sSoTranDau"];
                model.sSoTranThang = [dict objectForKey:@"sSoTranThang"];
                model.sSoTranHoa = [dict objectForKey:@"sSoTranHoa"];
                model.sSoTranThua = [dict objectForKey:@"sSoTranThua"];
                model.sBanThang = [dict objectForKey:@"sBanThang"];//37
                model.sBanThua = [dict objectForKey:@"sBanThua"];//23
                model.sHeSo = [dict objectForKey:@"sHeSo"];//14
                model.sLast5Match = [dict objectForKey:@"sLast5Match"];
                model.isHighlighted = NO;
                model.iID_MaDoi = [(NSNumber*)[dict objectForKey:@"iID_MaDoi"] intValue];
                
                if(self.model.iID_MaDoiNha == model.iID_MaDoi ||
                   self.model.iID_MaDoiKhach == model.iID_MaDoi) {

                    
                    if(self.model.iID_MaDoiNha == model.iID_MaDoi) {
                        self.sModel_Nha = model;
                    } else {
                        self.sModel_Khach = model;
                    }
                    
                    
                }
                [tmpBxh addObject:model];
                
                

            }
            
            [self makeShortBxhTable:tmpBxh];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }@catch(NSException *ex) {
        
    }
}

//-(NSUInteger) getIndex

-(void)makeShortBxhTable:(NSMutableArray*)bxhList
{
    NSUInteger sIndex_Nha = [bxhList indexOfObject:self.sModel_Nha];
    NSUInteger sIndex_Khach = [bxhList indexOfObject:self.sModel_Khach];
    NSUInteger sIndex_Min = (sIndex_Nha > sIndex_Khach) ? sIndex_Khach : sIndex_Nha;
    NSUInteger sIndex_Max = (sIndex_Nha > sIndex_Khach) ? sIndex_Nha : sIndex_Khach;
    

    if(sIndex_Min == 0) {
        BxhTeamModel *model = [bxhList objectAtIndex:(sIndex_Min+1)];
        model.isHighlighted = NO;
        [self.bxhDatasource addObject:[bxhList objectAtIndex:sIndex_Min]];
        [self.bxhDatasource addObject:model];
        [self.bxhDatasource addObject:[bxhList objectAtIndex:(sIndex_Min+2)]];
        
        if(sIndex_Max == (bxhList.count - 1)) {
            BxhTeamModel *model2 = [bxhList objectAtIndex:(sIndex_Max-1)];
            model2.isHighlighted = NO;
            [self.bxhDatasource addObject:[bxhList objectAtIndex:sIndex_Max-2]];
            [self.bxhDatasource addObject:model2];
            [self.bxhDatasource addObject:[bxhList objectAtIndex:(sIndex_Max)]];
        } else {
            BxhTeamModel *model2 = [bxhList objectAtIndex:(sIndex_Max)];
            model2.isHighlighted = NO;
            [self.bxhDatasource addObject:[bxhList objectAtIndex:sIndex_Max-1]];
            [self.bxhDatasource addObject:model2];
            [self.bxhDatasource addObject:[bxhList objectAtIndex:(sIndex_Max+1)]];
        }
        
    } else {
        BxhTeamModel *model = [bxhList objectAtIndex:(sIndex_Min)];
        model.isHighlighted = NO;
        [self.bxhDatasource addObject:[bxhList objectAtIndex:sIndex_Min-1]];
        [self.bxhDatasource addObject:model];
        [self.bxhDatasource addObject:[bxhList objectAtIndex:(sIndex_Min+1)]];
        if(sIndex_Max == (bxhList.count - 1)) {
            BxhTeamModel *model2 = [bxhList objectAtIndex:(sIndex_Max-1)];
            model2.isHighlighted = NO;
            [self.bxhDatasource addObject:[bxhList objectAtIndex:sIndex_Max-2]];
            [self.bxhDatasource addObject:model2];
            [self.bxhDatasource addObject:[bxhList objectAtIndex:(sIndex_Max)]];
        } else {
            BxhTeamModel *model2 = [bxhList objectAtIndex:(sIndex_Max)];
            model2.isHighlighted = NO;
            [self.bxhDatasource addObject:[bxhList objectAtIndex:sIndex_Max-1]];
            [self.bxhDatasource addObject:model2];
            [self.bxhDatasource addObject:[bxhList objectAtIndex:(sIndex_Max+1)]];
        }
    }
    
    
    [self refineBxhDatasource];
    
    
    
    
}

-(void)refineBxhDatasource{
    NSMutableArray *tmp = [NSMutableArray new];
    NSMutableDictionary *checker = [NSMutableDictionary new];
    for(int i=0;i<self.bxhDatasource.count;i++) {
        BxhTeamModel *model = [self.bxhDatasource objectAtIndex:(i)];
        model.isHighlighted = NO;
        id indexObj = [checker objectForKey:[NSString stringWithFormat:@"md-%d", model.iID_MaDoi]];
        if(indexObj == nil) {
            
            if(self.model.iID_MaDoiNha == model.iID_MaDoi ||
               self.model.iID_MaDoiKhach == model.iID_MaDoi) {
                model.isHighlighted = YES;
                
            }
            
            
            [tmp addObject:model];
            
            [checker setObject:@"1" forKey:[NSString stringWithFormat:@"md-%d", model.iID_MaDoi]];
        } else {
            if(self.model.iID_MaDoiNha == model.iID_MaDoi ||
               self.model.iID_MaDoiKhach == model.iID_MaDoi) {
                model.isHighlighted = YES;
                
            }
        }

    }
    
    [checker removeAllObjects];
    checker = nil;
    
    [self.bxhDatasource removeAllObjects];
    [self.bxhDatasource addObjectsFromArray:tmp];
}

-(void)handlePhongDoDetailResponse:(NSData *)data
{
    @try {
        NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_Phong_Do_ChiTietResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_Phong_Do_ChiTietResult>"] objectAtIndex:0];
        
        ZLog(@"jsonStr data: %@", jsonStr);
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            
            
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                
                NSUInteger _tmpTotal = [(NSNumber*)[dict objectForKey:@"TongSo_TranDau"] integerValue];
                
                
                self.sotran_doinha_sannha = [[dict objectForKey:@"DoiNha_SoTran_GhiBan_SanNha"] integerValue] + [[dict objectForKey:@"DoiNha_SoTran_Khong_GhiBan_SanNha"] integerValue];
                self.sotran_doinha_sankhach = [[dict objectForKey:@"DoiNha_SoTran_GhiBan_SanKhach"] integerValue] + [[dict objectForKey:@"DoiNha_SoTran_Khong_GhiBan_SanKhach"] integerValue];
                
                
                self.sotran_doikhach_sannha = [[dict objectForKey:@"DoiKhach_SoTran_GhiBan_SanNha"] integerValue] + [[dict objectForKey:@"DoiKhach_SoTran_Khong_GhiBan_SanNha"] integerValue];
                self.sotran_doikhach_sankhach = [[dict objectForKey:@"DoiKhach_SoTran_GhiBan_SanKhach"] integerValue] + [[dict objectForKey:@"DoiKhach_SoTran_Khong_GhiBan_SanKhach"] integerValue];
                

                
               
                [self.sPd_Nha1 addObject:[dict objectForKey:@"DoiNha_SoTran_GhiBan_SanNha"]];
                [self.sPd_Nha1 addObject:[dict objectForKey:@"DoiNha_TyLe_GhiBan_SanNha"]];
                [self.sPd_Nha1 addObject:[dict objectForKey:@"DoiNha_SoTran_Khong_GhiBan_SanNha"]];
                [self.sPd_Nha1 addObject:[dict objectForKey:@"DoiNha_SoTran_SachLuoi_SanNha"]];
                [self.sPd_Nha1 addObject:[dict objectForKey:@"DoiNha_SoTran_LotLuoi_SanNha"]];
                [self.sPd_Nha1 addObject:[dict objectForKey:@"DoiNha_TyLe_LotLuoi_SanNha"]];
                
                [self.sPd_Nha1_1 addObject:[dict objectForKey:@"DoiNha_SoTran_GhiBan_SanKhach"]];
                [self.sPd_Nha1_1 addObject:[dict objectForKey:@"DoiNha_TyLe_GhiBan_SanKhach"]];
                [self.sPd_Nha1_1 addObject:[dict objectForKey:@"DoiNha_SoTran_Khong_GhiBan_SanKhach"]];
                [self.sPd_Nha1_1 addObject:[dict objectForKey:@"DoiNha_SoTran_SachLuoi_SanKhach"]];
                [self.sPd_Nha1_1 addObject:[dict objectForKey:@"DoiNha_SoTran_LotLuoi_SanKhach"]];
                [self.sPd_Nha1_1 addObject:[dict objectForKey:@"DoiNha_TyLe_LotLuoi_SanKhach"]];

                
                // doi khach
                [self.sPd_Khach1 addObject:[dict objectForKey:@"DoiKhach_SoTran_GhiBan_SanNha"]];
                [self.sPd_Khach1 addObject:[dict objectForKey:@"DoiKhach_TyLe_GhiBan_SanNha"]];
                [self.sPd_Khach1 addObject:[dict objectForKey:@"DoiKhach_SoTran_Khong_GhiBan_SanNha"]];
                [self.sPd_Khach1 addObject:[dict objectForKey:@"DoiKhach_SoTran_SachLuoi_SanNha"]];
                [self.sPd_Khach1 addObject:[dict objectForKey:@"DoiKhach_SoTran_LotLuoi_SanNha"]];
                [self.sPd_Khach1 addObject:[dict objectForKey:@"DoiKhach_TyLe_LotLuoi_SanNha"]];
                
                // san khach
                [self.sPd_Khach1_1 addObject:[dict objectForKey:@"DoiKhach_SoTran_GhiBan_SanKhach"]];
                [self.sPd_Khach1_1 addObject:[dict objectForKey:@"DoiKhach_TyLe_GhiBan_SanKhach"]];
                [self.sPd_Khach1_1 addObject:[dict objectForKey:@"DoiKhach_SoTran_Khong_GhiBan_SanKhach"]];
                [self.sPd_Khach1_1 addObject:[dict objectForKey:@"DoiKhach_SoTran_SachLuoi_SanKhach"]];
                [self.sPd_Khach1_1 addObject:[dict objectForKey:@"DoiKhach_SoTran_LotLuoi_SanKhach"]];
                [self.sPd_Khach1_1 addObject:[dict objectForKey:@"DoiKhach_TyLe_LotLuoi_SanKhach"]];
                
                
//                rTongDiem_DoiNha
//                rTongDiem_DoiKhach
                
                
                //DoiNha_TyLe_LotLuoi_TrungBinh
                //DoiNha_SoTran_LotLuoi_SanNha
                //DoiNha_SoTran_SachLuoi_SanNha
                //DoiNha_SoTran_Khong_GhiBan_SanNha
                //DoiNha_TyLe_GhiBan_SanNha
//                DoiNha_SoTran_GhiBan_SanNha
                
                
                //doi nha, tan cong
                [self.sPd_Nha2 addObject:[dict objectForKey:@"DoiNha_TyLe_GhiBan_TrungBinh"]];
                [self.sPd_Nha2 addObject:[dict objectForKey:@"DoiNha_SoTran_Khong_GhiBan"]];
                [self.sPd_Nha2 addObject:[dict objectForKey:@"DoiNha_SoTran_GhiBan"]];
                [self.sPd_Nha2 addObject:[dict objectForKey:@"DoiNha_Hieu_So_Ban_Thang"]];
                //phong thu
                [self.sPd_Nha2 addObject:[dict objectForKey:@"DoiNha_TyLe_LotLuoi_TrungBinh"]];
                [self.sPd_Nha2 addObject:[dict objectForKey:@"DoiNha_TyLe_LotLuoi_TrungBinh"]];
                [self.sPd_Nha2 addObject:[dict objectForKey:@"DoiNha_SoTran_Khong_LotLuoi"]];
                [self.sPd_Nha2 addObject:[dict objectForKey:@"DoiNha_SoTran_LotLuoi"]];
                [self.sPd_Nha2 addObject:[dict objectForKey:@"DoiNha_Hieu_So_Ban_Thua"]];
                
                ////////////////////////
                //doi khach, tan cong
                [self.sPd_Khach2 addObject:[dict objectForKey:@"DoiKhach_TyLe_GhiBan_TrungBinh"]];
                [self.sPd_Khach2 addObject:[dict objectForKey:@"DoiKhach_SoTran_Khong_GhiBan"]];
                [self.sPd_Khach2 addObject:[dict objectForKey:@"DoiKhach_SoTran_GhiBan"]];
                [self.sPd_Khach2 addObject:[dict objectForKey:@"DoiKhach_Hieu_So_Ban_Thang"]];
                //phong thu
                [self.sPd_Khach2 addObject:[dict objectForKey:@"DoiKhach_TyLe_LotLuoi_TrungBinh"]];
                [self.sPd_Khach2 addObject:[dict objectForKey:@"DoiKhach_TyLe_LotLuoi_TrungBinh"]];
                [self.sPd_Khach2 addObject:[dict objectForKey:@"DoiKhach_SoTran_Khong_LotLuoi"]];
                [self.sPd_Khach2 addObject:[dict objectForKey:@"DoiKhach_SoTran_LotLuoi"]];
                [self.sPd_Khach2 addObject:[dict objectForKey:@"DoiKhach_Hieu_So_Ban_Thua"]];

                NSString* hieuso = [dict objectForKey:@"DoiKhach_Hieu_So_Ban_Thua"];
                @try {
                    self.totalMatch = [[hieuso componentsSeparatedByString:@"/"] objectAtIndex:1];
                }
                @catch (NSException *exception) {
                    //
                    ZLog(@"cannot get total match");
                }
                
                self.totalMatch = [NSString stringWithFormat:@"%lu", _tmpTotal];
                
                
                
                NSString* sDoiNha_Tong_BanThang = [dict objectForKey:@"DoiNha_Tong_BanThang"];
                NSString* sDoiKhach_Tong_BanThang = [dict objectForKey:@"DoiKhach_Tong_BanThang"];
                self.sDoiNha_Tong_BanThang = sDoiNha_Tong_BanThang;
                self.sDoiKhach_Tong_BanThang = sDoiKhach_Tong_BanThang;

                if(YES) {
                    break;
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }@catch(NSException *ex) {
        
    }
}

-(void)fetchAllInfo
{
    dispatch_queue_t myQueue1 = dispatch_queue_create("com.ptech.bdlive", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue1, ^{
        
        // clear all objects before do anything
        [self.sMaytinh_Dudoan_Dict removeAllObjects];
        [self.bxhDatasource removeAllObjects];
        [self.sPd_Nha1 removeAllObjects];
        [self.sPd_Nha1_1 removeAllObjects];
        [self.sPd_Nha2 removeAllObjects];
        [self.sPd_Khach1 removeAllObjects];
        [self.sPd_Khach1_1 removeAllObjects];
        [self.sPd_Khach2 removeAllObjects];
        
        
        // phong do
        [self.soapHandler sendPhongDoSOAPRequest:[PresetSOAPMessage getPhongDoSoapMessage:[NSString stringWithFormat:@"%lu", self.model.iID_MaTran]] soapAction:[PresetSOAPMessage getPhongDoSoapAction] type:0];
        
        [self.soapHandler sendPhongDoSOAPRequest:[PresetSOAPMessage getPhongDoDetailSoapMessage:[NSString stringWithFormat:@"%lu", self.model.iID_MaTran]] soapAction:[PresetSOAPMessage getPhongDoDetailSoapAction] type:1];
        
        if(self.p_type == 1) {
            // maytinh du doan
            [self.soapHandler sendPhongDoSOAPRequest:[PresetSOAPMessage getMaytinhDudoanMessage:[NSString stringWithFormat:@"%lu", self.model.iID_MaTran]] soapAction:[PresetSOAPMessage getMaytinhDudoanSoapAction] type:2];
            
        }
    });
    

    
//    dispatch_queue_t myQueue2 = dispatch_queue_create("com.ptech.bdlive", NULL);
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue2, ^{
//        // phong do
//        [self.soapHandler sendPhongDoSOAPRequest:[PresetSOAPMessage getPhongDoDetailSoapMessage:[NSString stringWithFormat:@"%lu", self.model.iID_MaGiai] sMaDoiNha:self.model.sMaDoiNha sMaDoiKhach:self.model.sMaDoiKhach] soapAction:[PresetSOAPMessage getPhongDoDetailSoapAction] type:1];
//    });
    
//    dispatch_queue_t myQueue3 = dispatch_queue_create("com.ptech.bdlive", NULL);
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue3, ^{
//        // phong do
//        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage getPhongDoSoapMessage:[NSString stringWithFormat:@"%lu", self.model.iID_MaTran]] soapAction:[PresetSOAPMessage getPhongDoSoapAction]];
//    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(IBAction)onReloadClick:(id)sender {
    self.loadButton.hidden = YES;
    self.loadIndicatorView.hidden = NO;
    [self.loadIndicatorView startAnimating];
    
    [self fetchAllInfo];
}

@end
