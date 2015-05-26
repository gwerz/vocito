

Here's some initial documentation for Vocito.
# Quick Intro #

  1. Start up Vocito
  1. Note that you have a new menu item in the upper right hand corner of your screen.
> > ![http://vocito.googlecode.com/svn/trunk/website/main_ui.png](http://vocito.googlecode.com/svn/trunk/website/main_ui.png)
  1. Click on the Vocito item and type in a phone number to call in the "Call" drop down and a phone number you want to receive the call at in the "From" drop down.
> > **Do not use your GrandCentral number for either your "To" or your "From" number. This will not work.**
  1. Click on the "Dial" Button
    * If this is the first time you have run Vocito you will now be prompted for your GrandCentral ID, and your GrandCentral password. These will be stored in your Keychain for future use.
    * Assuming that your login information is entered correctly, Vocito will now dial both phones. You will see progress text telling you what is happening scroll up in the menu bar. The phones should both start to ring momentarily. When they are both answered, they will be connected together.

Other notes:
  * Clicking on the "Address Book" icon will open your Address Book and let you select numbers from there.
  * The "From" Drop down menu is initially populated with your phone numbers as listed on your Address Book card. It will save any other numbers you enter there.
  * Clicking on the "Gear" button will give you more options.

Have fun!



# Address Book Support #
Vocito installs an Address Book plugin. To use it, find a contact in Address Book and click on the label to the right of the phone number that you wish to call, and select the "Vocito Call" menu item.

![http://vocito.googlecode.com/svn/trunk/website/addressbook_ui.png](http://vocito.googlecode.com/svn/trunk/website/addressbook_ui.png)

Vocito will call that number from the last number that Vocito dialed from (ie the number that is showing in the "From" dropdown if you click on the Vocito menu item.

# Quicksilver support #
Vocito also installs a Quicksilver plugin. To use it, type in the name of your contact, select a phone number for them and choose the "Call using Vocito" action.

![http://vocito.googlecode.com/svn/trunk/website/quicksilver_ui.png](http://vocito.googlecode.com/svn/trunk/website/quicksilver_ui.png)

Vocito will call that number from the last number that Vocito dialed from (ie the number that is showing in the "From" dropdown if you click on the Vocito menu item.

You can also enter a number directly into Quicksilver for Vocito to dial by typing a period "." followed by a 10 digit number (area code + number).

# Automator support #
Vocito can also be used via Automator. The action is called "Call With Vocito".

![http://vocito.googlecode.com/svn/trunk/website/automator_ui.png](http://vocito.googlecode.com/svn/trunk/website/automator_ui.png)

The "Use Input" menu allows you to choose whether the data entering the action will be used for the "call number", the "from number" or ignored. The data will be passed through to the next action if appropriate. The Automator action **does not** work on Tiger. This is due to binary incompatibilities introduced in Automator actions between Tiger and Leopard by Apple.

# System Service support #
Select a block of text in almost any application, and then go to the Services menu (under the current Application menu) and choose "Call with Vocito". Vocito will attempt to parse a phone number out of the selected text if possible. The number must be 10 digits (area code + number).

# AppleScript support #
Vocito supports a single command: **dial** text [**from** text]

A simple Vocito script would look like this:
```
tell application "Vocito"
  dial "1234567890" from "9876543210"
end tell
```

Vocito also supports a "from number" property on the application object.
```
tell application "Vocito"
	set from number to "1234567890"
end tell
```
This allows people using applications such as [MarcoPolo](http://www.symonds.id.au/marcopolo/) to set their "from number" based on their location.

# Save As #
Choosing "Save As" from the Gear menu allows you to save an applet that will dial the currently selected numbers in the "From" and "To" box.

# Integrating With iCal #
You can have Vocito automatically dial your phone for you at a certain time using iCal.
  1. Open the Vocito menu item and type in the number you want to dial into "Call" and the number you want to dial from in "From".
  1. Go to the Gear menu and "Save as Application".
  1. Go into iCal and create an appointment for the time you want the phones to be dialed.
  1. Edit the appointment and choose "Open File" from Alarm.
  1. Select the Application that you saved in step 2.

Now when that time comes around, your phones will automatically be dialed for you. Great for auto-connecting into conference calls at a certain time.

# "tel" URL support #
Vocito also supports "tel" URLs, and will register itself as a handler for them. If you find a good use for this, please let me know. tel URLs look like this:

`tel:2501234567`

and when clicked on, Vocito will dial that number from the last "From" number used.

# Trouble Shooting and FAQ #

> **Q)** Vocito tells me that I have entered my login information incorrectly<br>
<blockquote><b>A)</b> Go to the "Vocito" menu and open the window. Click on the "Gear" icon. Select "Preferences" update your information with your correct login information. To get your login information, go to <a href='http://www.grandcentral.com'>http://www.grandcentral.com</a> and attempt to login there.</blockquote>

<blockquote><b>Q)</b> Vocito won't dial a 7 digit number<br>
<b>A)</b> Vocito requires an area code, because Grand Central requires an area code. Please add an area code to make it a 10 digit number.</blockquote>

<blockquote><b>Q)</b> Does Vocito work with <a href='http://gizmo5.com'>Gizmo</a>?<br>
<b>A)</b> As far as I know yes, but for it to work as your "from number" you must have "Callin" capabilities turned on for your Gizmo sip number.</blockquote>

<blockquote><b>Q)</b> Vocito appears to be dialing, but doesn't do anything<br>
<b>A)</b> Please be sure that neither the "To" or the "From" number is your GrandCentral number.</blockquote>

