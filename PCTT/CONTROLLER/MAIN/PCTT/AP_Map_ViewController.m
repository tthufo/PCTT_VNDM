//
//  AP_Map_ViewController.m
//  MapApp
//
//  Created by Thanh Hai Tran on 4/10/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

#import "AP_Map_ViewController.h"

#import <GoogleMaps/GoogleMaps.h>

#import <AllPod/NSObject+Category.h>

#import "JSONKit.h"

#import "EM_MenuView.h"

#import <AllPod/Permission.h>

#import "WMSTileLayer.h"

#import "Giám_sát_thiên_tai-Swift.h"

@interface AP_Map_ViewController ()<GMSMapViewDelegate>
{
    IBOutlet UIImageView * hand;
    
    IBOutlet UIImageView * headerImg;
    
    IBOutlet UIView * top, * bar;
    
    IBOutlet UITextField * search;
    
    IBOutlet NSLayoutConstraint * topBar;
    
    NSMutableArray * dataList, * dataPoly;
        
    IBOutlet GMSMapView * mapView;
        
    BOOL isStreet, isShow, isEnable;
    
    IBOutlet UIButton * changeMap, * menuMap;
    
    GMSMarker * mainMarker, * currentLocation;
    
    NSString * uniqueID;
    
    NSTimer * time;
    
    UIActivityIndicatorView * indicator;
    
    GMSURLTileLayer *layer, *layerO;

    EM_MenuView * popUpDialog;

    BOOL isOn;
}

@end

@implementation AP_Map_ViewController

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([Information.check isEqualToString:@"0"]) {
        headerImg.image = [UIImage imageNamed:@"bg_text_dms"];
    }
    
    isStreet = YES;
    
    uniqueID = @"";
        
    dataList = [@[] mutableCopy];
    
    dataPoly = [@[] mutableCopy];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self lat]
                                                            longitude:[self lng]
                                                                 zoom:15];

    mapView.camera = camera;
    
    mapView.delegate = self;
    
    currentLocation = [[GMSMarker alloc] init];
    currentLocation.position = CLLocationCoordinate2DMake([self lat], [self lng]);
    currentLocation.icon = [UIImage imageNamed:@"blue"];
    currentLocation.map = mapView;
 
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *styleUrl = [mainBundle URLForResource:@"style_json" withExtension:@"json"];
    NSError *error;

    GMSMapStyle *style = [GMSMapStyle styleWithContentsOfFileURL:styleUrl error:&error];

    if (!style) {
      NSLog(@"The style definition could not be loaded: %@", error);
    }

    mapView.mapStyle = style;
    
    [self currentMaker:[self lat] andLong:[self lng]];
    
    [self didRequestPoint: true];
    
    [self didAddLayerTile];
}

- (void)didRequestPoint:(BOOL)zoom {
    NSString * url = [self infoPlist][@"host"];
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink":[NSString stringWithFormat:@"%@/%@", url, @"location/favorite"],
                                                 @"header":@{@"Authorization": [Information token]},
                                                 @"method":@"GET",
                                                 @"host":self,
                                                 @"overrideAlert":@"1",
                                                 @"overrideLoading":@"1"
                                                 
    } withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
        
        NSDictionary * result = [responseString objectFromJSONString];
        

        
        if (![[result getValueFromKey:@"status"] isEqualToString:@"OK"]) {
            
            [self showToast:@"Lỗi xảy ra, mời bạn thử lại" andPos:0];
            
            return;
        }
        
        [self->dataList removeAllObjects];
        
        [self->dataList addObjectsFromArray:result[@"data"]];
        
        [self didLayoutPoints: zoom];
    }];
}

- (void)didRequestLocation:(float)lat and:(float)lng name:(NSDictionary *)info {

    NSString * url = [NSString stringWithFormat: @"https://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&appid=4349784a2891cdfb65898215c8c26972", lat, lng];
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink": url,
                                                    @"methon": @"GET",
                                                    @"host":self,
                                                    @"overrideAlert":@"1",
                                                    @"overrideLoading":@"1"
                                                    
       } withCache:^(NSString *cacheString) {
           
       } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
                      
           if (error) {
               [self showToast:@"Lỗi xảy ra, mời bạn thử lại" andPos:0];
               
               return;
           }
                      
           NSDictionary * result = [responseString objectFromJSONString];
           
           if(self->popUpDialog)
           {
              self->popUpDialog = nil;
           }
          
           self->popUpDialog = [[EM_MenuView alloc] initWithPop:@{@"delete":@"1",
                                                                  @"lat": @(lat),
                                                                  @"lng": @(lng),
                                                                  @"id": [info getValueFromKey:@"id"],
                                                                  @"loc_name": [info getValueFromKey:@"loc_name"],
                                                                  @"temp":result[@"main"][@"temp"],
                                                                  @"pressure":result[@"main"][@"pressure"],
                                                                  @"humidity":result[@"main"][@"humidity"],
                                                                  @"wind":result[@"wind"][@"speed"]
           }];
          
           [self->popUpDialog showWithCompletion:^(int index, id object, EM_MenuView *menu) {
              
              if (index == 21) {
                  [self didRequestDeletePoint:object];
              }
           }];
       }];
}

