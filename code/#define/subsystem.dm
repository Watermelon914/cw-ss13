// Subsystem defines.
// All in one file so it's easier to see what everything is relative to.

#define SS_INIT_TICKER_SPAWN       999
#define SS_INIT_RUST               26
#define SS_INIT_SUPPLY_SHUTTLE     25
#define SS_INIT_SUN                24
#define SS_INIT_GARBAGE            23
#define SS_INIT_JOB                22
#define SS_INIT_PLANT              21.5
#define SS_INIT_HUMANS             21
#define SS_INIT_MAP                20
#define SS_INIT_COMPONENT          19.5
#define SS_INIT_POWER              19
#define SS_INIT_OBJECT             18
#define SS_INIT_PIPENET            17.5
#define SS_INIT_XENOARCH           17
#define SS_INIT_MORE_INIT          16
#define SS_INIT_AIR                15
#define SS_INIT_SHUTTLE            14
#define SS_INIT_LIGHTING           13
#define SS_INIT_LANDMARK           11
#define SS_INIT_MAPVIEW            10
#define SS_INIT_DEFCON             9
#define SS_INIT_UNSPECIFIED        0
#define SS_INIT_EMERGENCY_SHUTTLE -19
#define SS_INIT_ASSETS            -20
#define SS_INIT_TICKER            -21
#define SS_INIT_FINISH            -22
#define SS_INIT_MINIMAP           -23
#define SS_INIT_ADMIN             -24


#define SS_PRIORITY_TICKER         200
#define SS_PRIORITY_MAPVIEW		   170
#define SS_PRIORITY_MOB            150
#define SS_PRIORITY_XENO           149
#define SS_PRIORITY_HUMAN          148
#define SS_PRIORITY_COMPONENT      125
#define SS_PRIORITY_NANOUI         120
#define SS_PRIORITY_VOTE           110
#define SS_PRIORITY_FAST_OBJECTS   105
#define SS_PRIORITY_OBJECTS        100
#define SS_PRIORITY_POWER          95
#define SS_PRIORITY_MACHINERY      90
#define SS_PRIORITY_PIPENET        85
#define SS_PRIORITY_SHUTTLE        80
#define SS_PRIORITY_AIR            70
#define SS_PRIORITY_EVENT          65
#define SS_PRIORITY_DISEASE        60
#define SS_PRIORITY_FAST_MACHINERY 55
#define SS_PRIORITY_DEFCON         35
#define SS_PRIORITY_UNSPECIFIED    30
#define SS_PRIORITY_LIGHTING       20
#define SS_PRIORITY_SUN            3
#define SS_PRIORITY_GARBAGE        2
#define SS_PRIORITY_INACTIVITY     1
#define SS_PRIORITY_ADMIN          0


#define SS_WAIT_MACHINERY           3.5 SECONDS //TODO move the rest of these to defines
#define SS_WAIT_FAST_MACHINERY      0.7 SECONDS
#define SS_WAIT_FAST_OBJECTS        0.5 SECONDS
#define SS_WAIT_ADMIN               5 MINUTES

#define SS_DISPLAY_GARBAGE        -100
#define SS_DISPLAY_AIR            -90
#define SS_DISPLAY_LIGHTING       -80
#define SS_DISPLAY_MOB            -72
#define SS_DISPLAY_HUMAN          -71
#define SS_DISPLAY_XENO           -70
#define SS_DISPLAY_COMPONENT      -69
#define SS_DISPLAY_FAST_OBJECTS   -65
#define SS_DISPLAY_OBJECTS        -60
#define SS_DISPLAY_MACHINERY      -50
#define SS_DISPLAY_PIPENET        -40
#define SS_DISPLAY_FAST_MACHINERY -30
#define SS_DISPLAY_SHUTTLES       -25
#define SS_DISPLAY_POWER          -20
#define SS_DISPLAY_TICKER         -10
#define SS_DISPLAY_UNSPECIFIED     0
#define SS_DISPLAY_SUN             10
#define SS_DISPLAY_ADMIN           20