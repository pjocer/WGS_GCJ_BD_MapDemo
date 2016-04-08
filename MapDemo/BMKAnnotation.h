//
//  BMKAnnotation.h
//  MapDemo
//
//  Created by PerryJi on 16/4/7.
//  Copyright © 2016年 PerryJi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapKit/BMKAnnotation.h>
@interface BMKAnnotation : NSObject <BMKAnnotation>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end
