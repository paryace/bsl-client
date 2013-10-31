//
//  GeoLocation.h
//  bsl
//
//  Created by zhoujun on 13-10-31.
//
//

#import <Foundation/Foundation.h>

@interface GeoLocation : NSObject<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}

-(GeoLocation *)getLocation;
@end
