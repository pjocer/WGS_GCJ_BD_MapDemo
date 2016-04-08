//
//  ViewController.m
//  MapDemo
//
//  Created by PerryJi on 16/4/6.
//  Copyright © 2016年 PerryJi. All rights reserved.
//

#import "ViewController.h"
#import <BaiduMapKit/BMKMapView.h>
#import <BaiduMapKit/BMKLocationService.h>
#import <BaiduMapKit/BMKGeocodeSearch.h>
#import "MapMessageCell.h"
#import <BaiduMapKit/BMKAnnotationView.h>
#import "BMKAnnotation.h"
#import <AMapLocation/AMapLocationKit.h>
#import <AMapSearch/AMapSearchKit.h>
#import <MapKit/MapKit.h>
@interface ViewController () <BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,AMapSearchDelegate,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate,MKReverseGeocoderDelegate>
{
    BMKMapView *_mapView;
    BMKLocationService *_locService;
    BMKGeoCodeSearch *_search;
    BMKReverseGeoCodeOption *_geoCodeOption;
    BMKReverseGeoCodeResult *_geoCodeResult;
    BMKActionPaopaoView *_paopaoView;
    NSMutableArray <NSDictionary *>*_dataSource;
    UITableView *_tableView;
    
    AMapLocationManager *_manager;
    AMapSearchAPI *_searchAPI;
    AMapReGeocodeSearchRequest *_reGeoRequest;
    
    CLLocationManager *_clManager;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//百度地图相关初始化
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 400)];
    _mapView.showsUserLocation = YES;
    _mapView.showMapScaleBar = YES;
    _mapView.gesturesEnabled = YES;
    _search = [[BMKGeoCodeSearch alloc]init];
    _locService = [[BMKLocationService alloc]init];
    _geoCodeOption = [BMKReverseGeoCodeOption new];
    [_locService startUserLocationService];
    [self.view addSubview:_mapView];
//TableView 初始化
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_mapView.frame), self.view.bounds.size.width, self.view.bounds.size.height-400) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _dataSource = [NSMutableArray array];
    [_tableView registerNib:[UINib nibWithNibName:@"MapMessageCell" bundle:nil] forCellReuseIdentifier:@"MapMessageCell"];
    [self.view addSubview:_tableView];
    
//高德地图相关初始化
    _manager = [[AMapLocationManager alloc]init];
    [_manager setDesiredAccuracy:kCLLocationAccuracyBest];
    _manager.locationTimeout = 3;
    _manager.reGeocodeTimeout = 3;
    [_manager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        NSDictionary *dict = @{@"text":@"高德地图",@"address":regeocode.formattedAddress,@"location":[NSString stringWithFormat:@"经度:%f - 维度:%f",location.coordinate.latitude,location.coordinate.longitude]};
        [_dataSource addObject:dict];
        [_tableView reloadData];
    }];
    _searchAPI = [[AMapSearchAPI alloc]init];
    _searchAPI.delegate = self;
    _reGeoRequest = [[AMapReGeocodeSearchRequest alloc]init];
    
//CLLocation相关初始化
    _clManager = [[CLLocationManager alloc]init];
    _clManager.delegate = self;
    [_clManager startUpdatingLocation];
}


#pragma mark - CLLocationManager Delegete
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations objectAtIndex:0];
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placeMark = [placemarks objectAtIndex:0];
        NSDictionary *dict = @{@"text":@"WGS",@"address":[NSString stringWithFormat:@"%@%@%@%@",placeMark.locality,placeMark.subLocality,placeMark.thoroughfare,placeMark.subThoroughfare],@"location":[NSString stringWithFormat:@"经度:%f - 维度:%f",placeMark.location.coordinate.latitude,placeMark.location.coordinate.longitude]};
        NSUInteger count = 10;
        for (int i = 0; i < _dataSource.count; i++) {
            NSDictionary *dic = _dataSource[i];
            if ([dic[@"text"] isEqualToString:@"WGS"]) {
                count = i;
            }
        }
        if (count < 10) {
            [_dataSource removeObjectAtIndex:count];
        }
        [_dataSource addObject:dict];
        [_tableView reloadData];
    }];
}

#pragma mark - GCJSearch Delegate
//反地理编码搜索结果
-(void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    NSDictionary *dict = @{@"text":@"高德地图",@"address":response.regeocode.formattedAddress,@"location":[NSString stringWithFormat:@"经度:%f - 维度:%f",request.location.latitude,request.location.longitude]};
    NSUInteger count = 10;
    for (int i = 0; i < _dataSource.count; i++) {
        NSDictionary *dic = _dataSource[i];
        if ([dic[@"text"] isEqualToString:@"高德地图"]) {
            count = i;
        }
    }
    if (count < 10) {
        [_dataSource removeObjectAtIndex:count];
    }
    [_dataSource addObject:dict];
    [_tableView reloadData];
}

#pragma mark - BaiduMapView Delegate
-(void)mapview:(BMKMapView *)mapView onLongClick:(CLLocationCoordinate2D)coordinate {
    BMKAnnotation *annotation = [[BMKAnnotation alloc]init];
    annotation.coordinate = coordinate;
    annotation.title = @"Title";
    annotation.subTitle = @"SubTitle";
    [_mapView addAnnotation:annotation];
}

