//
//  AELocationController.m
//  iOS_note
//
//  Created by allen0828 on 2022/9/21.
//

#import "AELocationController.h"
#import <CoreLocation/CoreLocation.h>


@interface LocationObjc : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager *_locationManager;
    CLLocationDegrees _longitude;
    CLLocationDegrees _latitude;
    CLLocationDistance _altitude;
    BOOL _isGetLocation;
}

+ (id)shared;
- (double)getLongitude;
- (double)getLatitude;
- (double)getAltitude;

@end


@interface AELocationController ()

@end

@implementation AELocationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"同步获取位置";
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(1, 0, 250, 35)];
    btn.backgroundColor = UIColor.redColor;
    btn.center = self.view.center;
    [btn setTitle:@"获取位置" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(testClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)testClick {
    double longitude = [[LocationObjc shared] getLatitude];
//    double latitude = [[LocationObjc new] getLatitude];
    NSLog(@"---testClick %f", longitude);
}

@end




@implementation LocationObjc

+ (id)shared {
    static LocationObjc *single = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        single = [[LocationObjc alloc] init];
        [single config];
    });
    return single;
}
- (void)config {
   
}


- (double)getLongitude {
    if (![self isOpenLocation]) { return 0.0; }
    [self startLocation];
    return _longitude;
}
- (double)getLatitude {
    if (![self isOpenLocation]) { return 0.0; }
    [self startLocation];
    return _latitude;
}
- (double)getAltitude {
    if (![self isOpenLocation]) { return 0.0; }
    [self startLocation];
    return _altitude;
}

- (BOOL)isOpenLocation {
    BOOL enable = [CLLocationManager locationServicesEnabled];
    CLAuthorizationStatus status;
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    if (@available(iOS 14.0, *)) {
        status = _locationManager.authorizationStatus;
    } else {
        status = [CLLocationManager authorizationStatus];
    }
    if (!enable || status < 2) {
        [_locationManager requestAlwaysAuthorization];
        [_locationManager requestWhenInUseAuthorization];
    } else {
        if (status == kCLAuthorizationStatusDenied) {
            // show setting
            return false;
        } else {
            return true;
        }
    }
    return false;
}

- (void)startLocation {
    if (_isGetLocation) { return; }
    _isGetLocation = true;
    [_locationManager startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"didChangeAuthorizationStatus");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [_locationManager stopUpdatingLocation];
    _isGetLocation = false;
}


- (void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray*)locations {

    CLLocation*location = [locations lastObject];
    _longitude = location.coordinate.longitude;
    _latitude = location.coordinate.latitude;
    _altitude = location.altitude;
    
    NSLog(@"精度%f  纬度%f  高度%f",_longitude, _latitude, _altitude);
}

@end
