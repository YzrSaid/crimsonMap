Now lets implement the pathfinding algorithm. Right now when i choose a destination it makes the start navigation button active but it shouldnt since it has no FROM yet. It needs From and To/Destination. Now the flow is the From or where you are now is by scanning a qr or by the location_status_bar where in if it sense that your location is near a registered building in the json files so you can lock that and that will be your FROM but when you scan a qr and the qr succeeds it will now be the value of the location_status_bar and it automatically locks that location thsi is helpful in times the gps is weak and it cant sense any nearby buildings. 

But heres the problem, our school hasnt had qr codes yet in all buildings and locations in the school so maybe instead of just scan a qr create a button (so two buttons one main and one secondary small for qr) soi the main will be a dropdown as well like the destination. where user can choose where they are. Of course when this specific room or building/infra has been chosen already, in the dropdown in the destination it must not show anymore the building or room chosen in the FROM or just make it inactive or not clikable.

Now if there is already FROM and TO thats the time the Start Navigation becomes active and clickable. When user clicks that, it will now show a modal showing all the possible routes now this is the pathfinding algorithm. In my c# codes i already implemented this try to look at the @AStarAlgorithm.cs as you can see i already implemented the algorithm to look for possible routes and list all the routes possible and the first one must be the with Recommended tag as this is the shortest one. I used a* algorituhm to pick for the shortest and run again the algorithm with penalties to avoid making a route the same with the first one and if i have more than 2 or 3 i will set it with minimum of 3 routes.

### UI Changes
1. **Destination Picker**: Implement a dropdown for selecting the FROM location.
2. **QR Code Button**: Add a secondary button for scanning QR codes.
3. **Disable Selected Locations**: Ensure that selected FROM locations are disabled in the destination dropdown.
4. **Start Navigation Button**: Activate only when both FROM and TO are selected.
5. **Modal for Routes**: Display a modal with possible routes when navigation starts.

