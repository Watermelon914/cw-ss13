#define XENO_HIVE_EVOLUTION_FREETIME 3000 // 5 minutes of free evolution

#define TUNNEL_MOVEMENT_XENO_DELAY 20
#define TUNNEL_MOVEMENT_BIG_XENO_DELAY 60
#define TUNNEL_MOVEMENT_LARVA_DELAY 5

#define TUNNEL_ENTER_XENO_DELAY 40
#define TUNNEL_ENTER_BIG_XENO_DELAY 120
#define TUNNEL_ENTER_LARVA_DELAY 10

#define RESIN_WALL 1
#define RESIN_DOOR 2
#define RESIN_MEMBRANE 4
#define RESIN_NEST 8
#define RESIN_STICKY 16
#define RESIN_FAST 32

#define XENO_ACTION_CLICK  0 // Just select the action (base). Toggles can use this too
#define XENO_ACTION_ACTIVATE 1 // Actually use the action SHOULD ONLY BE USED ON ACTIVABLE ACTIONS OR ELSE WILL NOT WORK
#define XENO_ACTION_QUEUE 2 // Tell the action handler to queue the action for next click

#define XENO_MAXOVERHEAL_OF_MAXHEALTH 0.9 //Determines the max overheal of xenos, based on a procentage of max health.
#define XENO_ENEMIES_FOR_MAXOVERHEAL 6 //Amount of enemies required to get max overheal

#define HUD_PAIN_STATES_XENO   4
#define HUD_HEALTH_STATES_XENO 16
#define HUD_PLASMA_STATES_XENO 16
#define HUD_ARMOR_STATES_XENO  10

#define BUILD_TIME_XENO		20 //time taken for a xeno to place down a resin structure
#define BUILD_TIME_HIVELORD	10
#define NORMAL_XENO             0
#define XENO_QUEEN              1
#define XENO_LEADER_HIVE_POS(X)          (X + 1)
#define GET_XENO_LEADER_NUM(X)  (X.hive_pos - 1)
#define IS_XENO_LEADER(X)       (X.hive_pos > 1)

#define XENO_HIVE_AREA_SIZE 21 //The turf size from the centrepiece of a hive in which special things can be done (like building structures)

#define	EGG_BURST     0
#define	EGG_BURSTING  1
#define	EGG_GROWING   2
#define	EGG_GROWN     3
#define	EGG_DESTROYED 4

#define	EGG_MIN_GROWTH_TIME 100 //time it takes for the egg to mature once planted
#define	EGG_MAX_GROWTH_TIME 150

// Holds defines for /datum/caste_datum, which is the primary datum for the caste system,
// /datum/hive_status (self explanatory)
// and some of the var defines for the Xenomorph base type.

// Holds defines relevant to overall xeno balance

// Stopgap usage only. Use to unilaterally buff every Xenomorph.
// WARNING: These can fuck the entire game
#define XENO_UNIVERSAL_HPMULT 1.0		// Use to unilaterally buff every caste's total HP.
#define XENO_UNIVERSAL_PLASMAMULT 1.0	// Use to unilaterally buff every caste's total PLASMA.
#define XENO_UNIVERSAL_DAMAGEMULT 1.0	// Use to unilaterally buff every caste's DAMAGE.


/////////////////////////////////////////////////////////////////////////////////////
//
//	Stat Baselines
//
// These provide the values for caste that everything is built on/scaled off of.
//
/////////////////////////////////////////////////////////////////////////////////////

// Armor levels
#define XENO_NO_ARMOR 0
#define XENO_LOW_ARMOR 20
#define XENO_LOWMED_ARMOR 25
#define XENO_MEDIUM_ARMOR 30
#define XENO_HEAVY_ARMOR 40
#define XENO_ULTRA_ARMOR 50

// Explosive armor (think explosion resistance)
#define XENO_NO_EXPLOSIVE_ARMOR 0
#define XENO_LOW_EXPLOSIVE_ARMOR 10
#define XENO_MEDIUM_EXPLOSIVE_ARMOR 20
#define XENO_HEAVY_EXPLOSIVE_ARMOR 40
#define XENO_LOWULTRA_EXPLOSIVE_ARMOR 50
#define XENO_ULTRA_EXPLOSIVE_ARMOR 60
#define XENO_GIGA_EXPLOSIVE_ARMOR 100

