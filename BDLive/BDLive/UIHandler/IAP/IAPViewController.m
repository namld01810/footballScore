//
//  IAPViewController.m
//  BDLive
//
//  Created by Khanh Le on 8/21/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "IAPViewController.h"
#import <StoreKit/StoreKit.h>
#import "../../Utils/XSUtils.h"

#import "xs_common_inc.h"
#import "../../SOAPHandler/SOAPHandler.h"
#import "../../SOAPHandler/PresetSOAPMessage.h"
#import "../../Utils/NSString+MD5.h"
#import "../../Models/AccInfo.h"
#import "IAPItem.h"
#import "CarrierTableViewCell.h"
#import "CarrierViewController.h"

#import "AppStoreTableViewCell.h"

#define kRemoveAdsProductIdentifier @"star1"

static const int _TAB_APPSTORE_ = 1;
static const int _TAB_CARRIER_ = 3;

static const int _NUM_OF_CARRIER_ = 3;


#define STAR_UNIT 1000000


@interface IAPViewController () <SKProductsRequestDelegate, SKPaymentTransactionObserver, UITableViewDataSource, UITableViewDelegate, SOAPHandlerDelegate>

@property(nonatomic) NSUInteger tabIndex;


@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, weak) IBOutlet UIImageView *backImgView;
@property(nonatomic, weak) IBOutlet UIImageView *reloadImgView;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *reloadIndicatorView;
@property(nonatomic, weak) IBOutlet UILabel *purchaseLabel;


@property(nonatomic, weak) IBOutlet UIButton *storeButton;
@property(nonatomic, weak) IBOutlet UIButton *carrierButton;


@property(nonatomic, strong) NSMutableArray* listProductIds;
@property(nonatomic, strong) NSMutableArray* listAvailableProducts;
@property(nonatomic, strong) NSMutableArray* listProducts;


@property(nonatomic, strong) IAPItem* purchasedItem;

@property(nonatomic) BOOL isPurchasing;

@end

@implementation IAPViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabIndex = _TAB_APPSTORE_;
        self.listProductIds = @[].mutableCopy;
        self.listAvailableProducts = @[].mutableCopy;
        self.listProducts = @[].mutableCopy;
        
        self.purchasedItem = nil;
        [self setupDummyData];
        self.isPurchasing = NO;
    }
    return self;
}

-(void)setupDummyData {
//    
//    IAPItem* i1 = [IAPItem new];
//    i1.realPrice = 0.99f;
//    i1.convertedPrice = 2*STAR_UNIT;
//    i1.bundleId = @"com.ls365.item.099";
//    
//    
//    IAPItem* i2 = [IAPItem new];
//    i2.realPrice = 1.99f;
//    i2.convertedPrice = 4*STAR_UNIT;
//    i2.bundleId = @"com.ls365.item.199";
//    
//    
//    [self.listProductIds addObject:@"com.ls365.item.099"];
//    [self.listProductIds addObject:@"com.ls365.item.199"];
//    [self.listProductIds addObject:@"com.ls365.item.299"];
//    [self.listProductIds addObject:@"com.ls365.item.399"];
//    [self.listProductIds addObject:@"com.ls365.item.499"];
//    [self.listProductIds addObject:@"com.ls365.item.599"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString* napsao =  NSLocalizedString(@"iap-napsao.text", @"NapSao");
    self.purchaseLabel.text = napsao;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    
    
    self.reloadImgView.hidden = YES;
    self.backImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackClick:)];
    tap.numberOfTapsRequired = 1;
    [self.backImgView addGestureRecognizer:tap];
    
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.view andSubViews:YES];
    
    
    UINib *cell = [UINib nibWithNibName:@"AppStoreTableViewCell" bundle:nil];
    [self.tableView registerNib:cell forCellReuseIdentifier:@"AppStoreTableViewCell"];
    
    
    UINib *cell2 = [UINib nibWithNibName:@"CarrierTableViewCell" bundle:nil];
    [self.tableView registerNib:cell2 forCellReuseIdentifier:@"CarrierTableViewCell"];
    

    
    [self fetchListIAPItems];
    
    if(![AccInfo sharedInstance].isReview) {
        self.carrierButton.hidden = NO;
    }
}


