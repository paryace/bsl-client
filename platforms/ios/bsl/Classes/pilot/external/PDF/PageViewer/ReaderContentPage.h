//
//	ReaderContentPage.h
//	Reader v2.5.4
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2012 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Scanner.h"

@interface ReaderContentPage : UIView
{
@private // Instance variables

	NSMutableArray *_links;

	CGPDFDocumentRef _PDFDocRef;

	CGPDFPageRef _PDFPageRef;

	NSInteger _pageAngle;

	CGSize _pageSize;
}

@property (nonatomic, retain) Scanner *scanner;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, copy) NSArray *selections;

- (id)initWithURL:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)phrase;

- (id)singleTap:(UITapGestureRecognizer *)recognizer;

@end

#pragma mark -

//
//	ReaderDocumentLink class interface
//

@interface ReaderDocumentLink : NSObject
{
@private // Instance variables

	CGPDFDictionaryRef _dictionary;

	CGRect _rect;
}

@property (nonatomic, assign, readonly) CGRect rect;

@property (nonatomic, assign, readonly) CGPDFDictionaryRef dictionary;

+ (id)withRect:(CGRect)linkRect dictionary:(CGPDFDictionaryRef)linkDictionary;

- (id)initWithRect:(CGRect)linkRect dictionary:(CGPDFDictionaryRef)linkDictionary;

@end