// Health bands
#define XENO_HEALTH_LARVA 35 * XENO_UNIVERSAL_HPMULT
#define XENO_HEALTH_VERYLOW 200 * XENO_UNIVERSAL_HPMULT
#define XENO_HEALTH_LOW 225 * XENO_UNIVERSAL_HPMULT
#define XENO_HEALTH_LOWMEDIUM 250 * XENO_UNIVERSAL_HPMULT
#define XENO_HEALTH_MEDIUM 275 * XENO_UNIVERSAL_HPMULT
#define XENO_HEALTH_HIGHMEDIUM 325 * XENO_UNIVERSAL_HPMULT
#define XENO_HEALTH_LOWHIGH 400 * XENO_UNIVERSAL_HPMULT
#define XENO_HEALTH_HIGH 450 * XENO_UNIVERSAL_HPMULT
#define XENO_HEALTH_VERYHIGH 525 * XENO_UNIVERSAL_HPMULT
#define XENO_HEALTH_ULTRAHIGH 750 * XENO_UNIVERSAL_HPMULT
#define XENO_HEALTH_IMMORTAL 1200 * XENO_UNIVERSAL_HPMULT

// Plasma bands
#define XENO_PLASMA_LOW 100 * XENO_UNIVERSAL_PLASMAMULT
#define XENO_PLASMA_LOWMEDIUM 150 * XENO_UNIVERSAL_PLASMAMULT
#define XENO_PLASMA_MEDIUM 200 * XENO_UNIVERSAL_PLASMAMULT
#define XENO_PLASMA_HIGHMEDIUM 300 * XENO_UNIVERSAL_PLASMAMULT
#define XENO_PLASMA_HIGH 500 * XENO_UNIVERSAL_PLASMAMULT
#define XENO_PLASMA_VERYHIGH 800 * XENO_UNIVERSAL_PLASMAMULT
#define XENO_PLASMA_ULTRAHIGH 1000 * XENO_UNIVERSAL_PLASMAMULT

// Plasma gain bands
#define XENO_PLASMA_GAIN_LOW 1
#define XENO_PLASMA_GAIN_LOWMED 2
#define XENO_PLASMA_GAIN_MED 2.5
#define XENO_PLASMA_GAIN_HIGHMED 3
#define XENO_PLASMA_GAIN_HIGH 3.5
#define XENO_PLASMA_GAIN_VERYHIGH 4
#define XENO_PLASMA_GAIN_ULTRAHIGH 5

// Armor factor
#define XENO_ARMOR_FACTOR_LOW 25
#define XENO_ARMOR_FACTOR_MEDIUM 30
#define XENO_ARMOR_FACTOR_HIGH 35
#define XENO_ARMOR_FACTOR_VERYHIGH 40

// Evasion
#define XENO_EVASION_NONE 0
#define XENO_EVASION_LOW 10
#define XENO_EVASION_MEDIUM 15
#define XENO_EVASION_HIGH 20

// Speeds
#define XENO_SPEED_SLOW 0.7
#define XENO_SPEED_MEDIUM 0.3
#define XENO_SPEED_MEDHIGH -0.2
#define XENO_SPEED_LOWHIGH -0.4
#define XENO_SPEED_HIGH -0.5
#define XENO_SPEED_HIGHFAST -0.8
#define XENO_SPEED_FAST -1.6
#define XENO_SPEED_SANICFAST -1.9

// Xeno damage categories
#define XENO_DAMAGE_WEAK 10 * XENO_UNIVERSAL_DAMAGEMULT
#define XENO_DAMAGE_LOW 20 * XENO_UNIVERSAL_DAMAGEMULT
#define XENO_DAMAGE_LOWPLUS 25 * XENO_UNIVERSAL_DAMAGEMULT
#define XENO_DAMAGE_MEDIUMLOW 30 * XENO_UNIVERSAL_DAMAGEMULT
#define XENO_DAMAGE_MEDIUM 35 * XENO_UNIVERSAL_DAMAGEMULT
#define XENO_DAMAGE_MEDIUMHIGH 40 * XENO_UNIVERSAL_DAMAGEMULT
#define XENO_DAMAGE_HIGH 50 * XENO_UNIVERSAL_DAMAGEMULT
#define XENO_DAMAGE_VERYHIGH 75 * XENO_UNIVERSAL_DAMAGEMULT
#define XENO_DAMAGE_ULTRAHIGH 100 * XENO_UNIVERSAL_DAMAGEMULT


