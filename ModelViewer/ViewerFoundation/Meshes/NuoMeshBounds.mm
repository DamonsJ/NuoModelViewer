//
//  NuoMeshBounds.m
//  ModelViewer
//
//  Created by Dong on 1/25/18.
//  Copyright © 2018 middleware. All rights reserved.
//

#import "NuoMeshBounds.h"

@implementation NuoMeshBounds
{
    NuoBounds _boundingBox;
}

- (struct NuoBoundsBase*)boundingBox
{
    return &_boundingBox;
}


@end