-(void)onBackClick:(id)sender
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)purchase:(SKProduct*)product{
    @try {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    @catch (NSException *exception) {
        
    }
    
    
}

- (IBAction) restore{
    //this is called when the user restores purchases, you should hook this up to a button
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


- (IBAction)tapsRemoveAds{
    ZLog(@"User requests to remove ads");
    
    if([SKPaymentQueue canMakePayments]){
        ZLog(@"User can make payments");
        
        
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:self.listProductIds]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    }
    else{
        ZLog(@"User cannot make payments due to parental controls.");
        //this is called the user cannot make payments, most likely due to parental controls
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Make payments" message:@"User cannot make payments due to parental controls." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma SKProducts
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    SKProduct *validProduct = nil;
    int count = [response.products count];
    

    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        
        NSLog(@"Found product: %@ %@ %0.2f",
              validProduct.productIdentifier,
              validProduct.localizedTitle,
              validProduct.price.floatValue);
        
        [self.listAvailableProducts addObjectsFromArray:response.products];
        

//        self.reloadImgView.hidden = NO;
        [self.reloadIndicatorView stopAnimating];
        [self.tableView reloadData];
    }
    else if(!validProduct){
        ZLog(@"No products available");
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"IAP" message:@"NO Products Available!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for(SKPaymentTransaction *transaction in transactions){
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                
                if (self.purchasedItem) {
                    [self doSubmitPurchasedItem:self.purchasedItem Transaction_ID:transaction.transactionIdentifier];
                }
                
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                if (self.purchasedItem) {
                    [self doSubmitPurchasedItem:self.purchasedItem Transaction_ID:transaction.transactionIdentifier];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finish
                NSLog(@"SKPaymentTransactionStateFailed: %@",transaction.error);
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
                if(transaction.error.code == SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                } else {
                    NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"iap-alert-transaction-failed-title.text", @"failed")];
                    
                    NSString* localize_message = [NSString stringWithFormat:@"%@", NSLocalizedString(@"iap-alert-transaction-failed-msg.text", @"msg")];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizeMsg message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
                
                [self.reloadIndicatorView stopAnimating];
                
                
                
                
                
                self.isPurchasing = NO;
                
                break;
        }
    }
}


- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %i", queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            //called when the user successfully restores a purchase
            NSLog(@"Transaction state -> Restored");
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }   
}


#pragma table

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tabIndex == _TAB_APPSTORE_) {
        return 140.0f;
    }
    
    return 90.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.tabIndex == _TAB_APPSTORE_) {
        return self.listAvailableProducts.count/2;
    }
    
    return _NUM_OF_CARRIER_;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tabIndex == _TAB_APPSTORE_) {
        return [self createAppStoreCell:tableView cellForRowAtIndexPath:indexPath];
    }
    return [self createCarrierStoreCell:tableView cellForRowAtIndexPath:indexPath];
}