- (void)didRequestRegisterPoint:(NSDictionary *) info {
    [self.view endEditing:YES];
    
    if(![[Permission shareInstance] isLocationEnable]) {
        [self showToast:@"Bạn chưa cho phép sử dụng định vị và vị trí hiện tại" andPos:0];
        
        return;
    }
    NSString * url = [self infoPlist][@"host"];
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink": [NSString stringWithFormat:@"%@/%@", url, @"location/favorite"],
                                                 @"header":@{@"Authorization": [Information token]},
                                                 @"loc_name": [info getValueFromKey:@"name"],
                                                 @"lon": [info getValueFromKey:@"lng"],
                                                 @"lat": [info getValueFromKey:@"lat"],
                                                 @"host":self,
                                                 @"overrideAlert":@"1",
                                                 @"overrideLoading":@"1"
                                                 
    } withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
        
        NSDictionary * result = [responseString objectFromJSONString];
        
        if (![[result getValueFromKey:@"status"] isEqualToString:@"OK"]) {
            
            [self showToast:@"Lỗi xảy ra, mời bạn thử lại" andPos:0];
            
            return;
        }
                    
        [self showToast:@"Cập nhật địa điểm thành công" andPos:0];

        for (GMSMarker * marker in self->dataPoly) {
            marker.map = nil;
        }
        
        self->mainMarker.position = CLLocationCoordinate2DMake([self lat], [self lng]);
        
        [self didRequestPoint: NO];
    }];
}



- (void)didRequestDeletePoint:(NSDictionary *) info {
    NSString * url = [self infoPlist][@"host"];
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink": [NSString stringWithFormat:@"%@/%@/%@", url, @"location/favorite/delete", [info getValueFromKey: @"id"]],
                                                 @"header":@{@"Authorization": [Information token]},
                                                 @"method":@"GET",
                                                 @"host":self,
                                                 @"overrideAlert":@"1",
                                                 @"overrideLoading":@"1"
                                                 
    } withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
        
        NSDictionary * result = [responseString objectFromJSONString];
        
        if (![[result getValueFromKey:@"status"] isEqualToString:@"OK"]) {
            
            [self showToast:@"Lỗi xảy ra, mời bạn thử lại" andPos:0];
            
            return;
        }
                    
        [self showToast:@"Xóa thành công" andPos:0];

        for (GMSMarker * marker in self->dataPoly) {
            marker.map = nil;
        }
        
        [self didRequestPoint: NO];
    }];
}

- (void)didLayoutPoints:(BOOL)zoom
{
    GMSCoordinateBounds * bound = [[GMSCoordinateBounds alloc] init];
    [dataPoly removeAllObjects];
   for(NSDictionary * dict in dataList)
   {
       GMSMarker *marker = [[GMSMarker alloc] init];
       marker.position = CLLocationCoordinate2DMake([dict[@"lat"] floatValue], [dict[@"lon"] floatValue]);
       bound = [bound includingCoordinate:marker.position];
       marker.map = mapView;
       marker.accessibilityLabel = [dict bv_jsonStringWithPrettyPrint:YES];
       [dataPoly addObject:marker];
   }
    
    if (zoom) {
//        GMSCameraUpdate * update = [GMSCameraUpdate fitBounds:bound withPadding:55];
//        [mapView animateWithCameraUpdate:update];
    }
}

- (float)lat
{
    return [[Permission shareInstance] isLocationEnable] ? [[[Permission shareInstance] currentLocation][@"lat"] floatValue] : 21.008860;
}

- (float)lng
{
    return [[Permission shareInstance] isLocationEnable] ? [[[Permission shareInstance] currentLocation][@"lng"] floatValue] : 105.809340;
}

