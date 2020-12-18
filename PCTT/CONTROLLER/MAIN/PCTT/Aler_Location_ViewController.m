//
//  Aler_Location_ViewController.m
//  PCTT
//
//  Created by Thanh Hai Tran on 12/15/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

#import "Aler_Location_ViewController.h"

#import <GoogleMaps/GoogleMaps.h>

#import <AllPod/NSObject+Category.h>

#import "JSONKit.h"

#import "EM_MenuView.h"

#import <AllPod/Permission.h>

#import "WMSTileLayer.h"

#import "VNDMS-Swift.h"

#import "GMUGeoJSONParser.h"

#import "GMUStyle.h"

#import "GMUGeometryRenderer.h"

#import "GMUFeature.h"


@interface Aler_Location_ViewController ()<GMSMapViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIImageView * hand;
    
    IBOutlet UIImageView * headerImg;
    
    IBOutlet UIImageView * logoLeft;
    
    IBOutlet UIView * top, * bar;
    
    IBOutlet UITextField * search;
    
    IBOutlet NSLayoutConstraint * topBar;
    
    IBOutlet UITableView * tableView;
    
    NSMutableArray * dataList, * dataPoly, * options, * rendererList, * dataPointer;
    
    NSMutableDictionary * allPoints;
        
    IBOutlet GMSMapView * mapView;
        
    BOOL isStreet, isShow, isEnable, showOption;
    
    IBOutlet UIButton * changeMap, * menuMap;
    
    GMSMarker * mainMarker, * currentLocation;
    
    NSString * uniqueID;
    
    NSTimer * time;
    
    UIActivityIndicatorView * indicator;
    
    GMSURLTileLayer *layer, *layerO;

    EM_MenuView * popUpDialog;
    
    GMUGeometryRenderer *renderer;
    
    GMUGeoJSONParser *parser;

    BOOL isOn;
}

@end

@implementation Aler_Location_ViewController

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didPressShow:(id)sender
{
    showOption =! showOption;
    
    tableView.alpha = showOption ? 1 : 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([Information.check isEqualToString:@"0"]) {
        headerImg.image = [UIImage imageNamed:@"bg_text_dms"];
    }
    
    if ([Information.check isEqualToString:@"1"]) {
        logoLeft.image = [UIImage imageNamed:@"logo_tc"];
    }
    
    [tableView withCell:@"Optional_Cell"];
    
    isStreet = YES;
    
    showOption = YES;
    
    uniqueID = @"";
        
    dataList = [@[] mutableCopy];
    
    dataPoly = [@[] mutableCopy];
    
    options = [@[] mutableCopy];
    
    rendererList = [@[] mutableCopy];
    
    allPoints = [@{} mutableCopy];
    
    dataPointer = [@[] mutableCopy];

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
    
//    [self didRequestPoint: true];
    
    [self didAddLayerTile];
    
    [self didRequestOption];
    
//    [self didRequestMap];
}

- (void)didRequestOption {
    NSString * url = [self infoPlist][@"host"];
        
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink":[NSString stringWithFormat:@"%@/%@", url, @"thongtin-thientai/phanloai/"],
                                                 @"header":@{@"Authorization": [Information token]},
                                                 @"method":@"GET",
                                                 @"host":self,
                                                 @"overrideAlert":@"1",
                                                 @"overrideLoading":@"1"
                                                 
    } withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
        
        NSDictionary * result = [responseString objectFromJSONString];
         
        if (![errorCode isEqualToString:@"200"]) {
            [self showToast:@"Lỗi xảy ra, mời bạn thử lại" andPos:0];
            return;
        }
        
        [self->options removeAllObjects];
        
        for (NSDictionary * dict in result[@"array"]) {
            NSMutableDictionary * option = [[NSMutableDictionary alloc] initWithDictionary:dict];
            option[@"checked"] = @"0";
            [self->options addObject:option];
        }
                
        [self->tableView reloadData];
                
    }];
}

- (void)didRequestMapPoly {
    NSString * url = [self infoPlist][@"host"];
        
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink":[NSString stringWithFormat:@"%@/%@", url, [NSString stringWithFormat:@"thongtin-thientai/map?maptype=%@", @"0"]],
                                                 @"header":@{@"Authorization": [Information token]},
                                                 @"method":@"GET",
                                                 @"host":self,
                                                 @"overrideAlert":@"1",
                                                 @"overrideLoading":@"1"
                                                 
    } withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
        
        NSDictionary * result = [responseString objectFromJSONString];
         
        if (![errorCode isEqualToString:@"200"]) {
            [self showToast:@"Lỗi xảy ra, mời bạn thử lại" andPos:0];
            return;
        }
                
        
        [self->rendererList removeAllObjects];

        for (NSDictionary * dict in result[@"data"]) {

            NSData* data = [dict[@"geometry"] dataUsingEncoding:NSUTF8StringEncoding];

            GMUGeoJSONParser * parser = [[GMUGeoJSONParser alloc] initWithData:data];

            [parser parse];
            
            GMUStyle * style = [[GMUStyle alloc] initWithStyleID:@"random" strokeColor:[UIColor redColor] fillColor:[UIColor colorWithRed:184.0f/225.0f green:86.0f/225.0f blue:77.0f/225.0 alpha:0.6] width:1 scale:1 heading:1 anchor:CGPointMake(0, 0) iconUrl:@"" title:@"" hasFill:true hasStroke:true];

            for (GMUFeature * feature in parser.features) {
                feature.style = style;
            }
            
            GMUGeometryRenderer * renderer = [[GMUGeometryRenderer alloc] initWithMap:self->mapView
                                                     geometries:parser.features];
               
            [renderer render];
                        
            [self->rendererList addObject:renderer];
        }
    }];
}