-(CarrierTableViewCell*) createCarrierStoreCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CarrierTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"CarrierTableViewCell"];
    NSString* btnImgNamed = @"ic_iap_mobifone.png";
    
    cell.carrierButton.tag = _CARRIER_MOBI_FONE_ID_;
    
    if(indexPath.row == 1) {
        // vina
        btnImgNamed = @"ic_iap_vinaphone.png";
        cell.carrierButton.tag = _CARRIER_VINA_FONE_ID_;
    } else if(indexPath.row == 2) {
        // viettel
        btnImgNamed = @"ic_iap_viettel.png";
        cell.carrierButton.tag = _CARRIER_VIETTEL_ID_;
    }
    
    [cell.carrierButton setBackgroundImage:[UIImage imageNamed:btnImgNamed] forState:UIControlStateNormal];
    [cell.carrierButton addTarget:self action:@selector(onCarrierButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(IBAction)onCarrierButtonClicked:(UIButton*)sender {
    CarrierViewController *cv = [[CarrierViewController alloc] initWithNibName:@"CarrierViewController" bundle:nil];
    cv.carrierId = sender.tag;
    
    [self presentViewController:cv animated:YES completion:nil];
    
}

-(AppStoreTableViewCell*) createAppStoreCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppStoreTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"AppStoreTableViewCell"];
    
    NSString* leftIap = @"ic_iap_1.png";
    NSString* rightIap = @"ic_iap_2.png";
    NSString *priceTxt1, *priceTxt2, *star1, *star2;
    IAPItem *iap1 = nil, *iap2 = nil;
    
    
    if (indexPath.row == 0) {
        iap1 = self.listProducts[0];
        iap2 = self.listProducts[1];
        
        leftIap = @"ic_iap_1.png";
        rightIap = @"ic_iap_2.png";
        
        priceTxt1 = [NSString stringWithFormat:@"$ %0.2f", iap1.realPrice];
        priceTxt2 = [NSString stringWithFormat:@"$ %0.2f", iap2.realPrice];
        star1 = [NSString stringWithFormat:@"%@", [XSUtils format_iBalance:iap1.convertedPrice]];;//
        star2 = [NSString stringWithFormat:@"%@", [XSUtils format_iBalance:iap2.convertedPrice]];;//
        cell.leftButton.buttonIndex = 0;
        cell.rightButton.buttonIndex = 1;

    } else if(indexPath.row == 1) {
        iap1 = self.listProducts[2];
        iap2 = self.listProducts[3];
        
        leftIap = @"ic_iap_3.png";
        rightIap = @"ic_iap_4.png";
        
        priceTxt1 = [NSString stringWithFormat:@"$ %0.2f", iap1.realPrice];
        priceTxt2 = [NSString stringWithFormat:@"$ %0.2f", iap2.realPrice];
        star1 = [NSString stringWithFormat:@"%@", [XSUtils format_iBalance:iap1.convertedPrice]];;//
        star2 = [NSString stringWithFormat:@"%@", [XSUtils format_iBalance:iap2.convertedPrice]];;//
        
        cell.leftButton.buttonIndex = 2;
        cell.rightButton.buttonIndex = 3;
    } else if(indexPath.row == 2) {
        iap1 = self.listProducts[4];
        iap2 = self.listProducts[5];
        
        leftIap = @"ic_iap_5.png";
        rightIap = @"ic_iap_6.png";
        
        priceTxt1 = [NSString stringWithFormat:@"$ %0.2f", iap1.realPrice];
        priceTxt2 = [NSString stringWithFormat:@"$ %0.2f", iap2.realPrice];
        star1 = [NSString stringWithFormat:@"%@", [XSUtils format_iBalance:iap1.convertedPrice]];;//
        star2 = [NSString stringWithFormat:@"%@", [XSUtils format_iBalance:iap2.convertedPrice]];;//
        
        cell.leftButton.buttonIndex = 4;
        cell.rightButton.buttonIndex = 5;
    }
    
    
    [cell.leftButton setBackgroundImage:[UIImage imageNamed:leftIap] forState:UIControlStateNormal];
    [cell.rightButton setBackgroundImage:[UIImage imageNamed:rightIap] forState:UIControlStateNormal];
    
    cell.leftPrice.text = priceTxt1;
    cell.rightPrice.text = priceTxt2;
    cell.leftPriceStar.text = star1;
    cell.rightPriceStar.text = star2;
    
    [cell.leftButton addTarget:self action:@selector(onPurchaseClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.rightButton addTarget:self action:@selector(onPurchaseClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    return cell;
}




-(IBAction)onAppStoreClicked:(id)sender {
    if(self.tabIndex != _TAB_APPSTORE_) {
        self.tabIndex = _TAB_APPSTORE_;
        [self.storeButton setBackgroundImage:[UIImage imageNamed:@"ic_tab_active.png"] forState:UIControlStateNormal];
        
        [self.carrierButton setBackgroundImage:[UIImage imageNamed:@"ic_tab_inactive.png"] forState:UIControlStateNormal];

        [self.tableView reloadData];
        
    }
    

}

-(IBAction)onCarrierClicked:(id)sender {

    if(self.tabIndex != _TAB_CARRIER_) {
        self.tabIndex = _TAB_CARRIER_;
        [self.carrierButton setBackgroundImage:[UIImage imageNamed:@"ic_tab_active.png"] forState:UIControlStateNormal];
        
        [self.storeButton setBackgroundImage:[UIImage imageNamed:@"ic_tab_inactive.png"] forState:UIControlStateNormal];
        
        [self.tableView reloadData];
    }
}

-(IBAction)onPurchaseClicked:(IAPButton*)sender {
    
    if (self.isPurchasing) {
        return;
    }
    
    
    SKProduct *validProduct = [self.listAvailableProducts objectAtIndex:sender.buttonIndex];
    NSLog(@"Found product: %@ %0.2f",
          validProduct.productIdentifier,
          validProduct.price.floatValue);
    
    
    self.purchasedItem = self.listProducts[sender.buttonIndex];
    [self purchase:validProduct];
    
    [self.reloadIndicatorView startAnimating];
    self.reloadImgView.hidden = YES;
    self.isPurchasing = YES;
}


#pragma SOAP
-(void)onSoapError:(NSError *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* localizeMsg = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-load-data-error.text", @"Lỗi tải dữ liệu")];
        
        NSString* localize_message = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-network-error.text", kBDLive_OnLoadDataError_Message)];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizeMsg message:localize_message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];        [alert show];
    });
    
}
-(void)onSoapDidFinishLoading:(NSData *)data {
    NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    

        
        if ([xmlData rangeOfString:@"<wsFootBall_Get_GoiMuaSaoResult>"].location != NSNotFound) {
            // user info
            [self handle_wsFootBall_Get_GoiMuaSaoResult:xmlData];
            return;
        } else if([xmlData rangeOfString:@"<wsFootBall_MuaSao_SecureResult>"].location != NSNotFound) {
            [self handle_wsFootBall_MuaSaoResult:xmlData];
            return;
        } 
}

-(void)handle_wsFootBall_Get_GoiMuaSaoResult:(NSString*)xmlData {
    @try {
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_Get_GoiMuaSaoResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_Get_GoiMuaSaoResult>"] objectAtIndex:0];
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            
            [self.listProductIds removeAllObjects];
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                IAPItem* item = [IAPItem new];
                NSString* bundle_id = [dict objectForKey:@"bundle_id"];
                int iID_MaGoi = [(NSNumber*)[dict objectForKey:@"iID_MaGoi"] intValue];
                float real_price = [(NSNumber*)[dict objectForKey:@"real_price"] floatValue];
                NSUInteger so_sao = [(NSNumber*)[dict objectForKey:@"so_sao"] integerValue];
                
                
                item.bundleId = bundle_id;
                item.iID_MaGoi = iID_MaGoi;
                item.realPrice = real_price;
                item.convertedPrice = so_sao;
                
                [self.listProductIds addObject:bundle_id];
                [self.listProducts addObject:item];
                
            }
            
            [self tapsRemoveAds];
        }
        
    }
    @catch (NSException *exception) {
        
    }
    
}

