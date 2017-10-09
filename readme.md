# Project 4 - *Name of App Here*

Time spent: **28** hours spent in total

## User Stories

The following **required** functionality is completed:

- [x] Hamburger menu
   - [x] Dragging anywhere in the view should reveal the menu.
   - [x] The menu should include links to your profile, the home timeline, and the mentions view.
   - [x] The menu can look similar to the example or feel free to take liberty with the UI.
- [x] Profile page
   - [x] Contains the user header view
   - [x] Contains a section with the users basic stats: # tweets, # following, # followers
- [x] Home Timeline
   - [x] Tapping on a user image should bring up that user's profile page

The following **optional** features are implemented:

- [x] Profile Page
   - [x] Implement the paging view for the user description.
   - [x] As the paging view moves, increase the opacity of the background screen. See the actual Twitter app for this effect
   - [x] Pulling down the profile page should blur and resize the header image.
- [x] Account switching
   - [x] Long press on tab bar to bring up Account view with animation
   - [x] Tap account to switch to
   - [x] Include a plus button to Add an Account
   - [ ] Swipe to delete an account


The following **additional** features are implemented:

- [x] Hamburger menu
  - [x] Grey in and out effect on content view as user dragged the menu in hamburger view. Disable user interaction in subviews inside content view while the menu view is shown. Capturing tap gesture on content view to fold the menu.
- [x] Profile Page
  - [x] Adjust auto layout constraint of the page view width inside the page scroll view in respect to the actual scroll view frame width. (in viewDidLayoutSubviews)
  - [x] Make navigation bar transparent. Show header image under navigation bar. Pull down the profile page to fold the header image into size of navigation bar and make it blurry.
  - [x] Only using table view for the user tweets table and implement the scoll on the page using a simple state machine. So the scroll indicator only shows in the bottom tweets table part while the upper user info part move separately.
  

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

  1. how to properly maintain oauth sessions for multiple user
  2. 


## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='TwitterAdvancedWalkThrough_Xiang.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Not sure how to properly make the first cell of table view display under the transparent navigation bar initially.

## License

    Copyright [yyyy] [name of copyright owner]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
