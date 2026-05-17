These are the things I want you to implement first:

navbar:
for the navbar items we should only have 3: Home, Explore, and Settings only

PAGES:
Home:
-For the home it has banner that act as the background on the top most and the image for this is @wmsu_banner.png then in front of the banner is another picture which acts as the app name, @wmsu_crest.png
-On the upper right we have an about button use a simple ? mark icon black circular button
-now on this page it has a floating status bar on top it shows where is the user in the map. This status bar is just a long white shape with circular edges and it has 3 elements: the gps status indicator (green for strong, yellow for weak, red for none) its just a small circle dot beside it is the name of the building where the user is based on the map since this is a campus navigation system so if the user is near this building based on the coordinates of the user and the coords of the building based on the json files of nodes.json it will show the name of the building, if not then it will just say Searching for location... or other statuses since its possible the user is at home and not in the campus, and lastly is the lock button as user can lock this location so it wont change when the gps becomes slow or weak.
-on the upper part also below the banner is the two sections:
1. Where are you now? and below it is a button scan a qr
2. To/Destination and below it is a dropdown search box which lists all the buildings and if there are rooms under that building then that item should have a dropodown icon as well clicking it will show the rooms under that building u can use the @indoor.json in the data folder
-below the two sections is a start navigation button
-now thats the upper part the half part of the home page is the mapbox map in the map it has the spawner for the barriers of the campus, the current map active as you can change and the layout and spawners will also change, and the map button (zoom in, zoom out, and i am here)  use the lat and lng of the json files in the infrastructure and nodes for you to have idea.