//
-(void)handle_wsFootBall_MuaSaoResult:(NSString*)xmlData {
    @try {
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_MuaSao_SecureResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_MuaSao_SecureResult>"] objectAtIndex:0];
        
        
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
                
                NSUInteger iBalance = [(NSNumber*)[dict objectForKey:@"iBalance"] integerValue];
                NSString* Transaction_ID = [dict objectForKey:@"Transaction_ID"];
                
                if (iBalance > 0) {
                    [AccInfo sharedInstance].iBalance = iBalance;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.isPurchasing = NO;
                        [self.reloadIndicatorView stopAnimating];
                        NSString* localizeMsg = [NSString stringWithFormat:NSLocalizedString(@"iap-alert-iBalance", @"iBalance"), [XSUtils format_iBalance:iBalance]];
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    });
                    
                    
                    //501x137 => 240x66
                    return;
                }
                
                
            }
            
            [self tapsRemoveAds];
        }
        
    }
    @catch (NSException *exception) {
        
    }
    
    self.isPurchasing = NO;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.reloadIndicatorView stopAnimating];
    });
    
}


-(void)fetchListIAPItems {
    SOAPHandler *soapHandler = [SOAPHandler new];
    soapHandler.delegate = self;
    
    
    
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.iap", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), myQueue, ^{
        
        
        [soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_Get_GoiMuaSao_SoapMessage:1  bLoaiTheCao:0] soapAction:[PresetSOAPMessage get_wsFootBall_Get_GoiMuaSao_SoapAction]];
        
    });
}

-(void)doSubmitPurchasedItem:(IAPItem*)item Transaction_ID:(NSString*)Transaction_ID{
    SOAPHandler *soapHandler = [SOAPHandler new];
    soapHandler.delegate = self;
    
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.iap", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), myQueue, ^{
        
        NSString* account = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_ACOUNT_KEY];
        
        
        [soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_MuaSao_Secure_SoapMessage:1 MaGoi:item.iID_MaGoi Transaction_ID:Transaction_ID UserName:account real_price:item.realPrice so_sao:item.convertedPrice] soapAction:[PresetSOAPMessage get_wsFootBall_MuaSao_Secure_SoapAction]];
        
    });
}

@end
