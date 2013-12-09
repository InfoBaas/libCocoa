//
//  OBSCollectionPage+.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 19/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSCollectionPage.h"

@interface OBSCollectionPage ()

@property (nonatomic, assign) NSInteger pageNumber;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger pageCount;

@property (nonatomic, assign) NSArray *elements;
@property (nonatomic, assign) NSInteger elementCount;
@property (nonatomic, assign) NSInteger firstElement;

+ (OBSCollectionPage *)collectionPageFromDataJSON:(NSDictionary *)data andMetadataJSON:(NSDictionary *)metadata;

@end
