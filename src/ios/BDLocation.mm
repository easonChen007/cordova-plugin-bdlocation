/********* BDLocation.m Cordova Plugin Implementation *******/

#import "BDLocation.h"

@implementation BDLocation

- (void)pluginInitialize
{
    NSDictionary *plistDic = [[NSBundle mainBundle] infoDictionary];
    NSString* API_KEY = [[plistDic objectForKey:@"BDLocation"] objectForKey:@"API_KEY"];
    
    [[[BMKMapManager alloc] init] start:API_KEY generalDelegate:nil];

    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
}

- (void)watch:(CDVInvokedUrlCommand*)command
{
    _watchCommand = command;
    
    NSArray* args = [command arguments];
    NSString* mode = args[0];
    double distanceFilter = [args[6] doubleValue];
    
    if([mode isEqualToString:@"Battery_Saving"]){
        _locService.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    else if([mode isEqualToString:@"Battery_Saving"]){
        _locService.desiredAccuracy = kCLLocationAccuracyBest;
    }
    else{
        _locService.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    }
    
    _locService.distanceFilter = distanceFilter;
    
    [_locService startUserLocationService];
}

- (void)stop:(CDVInvokedUrlCommand*)command
{
    _watchCommand = nil;
    [_locService stopUserLocationService];
    
    [self.commandDelegate sendPluginResult:nil callbackId:command.callbackId];
}

- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    if(_watchCommand != nil)
    {
        NSDate* time = userLocation.location.timestamp;
        NSNumber* latitude = [NSNumber numberWithDouble:userLocation.location.coordinate.latitude];
        NSNumber* longitude = [NSNumber numberWithDouble:userLocation.location.coordinate.longitude];
        NSNumber* altitude = [NSNumber numberWithDouble:userLocation.location.altitude];
        NSNumber* radius = [NSNumber numberWithDouble:userLocation.location.horizontalAccuracy];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setValue:[dateFormatter stringFromDate:time] forKey:@"time"];
        [dict setValue:latitude forKey:@"latitude"];
        [dict setValue:longitude forKey:@"longitude"];
        [dict setValue:altitude forKey:@"altitude"];
        [dict setValue:radius forKey:@"radius"];
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        [result setKeepCallbackAsBool:TRUE];
        [self.commandDelegate sendPluginResult:result callbackId:_watchCommand.callbackId];
    }
}

@end
