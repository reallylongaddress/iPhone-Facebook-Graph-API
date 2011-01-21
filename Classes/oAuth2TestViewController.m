/*
 * Copyright (c) 2010, Dominic DiMarco (dominic@ReallyLongAddress.com)
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * -Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 * 
 * -Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * 
 * -Neither the name of the author nor the
 * names of its contributors may be used to endorse or promote products
 * derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */

//
//  oAuth2TestViewController.m
//  oAuth2Test
//
//  Created by dominic dimarco (ddimarco@room214.com @dominicdimarco) on 5/22/10.
//

#import "oAuth2TestViewController.h"
#import "SBJSON.h"
#import "FbGraphFile.h"

@implementation oAuth2TestViewController

@synthesize fbGraph;
@synthesize feedPostId;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	
	/*Facebook Application ID*/
	NSString *client_id = @"130902823636657";
	
	//alloc and initalize our FbGraph instance
	self.fbGraph = [[FbGraph alloc] initWithFbClientID:client_id];
	
	//begin the authentication process.....
	[fbGraph authenticateUserWithCallbackObject:self andSelector:@selector(fbGraphCallback:) 
						 andExtendedPermissions:@"user_photos,user_videos,publish_stream,offline_access,user_checkins,friends_checkins"];
	
	/**
	 * OR you may wish to 'anchor' the login UIWebView to a window not at the root of your application...
	 * for example you may wish it to render/display inside a UITabBar view....
	 *
	 * Feel free to try both methods here, simply (un)comment out the appropriate one.....
	 **/
	//	[fbGraph authenticateUserWithCallbackObject:self andSelector:@selector(fbGraphCallback:) andExtendedPermissions:@"user_photos,user_videos,publish_stream,offline_access" andSuperView:self.view];
	
}

- (void)dealloc {
	
	if (feedPostId != nil) {
		[feedPostId release];
	}
	[fbGraph release];
    [super dealloc];
}
/**
 * DOC:  http://developers.facebook.com/docs/api#selection
 * DOC:  http://developers.facebook.com/docs/reference/api/user
 **/
-(IBAction)getMeButtonPressed:(id)sender {
	FbGraphResponse *fb_graph_response = [fbGraph doGraphGet:@"me" withGetVars:nil];
	NSLog(@"getMeButtonPressed:  %@", fb_graph_response.htmlResponse);
	
}

/**
 * DOC:  http://developers.facebook.com/docs/api#selection
 * DOC:  http://developers.facebook.com/docs/reference/api/user
 **/
-(IBAction)getMeFriendsButtonPressed:(id)sender {
	FbGraphResponse *fb_graph_response = [fbGraph doGraphGet:@"me/friends" withGetVars:nil];
	NSLog(@"getMeFriendsButtonPressed:  %@", fb_graph_response.htmlResponse);
}

/**
 * DOC:  http://developers.facebook.com/docs/api#selection
 * DOC:  http://developers.facebook.com/docs/reference/api/user
 **/
-(IBAction)getMeFeedButtonPressed:(id)sender {
	FbGraphResponse *fb_graph_response = [fbGraph doGraphGet:@"me/feed" withGetVars:nil];
	NSLog(@"getMeFeedButtonPressed:  %@", fb_graph_response.htmlResponse);
}

/**
 * DOC:  http://developers.facebook.com/docs/api#publishing
 * DOC:  http://developers.facebook.com/docs/reference/api/user
 **/
