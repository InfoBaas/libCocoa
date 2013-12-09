//
//  OBSCollectionPage.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 19/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBSCollectionPage : NSObject

@property (nonatomic, readonly) NSInteger pageNumber;
@property (nonatomic, readonly) NSInteger pageSize;
@property (nonatomic, readonly) NSInteger pageCount;

@property (nonatomic, readonly) NSArray *elements;
@property (nonatomic, readonly) NSInteger elementCount;
@property (nonatomic, readonly) NSInteger firstElement;

@end
