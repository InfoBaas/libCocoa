//
//  OBSCollectionPage.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 19/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSCollectionPage+.h"

@implementation OBSCollectionPage

+ (OBSCollectionPage *)collectionPageFromDataJSON:(NSDictionary *)data andMetadataJSON:(NSDictionary *)metadata
{
    NSArray *elements = data[@"ids"];
    if (!elements || [elements isEqual:[NSNull null]]) {
        return nil;
    }
    NSNumber *pageNumber = data[@"pageNumber"];
    if (!pageNumber || [pageNumber isEqual:[NSNull null]]) {
        return nil;
    }
    NSNumber *pageSize = data[@"pageSize"];
    if (!pageSize || [pageSize isEqual:[NSNull null]]) {
        return nil;
    }
    NSNumber *numberOfElements = data[@"totalElems"];
    if (!numberOfElements || [numberOfElements isEqual:[NSNull null]]) {
        return nil;
    }
    NSNumber *numberOfPages = data[@"totalnumberpages"];
    if (!numberOfPages || [numberOfPages isEqual:[NSNull null]]) {
        return nil;
    }

    OBSCollectionPage *collectionPage = [[self alloc] init];

    collectionPage.elements = elements;
    collectionPage.pageNumber = [pageNumber integerValue];
    collectionPage.pageSize = [pageSize integerValue];
    collectionPage.pageCount = [numberOfPages integerValue];

    collectionPage.elementCount = [[collectionPage elements] count];
    collectionPage.firstElement = (collectionPage.pageNumber - 1) * collectionPage.pageCount + 1;

    return collectionPage;
}

@end