/////////////////////////////////////////////////////////////////////////////////////
//
//	Modifiers
//
// These below are used in the Xeno strain system to increase and decrease certain stats by strain
// USE THESE WITH SIGNS - postive will be ADDED, negative will be SUBTRACTED from the Xeno's
// previous stat. Bear in mind that the signs mean different things for different values.
//
/////////////////////////////////////////////////////////////////////////////////////

// Damage - this is applied as a flat nerf/buff to the xeno's average damage
#define XENO_DAMAGE_MOD_VERYSMALL  5
#define XENO_DAMAGE_MOD_SMALL      10
#define XENO_DAMAGE_MOD_MED        15
#define XENO_DAMAGE_MOD_LARGE      20
#define XENO_DAMAGE_MOD_VERYLARGE  25

// Overall health pool
#define XENO_HEALTH_MOD_VERYSMALL  20
#define XENO_HEALTH_MOD_SMALL      40
#define XENO_HEALTH_MOD_MED        60
#define XENO_HEALTH_MOD_LARGE      80
#define XENO_HEALTH_MOD_VERYLARGE  100

// Armor mods. Use the above defines for some guidance
// In general, +20 armor should be a little more than +20% effective HP, however,
// the higher the Xeno's base armor, the greater the effect.
#define XENO_ARMOR_MOD_VERYSMALL  5
#define XENO_ARMOR_MOD_SMALL      10
#define XENO_ARMOR_MOD_MED        15
#define XENO_ARMOR_MOD_LARGE      20
#define XENO_ARMOR_MOD_VERYLARGE  25

#define XENO_EXPOSIVEARMOR_MOD_VERYSMALL  10
#define XENO_EXPOSIVEARMOR_MOD_SMALL      20
#define XENO_EXPOSIVEARMOR_MOD_MED        30
#define XENO_EXPOSIVEARMOR_MOD_LARGE      40
#define XENO_EXPOSIVEARMOR_MOD_VERYLARGE  50

// Plasma
#define XENO_PLASMAPOOL_MOD_VERYSMALL  20
#define XENO_PLASMAPOOL_MOD_SMALL      40
#define XENO_PLASMAPOOL_MOD_MED        60
#define XENO_PLASMAPOOL_MOD_LARGE      80
#define XENO_PLASMAPOOL_MOD_VERYLARGE  100

// Plasma regen
#define XENO_PLASMAGAIN_MOD_SMALL 0.1
#define XENO_PLASMAGAIN_MOD_MED   0.2
#define XENO_PLASMAGAIN_MOD_LARGE 0.3

// Speed mods (these will be rolled into the xeno's total speed)
#define XENO_SPEED_MOD_SMALL      0.05
#define XENO_SPEED_MOD_MED        0.09
#define XENO_SPEED_MOD_LARGE      0.1
#define XENO_SPEED_MOD_VERYLARGE  0.25
#define XENO_SPEED_MOD_LOWULTRA	  0.375
#define XENO_SPEED_MOD_ULTRA	  0.5

// Pheremone strength modifiers
#define XENO_PHERO_MOD_VERYSMALL  0.25
#define XENO_PHERO_MOD_SMALL      0.5
#define XENO_PHERO_MOD_MED        0.75
#define XENO_PHERO_MOD_LARGE      1.0
#define XENO_PHERO_MOD_VERYLARGE  1.25

// Evasion modifiers
#define XENO_EVASION_MOD_VERYSMALL 	3
#define XENO_EVASION_MOD_SMALL	   	6
#define XENO_EVASION_MOD_MED  	   	9
#define XENO_EVASION_MOD_LARGE   	12
#define XENO_EVASION_MOD_VERYLARGE	15
#define XENO_EVASION_MOD_ULTRA		25

