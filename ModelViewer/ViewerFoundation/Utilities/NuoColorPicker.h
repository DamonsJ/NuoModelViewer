//
//  NuoColorPicker.h
//  ModelViewer
//
//  Created by Dong on 10/8/19.
//  Copyright © 2019 middleware. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface NuoColorPicker : NSView


@property (nonatomic, strong) NSString* panelName;
@property (nonatomic, strong) NSColor* color;
@property (nonatomic, strong) void((^colorChanged)(void));


@end


