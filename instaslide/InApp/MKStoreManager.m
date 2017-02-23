

#import "MKStoreManager.h"
#import "AppDelegate.h"
#import "PreviewController.h"
#import "HomeController.h"

extern PreviewController* gPreviewController;
extern HomeController* gHomeController;

@implementation MKStoreManager

@synthesize purchasableObjects;
@synthesize storeObserver;

// all your features should be managed one and only by StoreManager

BOOL featureAPurchased = false;

MKStoreManager* _sharedStoreManager = nil; // self

+ (BOOL) featureAPurchased {
	
	return featureAPurchased;
}

+ (MKStoreManager*)sharedManager
{
	@synchronized(self) {
		
        if (_sharedStoreManager == nil) {

            _sharedStoreManager = [[self alloc] init];

			_sharedStoreManager.purchasableObjects = [[NSMutableArray alloc] init];
			[_sharedStoreManager requestProductData];
			
			[MKStoreManager loadPurchases];
			_sharedStoreManager.storeObserver = [[MKStoreObserver alloc] init];
			[[SKPaymentQueue defaultQueue] addTransactionObserver:_sharedStoreManager.storeObserver];
        }
    }
    return _sharedStoreManager;
}

- (void) requestProductData
{
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: 
								 [NSSet setWithObjects: FEATURE_AID, nil]]; // add any other product here
	request.delegate = self;
	[request start];
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	[purchasableObjects addObjectsFromArray:response.products];
	// populate your UI Controls here
	for(int i=0;i<[purchasableObjects count];i++)
	{
		
		SKProduct *product = [purchasableObjects objectAtIndex:i];
		NSLog(@"Feature: %@, Cost: %f, ID: %@",[product localizedTitle],
			  [[product price] doubleValue], [product productIdentifier]);
	}
	
	[request autorelease];
}

- (void) buyFeatureA
{
    featureAPurchased = NO;
	[self buyFeature:FEATURE_AID];
}

-(void)restorePurchase
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) buyFeature:(NSString*) featureId
{
	if ([SKPaymentQueue canMakePayments])
	{
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:featureId];
//        [payment.quantity ];
//        NSLog(@"******* %d", [payment quantity]);
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MyApp" message:@"You are not authorized to purchase from AppStore"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
        

	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (gPreviewController) {
        [gPreviewController onFailedTransaction];
    }
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    if (gPreviewController) {
        [gPreviewController onFailedTransaction];
    }
    else
        [gHomeController onSucceededTransaction];

/*
	NSString *messageToBeShown = [NSString stringWithFormat:@"Reason: %@, You can try: %@", [transaction.error localizedFailureReason], [transaction.error localizedRecoverySuggestion]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to complete your purchase" message:messageToBeShown
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
	[alert release];
*/
}

-(void) provideContent: (NSString*) productIdentifier
{
	if([productIdentifier isEqualToString:FEATURE_AID])
    {
		featureAPurchased = YES;
      
        if (gPreviewController) {
            [gPreviewController onSucceededTransaction];
        }
        else
        {
            [gHomeController onSucceededTransaction];
        }
    }

	[MKStoreManager updatePurchases];
}

+(void) loadPurchases
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];	
	featureAPurchased = [userDefaults boolForKey:FEATURE_AID]; 
}

+(void) updatePurchases
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:featureAPurchased forKey:FEATURE_AID];
    [userDefaults synchronize];
}

@end

