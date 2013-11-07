//
//  GeoLocation.m
//  bsl
//
//  Created by zhoujun on 13-10-31.
//
//

#import "GeoLocation.h"

@implementation GeoLocation

-(GeoLocation *)getLocation
{
    return nil;
}
-(void)openLocation
{
//    if ([CLLocationManager locationServicesEnabled]) { // 检查定位服务是否可用
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter=0.5;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation]; // 开始定位
//    }
    
}
// 定位成功时调用
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    CLLocationCoordinate2D mylocation = newLocation.coordinate;//手机GPS

    
}
// 定位失败时调用
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"定位失败－－－－－－");
    
}


//-(void)OCFunc:(void(^)(int ,int))block withBlock:(void(^)(int ,int))_block {  //注意第一种写法的特别之处, OC函数要求变量类型和形参名分开, 所以写法和C不同
//}

    
@end
