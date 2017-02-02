//
//  ModelPanelUpdate.h
//  ModelViewer
//
//  Created by middleware on 1/29/17.
//  Copyright © 2017 middleware. All rights reserved.
//

#ifndef ModelPanelUpdate_h
#define ModelPanelUpdate_h


@class NuoMesh;


@protocol ModelPanelUpdate

- (void)modelPartSelectionChanged:(NSArray<NuoMesh*>*)selection;

@end


#endif /* ModelPanelUpdate_h */
