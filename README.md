###Guitar Tab Audio Preview

Guitar tablature is musical notation using fret positions, unlike a staff which describes pitch.
Amateurs can contribute tabs for popular songs easily on such sites as ultimate-guitar.com, 911tabs.com, etc.
This is a Google Chrome extension (with associated server scripts) which gives an audio preview of all or part of a guitar tab.
Once running, you can select a segment of a tab by highlighting a rectangular shape with the mouse.
After processing, the web browser plays back an mp3 of the highlighted section.

_Step 1: Load the extension into Chrome_  
Copy manifest.json, background.js, cursor-selection.js, icon.png into a folder.  
Download [jquery.min.js](http://code.jquery.com/jquery-1.11.3.min.js) and place in the same folder.  
Go to chrome://extensions  
Select "Load unpacked extension" and select the extension directory containing these files.  
Note: To update the extension, click **Reload** in chrome://extensions, *and* reload the appropriate web browser tab.

_Step 2: Enable MP3 Server_  
I had an Ubuntu VM running a Perl server on localhost, which responded to requests on the network between the host and guest OS.
Tested on Ubuntu 14.04 LTS, running in VirtualBox 5.0.6, hosted by Windows 7.  

By default, network access to the VM is granted through NAT, in which there is no way for the host OS to directly access the guest OS.
In order to access the Ubuntu localhost from Windows 7:  
In the VM Window, go to `Devices > Network > Network Settings...`  
Set `Attached to: Host-only Adapter` (which is `NAT` by default)  
Find the IP address of the VM with `ifconfig`  
In my case, at this stage the VM could still not see the host OS.
To fix this, in Windows 7 open a terminal and `ping` the above IP address.
Now confirm the host and guest OS can communicate by checking `arp -a` in Ubuntu gives the addess of the host.
On my machine, the host address was 192.168.56.1 and the guest address was 192.168.56.101, which is hard-coded into background.js  
Note: I was not able to access the internet in the Host-only Adapter configuration. Revert to NAT if necessary.

_Step 3: Begin MP3 Server_  
Copy truncate-tab.pl, extract-notes.pl, generate-midi.pl, http-server.pl into a folder.  
Install dependencies for MIDI synthesis and MP3 conversion:
`sudo apt-get install timidity lame`  
Install dependencies from CPAN:
HTTP-Daemon-6.01 and MIDI-Perl-0.83  
Begin with `perl http-server.pl`  

_How to Use:_  
Below is an example of a guitar tab, from *Army Corps of Architects* by Death Cab for Cutie.  

`{verse 2}`  
`e|--------0-------------------------------------------------------|`  
`b|-----1----1----------------3------------------------------------|`  
`g|------0-----0----------0-----0----------------------------------|`  
`d|---2----------2----------0-----0------------2/5\2-------2/5\2---|`  
`a|-3-------------------2-----------2--------3-----------3---------|`  
`e|-------------------3--------------------1-----------1-----------|`

In order to preview this part...  

`e|-------------`  
`b|-------------`  
`g|-------------`  
`d|-------2/5\2-`  
`a|-----3-------`  
`e|---1---------`  

...I highlight the tab, making the start and end points of my cursor the corners of the "cropping rectange."
This is the text that would appear highlighted in the web browser.  

`-------2/5\2-------2/5\2---|`  
`a|-3-------------------2-----------2--------3-----------3---------|`  
`e|-------------------3--------------------1---------`  

Wait, and the audio should play.
At least two string note labels (e.g `a|`, `e|`) must be highlighted at once, in order to provide enough positioning information.

_To Do:_  
MIDI generation needs work. The last fret is not played, and the timing relationships between notes is ignored in favour of uniform spacing.

Add handling for glissando and hammer-on / pull-off.