-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKUserLocation class]]) {
        return nil;
    }
    BMKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"annotationView"];
    if (annotationView == nil) {
        annotationView = [[BMKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"annotationView"];
        annotationView.frame = CGRectMake(0, 0, 20, 20);
        annotationView.canShowCallout = YES;
        annotationView.draggable = YES;
        annotationView.image = [UIImage imageNamed:@"Location"];
    }
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 41)];
    view.backgroundColor = [UIColor lightGrayColor];
    _paopaoView = [[BMKActionPaopaoView alloc]initWithCustomView:view];
    annotationView.paopaoView = _paopaoView;
    UILabel *leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(-50, 0, 32, 41)];
    leftLabel.backgroundColor = [UIColor blueColor];
    annotationView.leftCalloutAccessoryView = leftLabel;
    UILabel *rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, 32, 41)];
    rightLabel.backgroundColor = [UIColor greenColor];
    annotationView.rightCalloutAccessoryView = rightLabel;
    return annotationView;
}
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    CLLocationCoordinate2D coordinate = view.annotation.coordinate;
    _geoCodeOption.reverseGeoPoint = coordinate;
    //百度坐标定位
    [_search reverseGeoCode:_geoCodeOption];
    CLLocationCoordinate2D convertCoordinate = AMapLocationCoordinateConvert(coordinate, AMapLocationCoordinateTypeBaidu);
    _reGeoRequest.location = [AMapGeoPoint locationWithLatitude:convertCoordinate.latitude longitude:convertCoordinate.longitude];
    _reGeoRequest.radius = 1000;
    _reGeoRequest.requireExtension = YES;
    //高德坐标定位
    [_searchAPI AMapReGoecodeSearch:_reGeoRequest];
    //系统WGS定位
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:convertCoordinate altitude:500 horizontalAccuracy:300 verticalAccuracy:300 timestamp:[NSDate date]];
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placeMark = [placemarks objectAtIndex:0];
        NSDictionary *dict = @{@"text":@"WGS",@"address":[NSString stringWithFormat:@"%@%@%@%@",placeMark.locality,placeMark.subLocality,placeMark.thoroughfare,placeMark.subThoroughfare],@"location":[NSString stringWithFormat:@"经度:%f - 维度:%f",placeMark.location.coordinate.latitude,placeMark.location.coordinate.longitude]};
        NSUInteger count = 10;
        for (int i = 0; i < _dataSource.count; i++) {
            NSDictionary *dic = _dataSource[i];
            if ([dic[@"text"] isEqualToString:@"WGS"]) {
                count = i;
            }
        }
        if (count < 10) {
            [_dataSource removeObjectAtIndex:count];
        }
        [_clManager stopUpdatingLocation];
        [_dataSource addObject:dict];
        [_tableView reloadData];
    }];
    MKReverseGeocoder *geoMKCoder = [[MKReverseGeocoder alloc]initWithCoordinate:convertCoordinate];
    geoMKCoder.delegate = self;
    [geoMKCoder start];
}

#pragma mark - MKReverseGeocoder Delegate

-(void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
    NSDictionary *dict = @{@"text":@"MapKit",@"address":[NSString stringWithFormat:@"%@%@%@%@",placemark.locality,placemark.subLocality,placemark.thoroughfare,placemark.subThoroughfare],@"location":[NSString stringWithFormat:@"经度:%f - 维度:%f",placemark.location.coordinate.latitude,placemark.location.coordinate.longitude]};
    NSUInteger count = 10;
    for (int i = 0; i < _dataSource.count; i++) {
        NSDictionary *dic = _dataSource[i];
        if ([dic[@"text"] isEqualToString:@"MapKit"]) {
            count = i;
        }
    }
    if (count < 10) {
        [_dataSource removeObjectAtIndex:count];
    }
    [_dataSource addObject:dict];
    [_tableView reloadData];
}

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MapMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MapMessageCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!cell) {
        cell = [[MapMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSDictionary *dic = _dataSource[indexPath.row];
    cell.message = dic;
    return cell;
}


#pragma mark - GeoCodeSearch Delegate
//地理信息搜索结果
-(void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    NSLog(@"%@",[result address]);
}
//百度反地理编码搜索结果
-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    NSDictionary *dict = @{@"text":@"百度地图",@"address":result.address,@"location":[NSString stringWithFormat:@"经度:%f - 维度:%f",result.location.latitude,result.location.longitude]};
    NSUInteger count = 10;
    for (int i = 0; i < _dataSource.count; i++) {
        NSDictionary *dic = _dataSource[i];
        if ([dic[@"text"] isEqualToString:@"百度地图"]) {
            count = i;
        }
    }
    if (count < 10) {
        [_dataSource removeObjectAtIndex:count];
    }
    [_dataSource addObject:dict];
    [_tableView reloadData];
    [_locService stopUserLocationService];
}


#pragma mark - LocationService Delegate
-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    [_mapView updateLocationData:userLocation];
    [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    if (_mapView.zoomLevel != 15.f) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)2.0f*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:2.0f animations:^{
                _mapView.zoomLevel = 18;
            } completion:nil];
        });
    }
    //根据返回的坐标逆地理编码
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    _geoCodeOption.reverseGeoPoint = coordinate;
    [_search reverseGeoCode:_geoCodeOption];
}


#pragma mark - ViewController Controll
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _locService.delegate = self;
    _mapView.delegate = self;
    _search.delegate = self;
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
    _locService.delegate = nil;
    _search.delegate = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
