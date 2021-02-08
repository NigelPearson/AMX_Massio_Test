PROGRAM_NAME='Massio_Test'

DEFINE_DEVICE
dvMassioOne = 32222:1:1		// An MCP would be at :28:1 ?

DEFINE_CONSTANT
DEFINE_TYPE
DEFINE_VARIABLE
DEFINE_LATCHING
DEFINE_MUTUALLY_EXCLUSIVE


DEFINE_FUNCTION fnSetBright(DEV dv, integer bar, integer back)
{
    send_command dv,"'@BRT-',itoa(bar),',',itoa(back)"
}

// A bit of fun; first, ramp brightness up and down,
// while jumping bargraph around, before setting sensible brightness

DEFINE_FUNCTION fnMassioInit(DEV dv)
{
    fnSetBright(dv,		32,32)	// Maximum LED brightness
    send_level  dv,1,255		// Max is NOT 256 - that would be 0!
    WAIT 10
    {
	fnSetBright(dv,		24,24)
	send_level  dv,1,35
	WAIT 10
	{
	    fnSetBright(dv,	16,16)	// Half
	    send_level  dv,1,170
	    WAIT 10
	    {
		fnSetBright(dv,   8,8)
		send_level  dv,1,200
		WAIT 10
		{
		    send_level  dv,1,70
		    fnSetBright(dv,22,11)	// 2/3 bargraph, 1/3 buttons
		}
	    }
	}
    }
}

DEFINE_START

// Can't just initialise keypad LEDs here,
// because the device might not be online yet.
// See https://proforums.harman.com/amx/discussion/2774/tell-where-is-the-problem-please
//
// A long WAIT might work, but best to just wait for the ONLINE event.


DEFINE_EVENT

data_event[dvMassioOne] { online: fnMassioInit(dvMassioOne) }



button_event[dvMassioOne,1]	// Flash LEDs once
{
    push:	{}
    release:
    {
	send_command dvMassioOne,"'LED-DIS'"
	WAIT 3
	send_command dvMassioOne,"'LED-EN'"
    }
}

button_event[dvMassioOne,2]	// Flash LEDs twice
{
    push:	{}
    release:
    {
	send_command dvMassioOne,"'LED-DIS'"
	WAIT 3
	{
	    send_command dvMassioOne,"'LED-EN'"
	    WAIT 3
	    {
		send_command dvMassioOne,"'LED-DIS'"
		WAIT 3
		send_command dvMassioOne,"'LED-EN'"
	    }
	}
    }
}


button_event[dvMassioOne,7]
{
    push:	send_command dvMassioOne,"'@BRT-32,32'"
    release:	send_command dvMassioOne,"'@BRT-22,11'"
}

button_event[dvMassioOne,8]
{
    push:	send_command dvMassioOne,"'@BRT-0,0'"
    release:	send_command dvMassioOne,"'@BRT-22,11'"
}


button_event[dvMassioOne,11]	// Mute
{
    push:	send_level   dvMassioOne,1,255
    hold[5]:	send_level   dvMassioOne,1,8
    release:	send_level   dvMassioOne,1,128
}


// These would be one way to control a volume setting variable:

button_event[dvMassioOne,12]
{
    push:	send_string 0, "'+++ Massio dial Increase'"
    release:	{}
}

button_event[dvMassioOne,13]
{
    push:	send_string 0, "'--- Massio dial Decrease'"
    release:	{}
}



// This is an easier way:

level_event[dvMassioOne,2]
{
    stack_var  integer dial

    dial = level.value;
    send_string 0, "'Massio dial value: ', itoa(dial), '/255'"

    send_level   dvMassioOne,1,dial	// Set bargraph to match
}



// If a Massio is plugged into live system, we get these mysterious messages:
//
// (07:41:55.083):: Device [32222:1] is Online
// (07:41:55.084):: Command To [32222:1:1]-[LEVON]
// (07:41:55.084):: Command To [32222:1:1]-[RXON]
// (07:41:55.150):: String Size [32222:1:1] 512 byte(s) Type: 8 bit





DEFINE_PROGRAM

(*****************************************************************)
(*                       END OF PROGRAM                          *)
(*                                                               *)
(*         !!!  DO NOT PUT ANY CODE BELOW THIS COMMENT  !!!      *)
(*                                                               *)
(*****************************************************************)