-(IBAction)postMeFeedButtonPressed:(id)sender {
	
	NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:4];
	
	[variables setObject:@"this is a test message: postMeFeedButtonPressed" forKey:@"message"];
 	[variables setObject:@"http://bit.ly/bFTnqd" forKey:@"link"];
 	[variables setObject:@"This is the bolded copy next to the image" forKey:@"name"];
 	[variables setObject:@"This is the plain text copy next to the image.  All work and no play makes Jack a dull boy." forKey:@"description"];
	
	FbGraphResponse *fb_graph_response = [fbGraph doGraphPost:@"me/feed" withPostVars:variables];
	NSLog(@"postMeFeedButtonPressed:  %@", fb_graph_response.htmlResponse);
	
	//parse our json
	SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *facebook_response = [parser objectWithString:fb_graph_response.htmlResponse error:nil];	
	[parser release];
	
	//let's save the 'id' Facebook gives us so we can delete it if the user presses the 'delete /me/feed button'
	self.feedPostId = (NSString *)[facebook_response objectForKey:@"id"];
	NSLog(@"feedPostId, %@", feedPostId);
	NSLog(@"Now log into Facebook and look at your profile...");
	
}

/**
 * DOC:  http://developers.facebook.com/docs/api#publishing
 * DOC:  http://developers.facebook.com/docs/reference/api/photo
 **/
-(IBAction)postPictureButtonPressed:(id)sender {
	
	NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:2];
	
	//create a UIImage (you could use the picture album or camera too)
	UIImage *picture = [UIImage imageNamed:@"75x75.png"];
	
	//create a FbGraphFile object insance and set the picture we wish to publish on it
	FbGraphFile *graph_file = [[FbGraphFile alloc] initWithImage:picture];
	
	//finally, set the FbGraphFileobject onto our variables dictionary....
	[variables setObject:graph_file forKey:@"file"];
	
	[variables setObject:@"this is a test message: postPictureButtonPressed" forKey:@"message"];
	
	//the fbGraph object is smart enough to recognize the binary image data inside the FbGraphFile
	//object and treat that is such.....
	FbGraphResponse *fb_graph_response = [fbGraph doGraphPost:@"117795728310/photos" withPostVars:variables];
	NSLog(@"postPictureButtonPressed:  %@", fb_graph_response.htmlResponse);
	
	
	NSLog(@"Now log into Facebook and look at your profile & photo albums...");
	
}	

/**
 * DOC:  http://developers.facebook.com/docs/api#introspection
 **/
-(IBAction)getMeMetadataButtonPressed:(id)sender {
	
	NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:1];
	[variables setObject:@"1" forKey:@"metadata"];
	FbGraphResponse *fb_graph_response = [fbGraph doGraphGet:@"me" withGetVars:variables];
	
	NSLog(@"getMeMetadataButtonPressed:  %@", fb_graph_response.htmlResponse);
}

/**
 * NOTE:  Facebook also supports the HTTP Delete function, but for the sake of simplicity
 * we're using the HTTP Post method with a delete flag
 *
 * DOC:  http://developers.facebook.com/docs/api#deleting
 **/