<blockquote><b>Q)</b> Vocito appears to be dialing, but doesn't do anything on Tiger<br>
<b>A)</b> Vocito 1.0.1 had a bug on some Tiger machines. Version 1.1.0 and above fix it.</blockquote>

<blockquote><b>Q)</b> I logged out, and Vocito isn't in my menu bar anymore. How can I get it to stay there?<br>
<b>A)</b> Add it to your startup items.<br>
<ol><li>Go to System Preferences, and choose the "Accounts" panel.<br>
</li><li>Choose the "Login Items" tab.<br>
</li><li>Click on the "Plus" button at the bottom of the screen and select the Vocito application.<br>
</li></ol><blockquote>More information about Startup items is <a href='http://support.apple.com/kb/HT2602'>here</a></blockquote></blockquote>

<blockquote><b>Q)</b> Where do I report bugs?<br>
<b>A)</b> <a href='http://code.google.com/p/vocito/issues/list'>Click Here.</a> Please verify that there isn't already a similar bug in the queue.</blockquote>

<blockquote><b>Q)</b> I can't quit<br>
<b>A)</b> Go to the "Vocito" menu and open the window. Click on the "Gear" icon. Select "Quit".</blockquote>

<blockquote><b>Q)</b> Where did the name come from?<br>
<b>A)</b> Vocito is "call" in Latin.</blockquote>

<blockquote><b>Q)</b> How do you pronounce Vocito?<br>
<b>A)</b> Voe-kee-toe. According to most scholars, Latin speakers used a hard 'c' (sounds like an English 'k') as opposed to the soft 'c' (sounds like an English 'ch') used by Italians and the traditional Catholic Church. We decided to go with the hard 'c' to give us some street cred with all the Latin scholars out there.<br>
<b>A2)</b> I have been informed by many people that if I knew anything about Latin I would know that they pronounced 'v's as 'w's and that it should then by Woe-kee-toe. I'm sticking with the hard 'V' sound and the hard 'C' sound.</blockquote>

<blockquote><b>Q)</b> How can I give input regarding this page to make it better?<br>
<b>A)</b> Add a comment below, or post to the <a href='http://groups.google.com/group/vocito-discuss'>discussion group</a>.