// Armor factor modifiers
#define XENO_ARMORFACTOR_MOD_VERYSMALL	5
#define XENO_ARMORFACTOR_MOD_SMALL		10
#define XENO_ARMORFACTOR_MOD_MED		15
#define XENO_ARMORFACTOR_MOD_LARGE		20
#define XENO_ARMORFACTOR_MOD_VERYLARGE 	25

// Acid boost (I guess, this is used literally nowhere)
// Feel free to add more defines here if it ever becomes relevant
#define XENO_ACID_MOD_BOOST	1

// Weed boost (same as above)
#define XENO_WEED_BOOST 1

/////////////////////////////////////////////////////////////////////////////////////
//
//	Default scaling values
//
// In the abscence of a scalar (documented below) these values are what are used
// to scale xeno stats by age.
//
/////////////////////////////////////////////////////////////////////////////////////

#define XENO_MULTIPLIER_HEALTH_YOUNG 1.0 //Resolve this line once structures are resolved. Was 0.6.
#define XENO_MULTIPLIER_HEALTH_MATURE 1.25
#define XENO_MULTIPLIER_HEALTH_ELDER 1.4
#define XENO_MULTIPLIER_HEALTH_ANCIENT 1.5
#define XENO_MULTIPLIER_HEALTH_PRIMORDIAL 1.75

#define XENO_MULTIPLIER_DAMAGE_YOUNG 1.0
#define XENO_MULTIPLIER_DAMAGE_MATURE 1.2
#define XENO_MULTIPLIER_DAMAGE_ELDER 1.3
#define XENO_MULTIPLIER_DAMAGE_ANCIENT 1.35
#define XENO_MULTIPLIER_DAMAGE_PRIMORDIAL 1.45

#define XENO_MULTIPLIER_PLASMA_YOUNG 1.0
#define XENO_MULTIPLIER_PLASMA_MATURE 1.25
#define XENO_MULTIPLIER_PLASMA_ELDER 1.5
#define XENO_MULTIPLIER_PLASMA_ANCIENT 2.0
#define XENO_MULTIPLIER_PLASMA_PRIMORDIAL 2.25

#define XENO_MULTIPLIER_PLASMA_GAIN_YOUNG 1.0
#define XENO_MULTIPLIER_PLASMA_GAIN_MATURE 1.2
#define XENO_MULTIPLIER_PLASMA_GAIN_ELDER 1.4
#define XENO_MULTIPLIER_PLASMA_GAIN_ANCIENT 1.6
#define XENO_MULTIPLIER_PLASMA_GAIN_PRIMORDIAL 1.8

#define XENO_MULTIPLIER_ARMOR_FACTOR_YOUNG 1.0 //Resolve this line once structures are resolved. Was 0.6.
#define XENO_MULTIPLIER_ARMOR_FACTOR_MATURE 1.1
#define XENO_MULTIPLIER_ARMOR_FACTOR_ELDER 1.15
#define XENO_MULTIPLIER_ARMOR_FACTOR_ANCIENT 1.20
#define XENO_MULTIPLIER_ARMOR_FACTOR_PRIMORDIAL 1.30

#define XENO_MULTIPLIER_EVASION_YOUNG 1.0 //Resolve this line once structures are resolved. Was 0.6.
#define XENO_MULTIPLIER_EVASION_MATURE 1.10
#define XENO_MULTIPLIER_EVASION_ELDER 1.15
#define XENO_MULTIPLIER_EVASION_ANCIENT 1.20
#define XENO_MULTIPLIER_EVASION_PRIMORDIAL 1.3

/////////////////////////////////////////////////////////////////////////////////////////////
//
//	Scalars
//
// These are used to adjust caste scaling. Define in them in the caste datum definitions
// for each age to override the default. Bear in mind that these scale from the base caste
// values; they are NOT multiplicative. The actual variables for doing that are down below.
//
/////////////////////////////////////////////////////////////////////////////////////////////

