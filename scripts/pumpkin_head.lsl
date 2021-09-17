    /*

                    Fourmilab Pumpkin Head
                        The Inner Light

        This script is installed in the mesh pumpkin prim, which
        is the root prim of the link set.  Its sole purpose is to
        control the child prim which generates the lighting effects
        for the object.  The script is kept in the root prim to avoid
        confusion and make it easier for the user to, for example,
        configure by placing a script in the root prim.

    */

    integer INNER_LIGHT_LINK = 2;   // Link number of the inner light
    integer FACE_HEMISPHERE = 1;    // Hemisphere facing front

    key owner;                      // Owner UUID
    integer commandChannel = 1031;  // Command channel in chat
    integer commandH;               // Handle for command channel
    key whoDat = NULL_KEY;          // Avatar to whom we're attached
    integer restrictAccess = 0;     // Access restriction: 0 none, 1 group, 2 owner
    integer echo = TRUE;            // Echo chat and script commands ?
    integer flicker = TRUE;         // Should candlelight flicker ?

    string helpFileName = "Fourmilab Pumpkin Head User Guide";

    integer typing = FALSE;         // Is avatar typing ?
    float glowIdle = 0.05;          // Glow while idle
    float glowActive = 0.2;         // Glow while active
    integer lighton = TRUE;         // Is full bright light enabled ?

    //  Configuration script name
    string configScript = "Fourmilab Pumpkin Head Configuration";

    //  Script processing

    string ncSource = "";           // Current notecard being read
    key ncQuery;                    // Handle for notecard query
    integer ncLine = 0;             // Current line in notecard
    integer ncBusy = FALSE;         // Are we reading a notecard ?
    list ncQueue = [ ];             // Queue of pending notecards to read
    integer configuring;            // Processing configuration script ?

    //  tawk  --  Send a message to the interacting user in chat

    tawk(string msg) {
        if (whoDat == NULL_KEY) {
            //  No known sender.  Say in nearby chat.
            llSay(PUBLIC_CHANNEL, msg);
        } else {
            /*  While debugging, when speaking to the owner, use llOwnerSay()
                rather than llRegionSayTo() to avoid the risk of a runaway
                blithering loop triggering the gag which can only be removed
                by a region restart.  */
            if (owner == whoDat) {
                llOwnerSay(msg);
            } else {
                llRegionSayTo(whoDat, PUBLIC_CHANNEL, msg);
            }
        }
    }

    //  Static constants to avoid costly allocation
    string efkdig = "0123456789";
    string efkdifdec = "0123456789.";

    string ef(string s) {
        integer p = llStringLength(s) - 1;

        while (p >= 0) {
            //  Ignore non-digits after numbers
            while ((p >= 0) &&
                   (llSubStringIndex(efkdig, llGetSubString(s, p, p)) < 0)) {
                p--;
            }
            //  Verify we have a sequence of digits and one decimal point
            integer o = p - 1;
            integer digits = 1;
            integer decimals = 0;
            string c;
            while ((o >= 0) &&
                   (llSubStringIndex(efkdifdec, (c = llGetSubString(s, o, o))) >= 0)) {
                o--;
                if (c == ".") {
                    decimals++;
                } else {
                    digits++;
                }
            }
            if ((digits > 1) && (decimals == 1)) {
                //  Elide trailing zeroes
                integer b = p;
                while ((b >= 0) && (llGetSubString(s, b, b) == "0")) {
                    b--;
                }
                //  If we've deleted all the way to the decimal point, remove it
                if ((b >= 0) && (llGetSubString(s, b, b) == ".")) {
                    b--;
                }
                //  Remove everything we've trimmed from the number
                if (b < p) {
                    s = llDeleteSubString(s, b + 1, p);
                    p = b;
                }
                //  Done with this number.  Skip to next non digit or decimal
                while ((p >= 0) &&
                       (llSubStringIndex(efkdifdec, llGetSubString(s, p, p)) >= 0)) {
                    p--;
                }
            } else {
                //  This is not a floating point number
                p = o;
            }
        }
        return s;
    }

    string eff(float f) {
        return ef((string) f);
    }

