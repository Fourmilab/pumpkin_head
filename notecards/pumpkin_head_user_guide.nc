
                        Fourmilab Pumpkin Head User Guide

Fourmilab Pumpkin Head is a jack-o'lantern (pumpkin carved with a face,
lit from within) which may be worn as a head with both mesh and classic
avatars, or used as a static decoration for Halloween and other
occasions.   It includes a script that allows you to configure its
behaviour via chat command, and provides features such as brightening
the glow of the light when you're typing in chat.

WEARING THE HEAD

You can replace the head of your avatar with the Pumpkin Head and be the
envy of all who regard your visage.  How you do this differs depending on
whether you use a “classic” or mesh avatar.

Classic Avatars

With a classic avatar, the head is integrated with the rest of the
body, and in order for it not to interfere with the pumpkin head, must
be hidden with what is called an “Alpha Mask”, which allows making
portions of the body invisible (transparent).  Two alpha masks are
supplied with Pumpkin Head, “Fourmilab hide head, eyes, and hair alpha
mask” and “Fourmilab hide head alpha mask”.  In most cases, you'll want
to use the first, but for some special kinds of avatars, the second may
work better.  To apply the alpha mask, right click it and select “Add”
(details may differ depending on which viewer you're using).  After a
few moments, you should see you're avatar's head disappear.  If you're
wearing separate hair on the avatar, it will now be floating in space
above your neck.  Right click it and detach it from your avatar.  Now
continue with the instructions under “Adding the Head” below.

Mesh Avatars

Mesh avatars are “worn” on top of a classic avatar which is entirely
hidden by an alpha mask.  Consequently, if you're using one you already
have a full-body alpha mask that hides everything including the head.
Most mesh avatars have separate body and head parts, often purchased
separately from different sellers.  All you have to do is detach the
head and any associated parts such as ears, eyes, eyebrows, devil
horns, etc.  The easiest way to do this is to go to your Inventory
and open the “Current Outfit” folder, which contains links to
everything you are currently wearing, including mesh avatar components.
Right click the components associated with the head and select “Detach
from Yourself” to remove them.  (Details may differ depending on which
viewer you're using.)  If you're wearing mesh hair, remove it also.
You should now be headless.  Proceed with “Adding the Head” below.
(Some mesh avatars, particularly those for non-human creatures such
as animals and robots, may have integrated heads which cannot be
removed or hidden.  These cannot be used with the Pumpkin Head.)

Adding the Head

Now you're ready to add the Pumpkin Head to your avatar.  Right click
on “Fourmilab Pumpkin Head” in your inventory and click “Add”.  It
should appear, replacing your former head.  If, for some screwball
reason, it shows up attached to, say, your left foot, detach it, right
click again, and use “Attach To” then select “Skull”.  Once attached,
it should remember the location so you can just Add it subsequently.
Depending on the size and shape of your avatar, you may want to adjust
the pumpkin head up or down so it isn't too close to your shoulders or
floating above your neck.  Just right click it, select “Edit”, and
adjust the vertical position as you wish—this also should be remembered
the next time you wear the head.

It accepts commands submitted on local chat channel
77 by the wearer and responds in local chat to the wearer.  Commands
are as follows.

USING THE PUMPKIN HEAD AS A DECORATION

In addition to wearing the Pumpkin Head on your avatar, you can use it
as a static decoration, for example when hosting a Halloween party.
Simply rez the pumpkins from your inventory, as many as you like, and
place and orient them however you wish.  Each pumpkin has a land impact
of 6, which is about as low as possible for a mesh object of its
complexity.  You can use the chat commands described below to configure
the pumpkin as you wish, then use the “Delete script” command to freeze
the settings and avoid the script's wasting time in your simulation.
Note that if you're wearing the pumpkin head on your avatar at the same
time you send chat commands to one you've rezzed, both will respond to
commands of channel 1031.  To avoid this change the channel of the one
you're wearing before rezzing others as decorations.

CHAT COMMANDS

Fourmilab Pumpkin Head accepts commands submitted on local chat channel 
1031 (the date of Halloween, October 31st) by the wearer and responds 
in local chat to the wearer.  Commands are as follows. Most chat 
commands and parameters, except those specifying names from the 
inventory, may be abbreviated to as few as two characters and are 
insensitive to upper and lower case.

    Access public/group/owner
        Specifies who can send commands to the pumpkin.  You can
        restrict it to the owner only, members of the owner's group, or
        open to the general public.  Default access is by owner.

    Boot
        Reset the script.  All settings will be restored to their
        defaults.  If you have changed the chat command channel, this
        will restore it to the default of 1031.


    Channel n
        Set the channel on which the head listens for commands in
        local chat to channel n.  If you subsequently reset the
        script with the “Boot” command or manually, the chat
        channel will revert to the default of 1031.

    Clear
        Send vertical white space to local chat to separate output when
        debugging.

    Delete script
        Delete the script from Pumpkin Head.  After you enter this
        command, no further commands will be accepted, as the scripts
        which process them will be gone.  After you've made a custom
        configuration and are satisfied with the results, you can use
        this command to freeze your changes and prevent further
        modifications and also reduce the load your avatar places on
        the simulator.  This is particularly useful if you're planning
        to place numerous copies of the pumpkin as decorations, as
        there's no need for them to be running a time-consuming script.
        To avoid accidents, this command may not be abbreviated.

    Echo text
        Echo the text in local chat.  This allows scripts to send
        messages to those running them to let them know what they're
        doing.

    Help
        Send this notecard to the requester.

    Run [ Script Name ]
        Run the specified Script Name.  The name must be specified 
        exactly as the notecard is named in the inventory.  Scripts may 
        be nested, so the “Run” command may appear within a script.

    Set
        Set a variety of parameters.

        Set echo on/off
            Controls whether commands entered from local chat or a
            script are echoed to local chat as they are executed.

        Set flicker on/off
            Controls whether the light inside the pumpkin flickers
            like a candle or is steady.  This is on by default.

        Set glow active idle
            Sets the amount of glow from the light inside the pumpkin
            when the wearer is typing in chat (active) and not (idle)
            to the given values between 0 and 1.  The defaults are 0.2
            for active and 0.05 for idle.

        Set light on/off
            Enables or disables the light inside the pumpkin.  When
            disabled, only ambient illumination is used.

        Set shine intensity <r, g, b> range falloff
            Set the light as a point light source (or turn it off),
            with the specified intensity (1) and colour (as red, green,
            and blue values between 0 and 1), range (5), and falloff
            (1) parameters given (defaults in parentheses).  The
            settings are as used in the PRIM_POINT_LIGHT prim
            parameter:
                http://wiki.secondlife.com/wiki/PRIM_POINT_LIGHT
            Due to limitations in Second Life's lighting model, his
            will illuminate everything in the vicinity of the pumpkin,
            not just those in front of the face.

        Set trace on/off
            Enable or disable output, sent to the owner on local chat,
            describing operations as they occur.  This is generally
            only of interest to developers.

    Status
        Show status of the script, including settings and memory usage.

CONFIGURATION NOTECARD

When the pumpkin head is initially rezzed or reset with the Boot 
command, if there is a notecard in its inventory named “Fourmilab 
Pumpkin Head Configuration”, the commands it contains will be executed 
as if entered via local chat (do not specify the chat channel on the 
script lines).  This allows you to automatically set preferences as you 
like.

PERMISSIONS AND THE DEVELOPMENT KIT

Fourmilab Pumpkin Head is delivered with "full permissions". Every part
of the object, including the script, may be copied, modified, and
transferred subject only to the license below.  If you find a bug and
fix it, or add a feature, let me know so I can include it for others to
use.  The distribution includes a “Development Kit” directory, which
includes all of the components (for example, the alpha masks and
textures) of the model.

The Development Kit directory contains a Logs subdirectory which
includes the development narratives for the project.  If you wonder
"Why does it work that way?" the answer may be there.

Source code for this project is maintained on and available from the
GitHub repository:
    https://github.com/Fourmilab/pumpkin_head

LICENSE

This product (software, documents, and models) is licensed under a
Creative Commons Attribution-ShareAlike 4.0 International License.
    http://creativecommons.org/licenses/by-sa/4.0/
    https://creativecommons.org/licenses/by-sa/4.0/legalcode
You are free to copy and redistribute this material in any medium or
format, and to remix, transform, and build upon the material for any
purpose, including commercially.  You must give credit, provide a link
to the license, and indicate if changes were made.  If you remix,
transform, or build upon this material, you must distribute your
contributions under the same license as the original.

ACKNOWLEDGEMENTS

The mesh pumpkin is based upon the Blender model “Pumpkin” created by
Blend Swap user “anthuk” and released under the Creative Commons Zero
1.0 license, "You are free to use this asset privately for any use you
see fit. If you choose to distribute copies or modified versions of
this asset you must do so under the following requirements: There are
no requirements for this license.”