#define XENO_SCALAR_HEALTH_NONE				1.0
#define XENO_SCALAR_HEALTH_LOW  			1.1
#define XENO_SCALAR_HEALTH_LOWMED			1.15
#define XENO_SCALAR_HEALTH_MED				1.2
#define XENO_SCALAR_HEALTH_MEDHIGH			1.25
#define XENO_SCALAR_HEALTH_HIGH				1.3
#define XENO_SCALAR_HEALTH_VERYHIGH			1.35
#define XENO_SCALAR_HEALTH_ULTRAHIGH		1.4
#define XENO_SCALAR_HEALTH_IMMORTAL			1.5
#define XENO_SCALAR_HEALTH_OHLAWD			1.7

#define XENO_SCALAR_DAMAGE_NONE				1.0
#define XENO_SCALAR_DAMAGE_LOW  			1.1
#define XENO_SCALAR_DAMAGE_MED				1.2
#define XENO_SCALAR_DAMAGE_HIGH				1.3
#define XENO_SCALAR_DAMAGE_VERYHIGH			1.4
#define XENO_SCALAR_DAMAGE_ULTRAHIGH		1.5

#define XENO_SCALAR_PLASMA_NONE				1.0
#define XENO_SCALAR_PLASMA_LOW  			1.25
#define XENO_SCALAR_PLASMA_MED				1.5
#define XENO_SCALAR_PLASMA_HIGH				1.75
#define XENO_SCALAR_PLASMA_VERYHIGH			2.0
#define XENO_SCALAR_PLASMA_ULTRAHIGH		2.25

#define XENO_SCALAR_PLASMA_GAIN_NONE		1.0
#define XENO_SCALAR_PLASMA_GAIN_LOW  		1.15
#define XENO_SCALAR_PLASMA_GAIN_MED			1.3
#define XENO_SCALAR_PLASMA_GAIN_HIGH		1.45
#define XENO_SCALAR_PLASMA_GAIN_VERYHIGH	1.6
#define XENO_SCALAR_PLASMA_GAIN_ULTRAHIGH	1.75

#define XENO_SCALAR_ARMORFACTOR_NONE		1.0
#define XENO_SCALAR_ARMORFACTOR_LOW  		1.05
#define XENO_SCALAR_ARMORFACTOR_MED			1.1
#define XENO_SCALAR_ARMORFACTOR_HIGH		1.15
#define XENO_SCALAR_ARMORFACTOR_VERYHIGH	1.20
#define XENO_SCALAR_ARMORFACTOR_ULTRAHIGH	1.25

#define XENO_SCALAR_EVASION_NONE			1.0
#define XENO_SCALAR_EVASION_LOW  			1.05
#define XENO_SCALAR_EVASION_MED				1.1
#define XENO_SCALAR_EVASION_HIGH			1.15
#define XENO_SCALAR_EVASION_VERYHIGH		1.20
#define XENO_SCALAR_EVASION_ULTRAHIGH		1.25

#define XENO_STRUCTURE_BUILD_TIME           50

#define XENO_STRUCTURE_POOL                 "spawn pool"
#define XENO_STRUCTURE_EGGMORPH             "egg morpher"
#define XENO_STRUCTURE_EVOPOD               "evolution pod"

#define RESIN_TRAP_EMPTY 0
#define RESIN_TRAP_HUGGER 1
#define RESIN_TRAP_GAS 2
#define RESIN_TRAP_ACID1 3
#define RESIN_TRAP_ACID2 4
#define RESIN_TRAP_ACID3 5

// Caste name defines
#define CASTE_LARVA "Larva"

#define CASTE_RUNNER "Runner"
#define CASTE_LURKER "Lurker"
#define CASTE_RAVAGER "Ravager"

#define CASTE_SENTINEL "Sentinel"
#define CASTE_SPITTER "Spitter"
#define CASTE_BOILER "Boiler"

#define CASTE_DEFENDER "Defender"
#define CASTE_WARRIOR "Warrior"
#define CASTE_CRUSHER "Crusher"
#define CASTE_PRAETORIAN "Praetorian"

#define CASTE_DRONE "Drone"
#define CASTE_HIVELORD "Hivelord"
#define CASTE_CARRIER "Carrier"
#define CASTE_BURROWER "Burrower"

#define CASTE_QUEEN "Queen"