- (void)didAddLayerTile
{
    NSDictionary * infoPlist = [self dictWithPlist:@"Info"];

    GMSTileURLConstructor urls1 = ^(NSUInteger x, NSUInteger y, NSUInteger zoom) {
        
//        int cor = pow(2, zoom) - 1 - y;
        
                NSString *url = [NSString stringWithFormat:@"%@/%lu/%lu/%lu.%@", infoPlist[@"tile"],
                                (unsigned long)zoom, (unsigned long)x, (unsigned long)y, @"png"];
        
    
        NSLog(@"%@", url);
        
        return [NSURL URLWithString:url];
    };

    layerO = [GMSURLTileLayer tileLayerWithURLConstructor:urls1];

    layerO.map = mapView;
}


- (void)getAreaInfo
{
    if(time)
    {
        [time invalidate];
        
        time = nil;
    }
    
    time = [NSTimer scheduledTimerWithTimeInterval: 0.8 target:self selector:@selector(didRequestForAreaInfo) userInfo:nil repeats: NO];
}

- (void)didGotoPosition:(float)lat andLong:(float)lng andZoom:(float)zoom
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                            longitude:lng
                                                                 zoom:zoom];
    [mapView animateToCameraPosition:camera];
}

- (void)currentMaker:(float)lat andLong:(float)lng
{
    if (!mainMarker) {
        mainMarker = [[GMSMarker alloc] init];
    }
    mainMarker.position = CLLocationCoordinate2DMake(lat, lng);
    mainMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
    mainMarker.map = mapView;
}

- (IBAction)didPressDismiss:(UIButton*)sender
{
    bar.hidden = YES;
    
    [self.view endEditing:YES];
}

- (IBAction)didPressLocation:(UIButton*)sender
{
    currentLocation.position = CLLocationCoordinate2DMake([self lat], [self lng]);

    [self didGotoPosition:[self lat] andLong:[self lng] andZoom:15];
}

- (IBAction)didPressMapType:(UIButton*)sender
{
    [sender setImage:[UIImage imageNamed: isStreet ? @"icon_vetinh" : @"icon_strees"] forState:UIControlStateNormal];
    
    mapView.mapType = isStreet ? 2 : 1;
    
    isStreet = !isStreet;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    return YES;
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    
    if (marker == mainMarker || marker == currentLocation) {
        return NO;
    }
    
    [self didRequestLocation:marker.position.latitude and:marker.position.longitude name: [marker.accessibilityLabel objectFromJSONString]];
        
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker;
{
//    AP_Web_ViewController * web = [AP_Web_ViewController new];
//
//    web.info = [[marker.accessibilityLabel objectFromJSONString] reFormat];
//
//    [self.navigationController pushViewController:web animated:YES];
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
//    CGPoint locationInView = [mapView.projection pointForCoordinate:coordinate];
    
//    mainMarker.position = coordinate;
//
//    mainMarker.map = mapView;
    
    [self currentMaker:coordinate.latitude andLong:coordinate.longitude];
    
    if(popUpDialog)
    {
        popUpDialog = nil;
    }
    
    popUpDialog = [[EM_MenuView alloc] initWithPop:@{@"lat": @(coordinate.latitude), @"lng": @(coordinate.longitude)}];
    
    [popUpDialog showWithCompletion:^(int index, id object, EM_MenuView *menu) {
        
        if (index == 9000) {
            [self.view endEditing:YES];
        }
        
        if (index == 20) {
            [self didRequestRegisterPoint:object];
        }
        
        if (index == 21) {
            [self didRequestDeletePoint:object];
        }
    }];
}

- (nullable UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
//    if(marker == mainMarker || marker == layerMarker)
//    {
//        return nil;
//    }
    
//    NSMutableDictionary * markerInfo = [[marker.accessibilityLabel objectFromJSONString] reFormat];
//
//    if([markerInfo responseForKey:@"images"] && ![markerInfo[@"images"] isKindOfClass:[NSString class]])
//    {
//        indexing = 0;
//
//        if([markerInfo[@"images"] isKindOfClass:[NSArray class]] && ((NSArray*)markerInfo[@"images"]).count == 0)
//        {
//            indexing = 1;
//        }
//    }
//
    return nil;
    
    UIView * view = [[NSBundle mainBundle] loadNibNamed:@"Annotation" owner:nil options:nil][1];

    
    ((UIView*)[self withView:view tag:15]).transform = CGAffineTransformMakeRotation(150);
    
    UILabel * des = ((UILabel*)[self withView:view tag:12]);
    
    des.text = @"sdfdsfdsfsdfsd";

    
    
//    marker.tracksInfoWindowChanges = YES;
    
    return view;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
