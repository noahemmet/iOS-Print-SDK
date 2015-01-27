//
//  OLAnalytics.m
//  KitePrintSDK
//
//  Created by Konstadinos Karayannis on 1/27/15.
//  Copyright (c) 2015 Deon Botha. All rights reserved.
//

#import "OLAnalytics.h"
#import "OLPrintOrder.h"
#import "OLAddress.h"
#import "OLCountry.h"
#import "OLProduct.h"
#import "OLPrintJob.h"
#import "OLKitePrintSDK.h"
#import <AFNetworking.h>
#include <sys/sysctl.h>

static NSString *const kKeyUserDistinctId = @"ly.kite.sdk.kKeyUserDistinctId";
static NSString *const kOLMixpanelToken = @"cdf64507670dd359c43aa8895fb87676";
static NSString *const kOLMixpanelURL = @"http://api.mixpanel.com/track/";

@implementation OLAnalytics

static NSString *nonNilStr(NSString *str) {
    return str == nil ? @"" : str;
}

+ (NSString *)userDistinctId{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *distId = [defaults objectForKey:kKeyUserDistinctId];
    if (!distId){
        distId = [[NSUUID UUID] UUIDString];
        [defaults setObject:distId forKey:kKeyUserDistinctId];
        [defaults synchronize];
    }
    return distId;
}