- (void)didRequestMap:(NSString*)type {
    NSString * url = [self infoPlist][@"host"];
        
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink":[NSString stringWithFormat:@"%@/%@", url, [NSString stringWithFormat:@"thongtin-thientai/map?maptype=%@", type]],
                                                 @"header":@{@"Authorization": [Information token]},
                                                 @"method":@"GET",
                                                 @"host":self,
                                                 @"overrideAlert":@"1",
                                                 @"overrideLoading":@"1"
                                                 
    } withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
        
        NSDictionary * result = [responseString objectFromJSONString];
         
        if (![errorCode isEqualToString:@"200"]) {
            [self showToast:@"Lỗi xảy ra, mời bạn thử lại" andPos:0];
            return;
        }
                        
        self->allPoints[type] = result[@"data"];
        
        [self didLayoutPointNest:YES];
    }];
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

    
//    NSString * url = [NSString stringWithFormat: @"https://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&appid=4349784a2891cdfb65898215c8c26972", lat, lng];
//
//    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink": url,
//                                                    @"methon": @"GET",
//                                                    @"host":self,
//                                                    @"overrideAlert":@"1",
//                                                    @"overrideLoading":@"1"
//
//       } withCache:^(NSString *cacheString) {
//
//       } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
//
//           if (error) {
//               [self showToast:@"Lỗi xảy ra, mời bạn thử lại" andPos:0];
//
//               return;
//           }
//
//           NSDictionary * result = [responseString objectFromJSONString];
//
           if(self->popUpDialog)
           {
              self->popUpDialog = nil;
           }

           self->popUpDialog = [[EM_MenuView alloc] initWithAlertLocation:info];

           [self->popUpDialog showWithCompletion:^(int index, id object, EM_MenuView *menu) {

              if (index == 1) {
//                  [menu close];
//
//                  [self didRequestLocation:lat and:lng name:info];
                  
                  [menu close];

                  Event_Upload_ViewController * upload = [Event_Upload_ViewController new];
                  
                  upload.info = info;
                  
                  [self.navigationController pushViewController:upload animated:YES];
              } else {
//                  [menu close];
//
//                  Event_Upload_ViewController * upload = [Event_Upload_ViewController new];
//                  
//                  upload.info = info;
//                  
//                  [self.navigationController pushViewController:upload animated:YES];
              }

           }];
//       }];
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

- (void)didLayoutPointNest:(BOOL)zoom
{
    GMSCoordinateBounds * bound = [[GMSCoordinateBounds alloc] init];
//    [dataPointer removeAllObjects];
    for (NSArray * arr in allPoints.allValues) {
       for (NSDictionary * dict in arr) {
          GMSMarker *marker = [[GMSMarker alloc] init];
          marker.position = CLLocationCoordinate2DMake([dict[@"lat"] floatValue], [dict[@"lon"] floatValue]);
          bound = [bound includingCoordinate:marker.position];
          marker.map = mapView;
          marker.accessibilityLabel = [dict bv_jsonStringWithPrettyPrint:YES];
          [dataPointer addObject:marker];
       }
   }
    
    if (YES) {
        GMSCameraUpdate * update = [GMSCameraUpdate fitBounds:bound withPadding:55];
        [mapView animateWithCameraUpdate:update];
    }
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
        
    
//        NSLog(@"%@", url);
        
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
//    mainMarker.map = mapView;
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
    
//    [self currentMaker:coordinate.latitude andLong:coordinate.longitude];
//
//    if(popUpDialog)
//    {
//        popUpDialog = nil;
//    }
//
//    popUpDialog = [[EM_MenuView alloc] initWithPop:@{@"lat": @(coordinate.latitude), @"lng": @(coordinate.longitude)}];
//
//    [popUpDialog showWithCompletion:^(int index, id object, EM_MenuView *menu) {
//
//        if (index == 9000) {
//            [self.view endEditing:YES];
//        }
//
//        if (index == 20) {
//            [self didRequestRegisterPoint:object];
//        }
//
//        if (index == 21) {
//            [self didRequestDeletePoint:object];
//        }
//    }];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return options.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell*)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:@"Optional_Cell" forIndexPath:indexPath];

    NSDictionary * dict = options[indexPath.row];
    
    UILabel * label = [self withView:cell tag:11];
    
    [label withBorder:@{@"Bwidth":@"1", @"Bcorner":@"6", @"Bcolor": [[dict getValueFromKey:@"checked"] isEqualToString:@"0"] ? [UIColor blueColor] : [UIColor redColor]}];
    
    label.text = dict[@"ten_phanloai"];
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary * dict = options[indexPath.row];
    
    if ([[dict getValueFromKey:@"id"] isEqualToString: @"0"]) {
        if ([[dict getValueFromKey:@"checked"] isEqualToString:@"0"]) {
            [self didRequestMapPoly];
        } else {
            for (GMUGeometryRenderer * render in rendererList) {
                [render clear];
            }
        }
    } else {
        NSString * typing = [dict getValueFromKey:@"id"];
        if ([[dict getValueFromKey:@"checked"] isEqualToString:@"0"]) {
            [self didRequestMap:typing];
        } else {
            allPoints[typing] = @[];
            for (GMSMarker * marker in self->dataPointer) {
                marker.map = nil;
            }
            [self didLayoutPointNest:NO];
        }
    }
    
    options[indexPath.row][@"checked"] = [[dict getValueFromKey
:@"checked"] isEqualToString:@"0"] ? @"1" : @"0";
    
    [tableView reloadData];
}

@end