//    string efv(vector v) {
//        return ef((string) v);
//    }

    //  checkAccess  --  Check if user has permission to send commands

    integer checkAccess(key id) {
        return (restrictAccess == 0) ||
               ((restrictAccess == 1) && llSameGroup(id)) ||
               (id == llGetOwner());
    }

    //  abbrP  --  Test if string matches abbreviation

    integer abbrP(string str, string abbr) {
        return abbr == llGetSubString(str, 0, llStringLength(abbr) - 1);
    }

    //  constrain  --  Constrain a float parameter within limit

    float constrain(float v, float low, float high) {
        if (v > high) {
            v = high;
        } else if (v < low) {
            v = low;
        }
        return v;
    }

    //  onOff  --  Parse an on/off parameter

    integer onOff(string param) {
        if (abbrP(param, "on")) {
            return TRUE;
        } else if (abbrP(param, "of")) {
            return FALSE;
        } else {
            tawk("Error: please specify on or off.");
            return -1;
        }
    }

    //  eOnOff  -- Edit an on/off parameter

    string eOnOff(integer p) {
        if (p) {
            return "on";
        }
        return "off";
    }

    //  updGlow  --  Update glow on light

    updGlow() {
        float gl = glowIdle;
        if (typing) {
            gl = glowActive;
        }
        llSetLinkPrimitiveParamsFast(INNER_LIGHT_LINK,
            [ PRIM_GLOW, FACE_HEMISPHERE, gl ]);
    }

    /*  fixArgs  --  Transform command arguments into canonical form.
                     All white space within vector and rotation brackets
                     is elided so they will be parsed as single arguments.  */

    string fixArgs(string cmd) {
        cmd = llToLower(llStringTrim(cmd, STRING_TRIM));
        integer l = llStringLength(cmd);
        integer inbrack = FALSE;
        integer i;
        string fcmd = "";

        for (i = 0; i < l; i++) {
            string c = llGetSubString(cmd, i, i);
            if (inbrack && (c == ">")) {
                inbrack = FALSE;
            }
            if (c == "<") {
                inbrack = TRUE;
            }
            if (!((c == " ") && inbrack)) {
                fcmd += c;
            }
        }
        return fcmd;
    }

    //  scriptName  --  Extract original name from command

    string scriptName(string cmd, string lmessage, string message) {
        integer dindex = llSubStringIndex(lmessage, cmd);
        dindex += llSubStringIndex(llGetSubString(lmessage, dindex, -1), " ");
        return llStringTrim(llGetSubString(message, dindex, -1), STRING_TRIM);
    }

    //  processCommand  --  Process a command

    integer processCommand(key id, string message) {

        if (!checkAccess(id)) {
            llRegionSayTo(id, PUBLIC_CHANNEL,
                "You do not have permission to control this object.");
            return FALSE;
        }

        whoDat = id;            // Direct chat output to sender of command

        /*  If echo is enabled, echo command to sender unless
            prefixed with "@".  */

        integer echoCmd = TRUE;
        if (llGetSubString(llStringTrim(message, STRING_TRIM_HEAD), 0, 0) == "@") {
            echoCmd = FALSE;
            message = llGetSubString(llStringTrim(message, STRING_TRIM_HEAD), 1, -1);
        }
        if (echo && echoCmd) {
            string prefix = ">> /" + (string) commandChannel + " ";
            tawk(prefix + message);             // Echo command to sender
        }

        string lmessage = fixArgs(message);
        list args = llParseString2List(lmessage, [ " " ], []);    // Command and arguments
        integer argn = llGetListLength(args);       // Number of arguments
        string command = llList2String(args, 0);    // The command
        string sparam = llList2String(args, 1);     // First argument, for convenience

        //  Access who                  Restrict chat command access to public/group/owner

        if (abbrP(command, "ac")) {
            string who = sparam;

            if (abbrP(who, "p")) {          // Public
                restrictAccess = 0;
            } else if (abbrP(who, "g")) {   // Group
                restrictAccess = 1;
            } else if (abbrP(who, "o")) {   // Owner
                restrictAccess = 2;
            } else {
                tawk("Unknown access restriction \"" + who +
                    "\".  Valid: public, group, owner.\n");
                return FALSE;
            }

        //  Boot                    Reset the script to initial settings

        } else if (abbrP(command, "bo")) {
            llResetScript();

        /*  Channel n               Change command channel.  Note that
                                    the channel change is lost on a
                                    script reset.  */

        } else if (abbrP(command, "ch")) {
            integer newch = (integer) sparam;
            if ((newch < 2)) {
                tawk("Invalid channel " + (string) newch + ".");
                return FALSE;
            } else {
                llListenRemove(commandH);
                commandChannel = newch;
                commandH = llListen(commandChannel, "", NULL_KEY, "");
                tawk("Listening on /" + (string) commandChannel);
            }

        //  Clear                       Clear chat for debugging

        } else if (abbrP(command, "cl")) {
            tawk("\n\n\n\n\n\n\n\n\n\n\n\n\n");

        //  Delete script               Delete this script (cannot be abbreviated)

        } else if ((command == "delete") && (sparam == "script")) {
            tawk("Script deleted.");
            llSleep(0.1);
            llRemoveInventory(llGetScriptName());
            while (TRUE) {
                llSleep(0.1);           // Spin until we go away
            }

        //  Echo text                   Send text to sender

        } else if (abbrP(command, "ec")) {
            tawk(scriptName("ec", lmessage, message));

        //  Help                        Give help information

        } else if (abbrP(command, "he")) {
            llGiveInventory(id, helpFileName);      // Give requester the User Guide notecard

        //  Run scrname                 Run script from notecard

        } else if (abbrP(command, "ru")) {
            processNotecardCommands(scriptName("ru", lmessage, message), whoDat);

        //  Set                     Set parameter

        } else if (abbrP(command, "se")) {
            string svalue = llList2String(args, 2);

            //  Set echo on/off                 Control echoing of commands

            if (abbrP(sparam, "ec")) {
                integer b = onOff(svalue);
                if (b >= 0) {
                    echo = b;
                }

            //  Set flicker on/off

            } else if (abbrP(sparam, "fl")) {
                flicker = onOff(svalue);
                if (flicker) {
                    llSetLinkTextureAnim(INNER_LIGHT_LINK,
                        ANIM_ON | LOOP | PING_PONG, FACE_HEMISPHERE, 4, 4, 0, 16, 8);
                } else {
                    llSetLinkTextureAnim(INNER_LIGHT_LINK,
                        ANIM_ON | LOOP | PING_PONG, FACE_HEMISPHERE, 4, 4, 0, 1, 0.01);
                }

            //  Set glow active idle        Set glow for active and idle state

            } else if (abbrP(sparam, "gl")) {
                glowActive = constrain((float) svalue, 0, 1);
                glowIdle = constrain((float) llList2String(args, 3), 0, 1);
                updGlow();

            //  Set light on/off            Enable/disable full bright light

            } else if (abbrP(sparam, "li")) {
                lighton = onOff(svalue);
                llSetLinkPrimitiveParamsFast(INNER_LIGHT_LINK,
                    [ PRIM_FULLBRIGHT, FACE_HEMISPHERE, lighton ]);

            //  Set shine intensity <r,g,b> radius falloff

            } else if (abbrP(sparam, "sh")) {
                if (argn >= 3) {
                    list cshine = llGetLinkPrimitiveParams(INNER_LIGHT_LINK,
                        [ PRIM_POINT_LIGHT ]);
                    integer shining = llList2Integer(cshine, 0);
                    vector colour = (vector) llList2String(cshine, 1);
                    float intensity = llList2Float(cshine, 2);
                    float radius = llList2Float(cshine, 3);
                    float falloff = llList2Float(cshine, 4);

                    intensity = (float) svalue;
                    if (argn >= 4) {
                        colour = (vector)  llList2String(args, 3);
                        if (argn >= 5) {
                            radius = (float) llList2String(args, 4);
                            if (argn >= 6) {
                                falloff = (float) llList2String(args, 5);
                            }
                        }
                    }
                    shining = intensity > 0;
                    llSetLinkPrimitiveParamsFast(INNER_LIGHT_LINK,
                        [ PRIM_POINT_LIGHT, shining, colour, intensity, radius, falloff ]);
                }

            //  Set trace on/off

            } else if (abbrP(sparam, "tr")) {

            } else {
                tawk("Invalid.  Set flicker/glow");
                return FALSE;
            }

        //  Status

        } else if (abbrP(command, "st")) {
            integer mFree = llGetFreeMemory();
            integer mUsed = llGetUsedMemory();
            tawk(llGetScriptName() + " status:\n" +
                    "  Script memory.  Free: " + (string) mFree +
                    "  Used: " + (string) mUsed + " (" +
                    (string) ((integer) llRound((mUsed * 100.0) / (mUsed + mFree))) + "%)"
            );
            tawk("Flicker: " + eOnOff(flicker) +
                 "  Light: " + eOnOff(lighton) +
                 "  Glow: active " + eff(glowActive) + " idle " + eff(glowIdle));
            list cshine = llGetLinkPrimitiveParams(INNER_LIGHT_LINK,
                [ PRIM_POINT_LIGHT ]);
            tawk("Shine: " +
                 eOnOff(llList2Integer(cshine, 0)) +
                 " intensity " + eff(llList2Float(cshine, 2)) +
                 " colour " +   ef(llList2String(cshine, 1)) +
                 " radius " + eff(llList2Float(cshine, 3)) +
                 " falloff " + eff(llList2Float(cshine, 4)));

        } else {
            tawk("Huh?  \"" + message + "\" undefined.  Chat /" +
                (string) commandChannel + " help for instructions.");
            return FALSE;
        }
        return TRUE;
    }

    //  Initialise / reset notecard processing

    processNotecardInit() {
        ncSource = "";                  // No current notecard
        ncBusy = FALSE;                 // Mark no notecard being read
        ncQueue = [ ];                  // Queue of pending notecards
    }

    //  processNotecardCommands  --  Read and execute commands from a notecard

    processNotecardCommands(string ncname, key id) {
        ncSource = ncname;
        whoDat = id;
        if (llGetInventoryKey(ncSource) == NULL_KEY) {
            tawk("No notecard named " + ncSource);
            return;
        }
        if (ncBusy) {
            ncQueue += ncname;
        } else {
            ncLine = 0;
            ncBusy = TRUE;          // Mark busy reading notecard
            ncQuery = llGetNotecardLine(ncSource, ncLine);
        }
    }

    default {
        on_rez(integer n) {
            llResetScript();
        }

        state_entry() {
            whoDat = owner = llGetOwner();

            processNotecardInit();

            //  If a configuration script is present, run it
            if ((configuring = (llGetInventoryKey(configScript) != NULL_KEY))) {
                processNotecardCommands(configScript, owner);
            }

//  Fix erroneously set texture animation on pumpkin stem
llSetLinkTextureAnim(1, 0, 1, 4, 4, 0, 1, 0.01);
llSetLinkTextureAnim(1, 0, 0, 4, 4, 0, 1, 0.01);
            //  Set the "inner light" sphere flickering like a candle flame
            if (flicker) {
                llSetLinkTextureAnim(INNER_LIGHT_LINK,
                    ANIM_ON | LOOP | PING_PONG, FACE_HEMISPHERE, 4, 4, 0, 16, 8);
            }
            updGlow();
            //  Start poll for typing or speaking
            llSetTimerEvent(0.1);

            //  Start listening on the command chat channel
            commandH = llListen(commandChannel, "", NULL_KEY, "");
            llOwnerSay("Listening on /" + (string) commandChannel);
        }

        //  Attachment to or detachment from an avatar

        attach(key attachedAgent) {
            if (attachedAgent != NULL_KEY) {
                whoDat = attachedAgent;
//llOwnerSay("attach");
          }
        }

        /*  The listen event handler processes messages from
            our chat control channel.  */

        listen(integer channel, string name, key id, string message) {
            processCommand(id, message);
        }

        /*  We use the timer to poll whether the avatar is typing
            or speaking.  Whilst active, the glow from the inner
            light is brightened, then returned to normal when the
            idle state is resumed.  The llGetAgentInfo() function
            appears to set AGENT_TYPING almost immediately the user
            starts to type, but takes a second or so to remove the
            state after the last keystroke, presumably to avoid
            toggling during short pauses during keyboard input.  */

        timer() {
            integer astat = llGetAgentInfo(whoDat);
            if (astat & AGENT_TYPING) {
                if (!typing) {
                    typing = TRUE;
                    updGlow();
                }
            } else {
                if (typing) {
                    typing = FALSE;
                    updGlow();
                }
            }
        }

        //  The dataserver event receives lines from the notecard we're reading

        dataserver(key query_id, string data) {
            if (query_id == ncQuery) {
                if (data == EOF) {
                    if (llGetListLength(ncQueue) > 0) {
                        //  This script is done.  Pop to outer script.
                        ncSource = llList2String(ncQueue, 0);
                        ncQueue = llDeleteSubList(ncQueue, 0, 0);
                        ncLine = 0;
                        ncQuery = llGetNotecardLine(ncSource, ncLine);
                    } else {
                        //  Finished top level script.  We're done/
                        ncBusy = FALSE;         // Mark notecard input idle
                        ncSource = "";
                        ncLine = 0;
                        if (configuring) {
                            configuring = FALSE;
                        }
                    }
                } else {
                    string s = llStringTrim(data, STRING_TRIM);
                    //  Ignore comments and send valid commands to client
                    integer valid = TRUE;
                    if ((llStringLength(s) > 0) && (llGetSubString(s, 0, 0) != "#")) {
                        valid = processCommand(whoDat, s);
                    }
                    if (valid) {
                        //  Fetch next line from notecard
                        ncQuery = llGetNotecardLine(ncSource, ncLine);
                        ncLine++;
                    } else {
                        //  Error in script: abort notecard input
                        processNotecardInit();
                    }
                }
            }
        }
    }