+ (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

+ (void)sendToMixPanelWithDictionary:(NSDictionary *)dict{
    NSError *error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSURL *baseURL = [NSURL URLWithString:kOLMixpanelURL];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    [manager POST:@"" parameters:@{@"data" : [jsonData base64EncodedStringWithOptions:0]} success:NULL failure:NULL];
}

+ (NSDictionary *)defaultDictionaryForEventName:(NSString *)eventName{
    NSString *environment = @"Live";
    if ([OLKitePrintSDK environment] == kOLKitePrintSDKEnvironmentSandbox) {
        environment = @"Sandbox";
    }
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleName = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleDisplayName"]];
    NSMutableDictionary *propertiesDict = [@{
                                             @"token" : kOLMixpanelToken,
                                             @"distinct_id" : [OLAnalytics userDistinctId],
                                             @"host_app_id" : [[NSBundle mainBundle] bundleIdentifier],
                                             @"host_app_name" : bundleName,
                                             @"platform" : @"iOS",
                                             @"model" : [OLAnalytics platform],
                                             @"Screen Height" : @([UIScreen mainScreen].bounds.size.height),
                                             @"Screen Width" : @([UIScreen mainScreen].bounds.size.width),
                                             @"Environment" : environment
                                             } mutableCopy];
    NSDictionary *dict = @{@"event" : eventName,
                           @"properties" : propertiesDict};
    return dict;
}

+ (void)trackKiteViewControllerLoaded{
    NSDictionary *dict = [OLAnalytics defaultDictionaryForEventName:@"Kite Loaded"];
    [OLAnalytics sendToMixPanelWithDictionary:dict];
}

+ (void)trackProductSelectionScreenViewed{
    NSDictionary *dict = [OLAnalytics defaultDictionaryForEventName:@"Product Selection Screen Viewed"];
    [OLAnalytics sendToMixPanelWithDictionary:dict];
}

+ (void)trackProductDescriptionScreenViewed:(NSString *)productName{
    NSDictionary *dict = [OLAnalytics defaultDictionaryForEventName:@"Product Description Screen Viewed"];
    [dict[@"properties"] setObject:productName forKey:@"Product Name"];
    [OLAnalytics sendToMixPanelWithDictionary:dict];
}

+ (void)trackProductTemplateSelectionScreenViewed:(NSString *)productName{
    NSDictionary *dict = [OLAnalytics defaultDictionaryForEventName:@"Template Selection Screen Viewed"];
    [dict[@"properties"] setObject:productName forKey:@"Product Name"];
    [OLAnalytics sendToMixPanelWithDictionary:dict];
}

+ (void)trackReviewScreenViewed:(NSString *)productName{
    NSDictionary *dict = [OLAnalytics defaultDictionaryForEventName:@"Review Screen Viewed"];
    [dict[@"properties"] setObject:productName forKey:@"Product Name"];
    [OLAnalytics sendToMixPanelWithDictionary:dict];
}

+ (void)trackShippingScreenViewedForOrder:(OLPrintOrder *)printOrder{
    NSDictionary *dict = [OLAnalytics defaultDictionaryForEventName:@"Shipping Screen Viewed"];
    NSMutableDictionary *p = [self propertiesForPrintOrder:printOrder];
    [dict[@"properties"] addEntriesFromDictionary:p];
    [OLAnalytics sendToMixPanelWithDictionary:dict];
}

+ (void)trackPaymentScreenViewedForOrder:(OLPrintOrder *)printOrder{
    NSDictionary *dict = [OLAnalytics defaultDictionaryForEventName:@"Payment Screen Viewed"];
    NSMutableDictionary *p = [self propertiesForPrintOrder:printOrder];
    [dict[@"properties"] addEntriesFromDictionary:p];
    [OLAnalytics sendToMixPanelWithDictionary:dict];
}

+ (void)trackPaymentCompletedForOrder:(OLPrintOrder *)printOrder{
    NSDictionary *dict = [OLAnalytics defaultDictionaryForEventName:@"Payment Completed"];
    NSMutableDictionary *p = [self propertiesForPrintOrder:printOrder];
    [dict[@"properties"] addEntriesFromDictionary:p];
    [OLAnalytics sendToMixPanelWithDictionary:dict];
}

+ (void)trackOrderSubmission:(OLPrintOrder *)printOrder{
    NSDictionary *dict = [OLAnalytics defaultDictionaryForEventName:@"Print Order Submission"];
    NSMutableDictionary *p = [self propertiesForPrintOrder:printOrder];
    [dict[@"properties"] addEntriesFromDictionary:p];
    [OLAnalytics sendToMixPanelWithDictionary:dict];
}

+ (NSMutableDictionary *)propertiesForPrintOrder:(OLPrintOrder *)printOrder {
    NSMutableDictionary *p = [[NSMutableDictionary alloc] init];
    
    p[@"Product"] = [self listOfProductNamesForJobsInOrder:printOrder];
    
    if (printOrder.proofOfPayment) {
        p[@"Proof of Payment"] = printOrder.proofOfPayment;
        NSString *paymentMethod = @"JudoPay";
        if ([printOrder.proofOfPayment hasPrefix:@"AP-"] || [printOrder.proofOfPayment hasPrefix:@"PAY-"]) {
            paymentMethod = @"PayPal";
        }
        p[@"Payment Method"] = paymentMethod;
    }
    
    if (printOrder.lastPrintSubmissionError) {
        p[@"Print Submission Success"] = @"False";
        p[@"Print Submission Error"] = nonNilStr(printOrder.lastPrintSubmissionError.localizedDescription);
    }
    
    if (printOrder.receipt) {
        p[@"Print Order Id"] = printOrder.receipt;
        p[@"Print Submission Success"] = @"True";
        p[@"Print Submission Error"] = @"None";
    }
    
    if (printOrder.promoCode) {
        p[@"Voucher Code"] = printOrder.promoCode;
        p[@"Voucher Discount"] = printOrder.promoDiscount.stringValue;
    }
    
    if (printOrder.userData) {
        if (printOrder.userData[@"email"]) {
            p[@"Shipping Email"] = printOrder.userData[@"email"];
        }
        
        if (printOrder.userData[@"phone"]) {
            p[@"Shipping Phone"] = printOrder.userData[@"phone"];
        }
        
        NSUInteger totalPhotoCount = 0;
        if (printOrder.userData[@"photo_count_facebook"]) {
            p[@"Facebook Photo Count"] = [printOrder.userData[@"photo_count_facebook"] stringValue];
            totalPhotoCount += [printOrder.userData[@"photo_count_facebook"] unsignedIntegerValue];
        }
        
        if (printOrder.userData[@"photo_count_instagram"]) {
            p[@"Instagram Photo Count"] = [printOrder.userData[@"photo_count_instagram"] stringValue];
            totalPhotoCount += [printOrder.userData[@"photo_count_instagram"] unsignedIntegerValue];
        }
        
        if (printOrder.userData[@"photo_count_iphone"]) {
            p[@"iPhone Photo Count"] = [printOrder.userData[@"photo_count_iphone"] stringValue];
            totalPhotoCount += [printOrder.userData[@"photo_count_iphone"] unsignedIntegerValue];
        }
        
        p[@"Total Photo Count"] = [NSString stringWithFormat:@"%lu", totalPhotoCount];
    }
    
    if (printOrder.shippingAddress) {
        p[@"Shipping Recipient"] = nonNilStr(printOrder.shippingAddress.recipientName);
        p[@"Shipping Line 1"] = nonNilStr(printOrder.shippingAddress.line1);
        p[@"Shipping Line 2"] = nonNilStr(printOrder.shippingAddress.line2);
        p[@"Shipping City"] = nonNilStr(printOrder.shippingAddress.city);
        p[@"Shipping County"] = nonNilStr(printOrder.shippingAddress.stateOrCounty);
        p[@"Shipping Postcode"] = nonNilStr(printOrder.shippingAddress.zipOrPostcode);
        p[@"Shipping Country"] = nonNilStr(printOrder.shippingAddress.country.name);
        p[@"Shipping Country Code2"] = nonNilStr(printOrder.shippingAddress.country.codeAlpha2);
        p[@"Shipping Country Code3"] = nonNilStr(printOrder.shippingAddress.country.codeAlpha3);
    }
    
    NSDecimalNumber *cost = [printOrder costInCurrency:@"GBP"];
    p[@"Cost"] = [cost stringValue];
    p[@"Job Count"] = [NSString stringWithFormat:@"%lu", printOrder.jobs.count];
    
    return p;
}

+ (NSMutableArray*) listOfProductNamesForJobsInOrder:(OLPrintOrder*) printOrder{
    NSMutableArray* productNames = [[NSMutableArray alloc] initWithCapacity:[printOrder.jobs count]];
    for (id<OLPrintJob> printJob in printOrder.jobs){
        [productNames addObject:[OLProduct productWithTemplateId:printJob.templateId].productTemplate.name];
    }
    return productNames;
}

@end