-(IBAction)deleteMeFeedButtonPressed:(id)sender {
	
	if (feedPostId != nil) {
		
		NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:1];
		
		[variables setObject:@"delete" forKey:@"method"];
		FbGraphResponse *fb_graph_response = [fbGraph doGraphPost:feedPostId withPostVars:variables];
		NSLog(@"http_response:  %@", fb_graph_response.htmlResponse);
		
		//since it's been removed from facebook, clear our feedPostId
		self.feedPostId = nil;
		
		//if they haven't pressed 'post me/feed' yet let them know they have to
	} else {
		//pop a message letting them know most of the info will be dumped in the log
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Note" message:@"Please post to your stream first by pressing 'post me/feed', then delete." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

/**
 * DOC:  http://developers.facebook.com/docs/api#search
 **/
-(IBAction)searchButtonPressed:(id)sender {
	
	NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:2];
	
	[variables setObject:@"iphone 4" forKey:@"q"];
	[variables setObject:@"post" forKey:@"type"];
	
	FbGraphResponse *fb_graph_response = [fbGraph doGraphGet:@"search" withGetVars:variables];
	
	NSLog(@"Raw HTML:  %@", fb_graph_response.htmlResponse);
	
	/**
	 * Lets go into some level of detail of how to parse data out of
	 * the JSON formated response data we get from Facebook.
	 * Personally I like the SBJSON parser which can be found here:
	 * http://code.google.com/p/json-framework/
	 *
	 * There's several solid examples to be found via Google, here's how
	 * I use it....
	 */
	
	//parse the json into a NSDictionary
	SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *parsed_json = [parser objectWithString:fb_graph_response.htmlResponse error:nil];	
	[parser release];
	
	//there's 2 additional dictionaries inside this one on the first level ('data' and 'paging')
	NSDictionary *data = (NSDictionary *)[parsed_json objectForKey:@"data"];
	
	//how many wall posts have been returned that meet our search criteria (25 max by default)
	NSLog(@"# search results:  %i", [data count]);
	
	NSEnumerator *enumerator = [data objectEnumerator];
	NSDictionary *wall_post;
	
	while ((wall_post = (NSDictionary *)[enumerator nextObject])) {
		
		NSDictionary *posted_by_dict = (NSDictionary *)[wall_post objectForKey:@"from"];
		NSString *from_name = (NSString *)[posted_by_dict objectForKey:@"name"];
		NSString *from_fb_id = (NSString *)[posted_by_dict objectForKey:@"id"];
		
		NSString *message = (NSString *)[wall_post objectForKey:@"message"];
		
		NSLog(@"FromName (FB ID):  Message:  %@ (%@):  %@", from_name, from_fb_id, message);
	}
	
	//Just so you know, this is how the pagination works...Facebook returns to
	//us a link with two links (next & previous)
	NSDictionary *paging = (NSDictionary *)[parsed_json objectForKey:@"paging"];
	NSString *next_page_url = (NSString *)[paging objectForKey:@"next"];
	
	FbGraphResponse *next_page_fb_graph_response = [fbGraph doGraphGetWithUrlString:next_page_url];
	
	NSLog(@"Next Page:  %@", next_page_fb_graph_response.htmlResponse);
}

/**
 * DOC:  http://developers.facebook.com/docs/reference/api/photo
 **/
-(IBAction)getAuthorPictureButtonPressed:(id)sender {
	
	NSString *get_string = [NSString stringWithFormat:@"%@/picture", @"1203788197"];
	FbGraphResponse *fb_graph_response = [fbGraph doGraphGet:get_string withGetVars:nil];
	
	/**
	 * Rather than returing a url to the image, Facebook will stream an image file's bits back to us..
	 **/
	if (fb_graph_response.imageResponse != nil) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Author's Avatar" message:@"~Cheese~" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		
		//simply set the UIImage we have in the image view to display....easy as pie.....mmmm pie....
		UIImageView *image_view = [[UIImageView alloc] initWithImage:fb_graph_response.imageResponse];
		[alert addSubview:image_view];
		[alert show];
		
	}//end if
}

#pragma mark -
#pragma mark FbGraph Callback Function
/**
 * This function is called by FbGraph after it's finished the authentication process
 **/
- (void)fbGraphCallback:(id)sender {
	
	if ( (fbGraph.accessToken == nil) || ([fbGraph.accessToken length] == 0) ) {
		
		NSLog(@"You pressed the 'cancel' or 'Dont Allow' button, you are NOT logged into Facebook...I require you to be logged in & approve access before you can do anything useful....");
		
		//restart the authentication process.....
		[fbGraph authenticateUserWithCallbackObject:self andSelector:@selector(fbGraphCallback:) 
							 andExtendedPermissions:@"user_photos,user_videos,publish_stream,offline_access,user_checkins,friends_checkins"];
		
	} else {
		//pop a message letting them know most of the info will be dumped in the log
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Note" message:@"For the simplest code, I've written all output to the 'Debugger Console'." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		NSLog(@"------------>CONGRATULATIONS<------------, You're logged into Facebook...  Your oAuth token is:  %@", fbGraph.accessToken);
		
	}
	
}

@end
