//
//  MapMessageCell.h
//  MapDemo
//
//  Created by PerryJi on 16/4/6.
//  Copyright © 2016年 PerryJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapMessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (strong, nonatomic) NSDictionary *message;
@end
