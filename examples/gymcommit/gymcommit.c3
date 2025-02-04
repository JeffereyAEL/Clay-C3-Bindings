module gymcommit::gc;

import clay;

const ClayColor BLACK = { 0, 0, 0, 255 };
const ClayColor WHITE = { 255, 255, 255, 255 };
const ClayColor ORANGE_FIRE = { 221, 87, 28, 255 };
const ClayColor BLUE_LAPIS_LAZULI = { 62, 105, 147, 255 };
// const ClayColor BLUE_PRUSSIAN = clay::@colorHex(0x233C54);
const ClayColor GRAY_DARK =  { 80, 80, 80, 255 };
const ClayColor GRAY = { 130, 130, 130, 255 };
const ClayColor GRAY_LIGHT = {200, 200, 200, 255};
const ClayColor BEIGE = { 227,212,173, 255 };
const ClayColor PURPLE = {80, 25, 200, 255};
const ClayColor RED = {255, 0, 0, 255};

enum RangeOfMotion
{
    NONE,
    FULL,
    ECCENTRIC,
    CONCENTRIC,
    STATIC
}

enum ExerciseTag : ushort(String name)
{
    NONE      = "_NONE_",
    SHOULDER  = "Shoulder",
    BACK      = "Back",
    CHEST     = "Chest",
    ARM       = "Arm",
    CORE      = "Core",
    LEG       = "Leg",
}

enum ExerciseType : ushort(String name, ExerciseTag tag)
{
    NONE                        = { "_NONE_"                     , ExerciseTag.NONE },
    FACE_PULL                   = { "Face Pull"                  , ExerciseTag.SHOULDER },
    TRAP_SHRUG                  = { "Trap Shrug"                 , ExerciseTag.SHOULDER },
    SHOULDER_INTERNAL_ROTATION  = { "Shoulder Internal Rotation" , ExerciseTag.SHOULDER },
    SHOUDLER_EXTERNAL_ROTATION  = { "Shoulder External Rotation" , ExerciseTag.SHOULDER },
    LATERAL_RAISE               = { "Lateral Raise"              , ExerciseTag.SHOULDER },
    FRONT_RAISE                 = { "Front Raise"                , ExerciseTag.SHOULDER },
    SHOULDER_PRESS              = { "Shoulder Press"             , ExerciseTag.SHOULDER },
    LAT_PULLDOWN                = { "Lat Pulldown"               , ExerciseTag.BACK },
    ROW                         = { "Row"                        , ExerciseTag.BACK },
    HYPEREXTENSION              = { "Hyperextension"             , ExerciseTag.BACK },
    DEADLIFT                    = { "Deadlift"                   , ExerciseTag.BACK },
    CHEST_PRESS                 = { "Chest Press"                , ExerciseTag.CHEST },
    CHEST_FLY                   = { "Chest Fly"                  , ExerciseTag.CHEST },
    BICEP_CURL                  = { "Bicep Curl"                 , ExerciseTag.ARM },
    TRICEP_EXTENSION            = { "Tricep Extension"           , ExerciseTag.ARM },
    FOREARM_CURL                = { "Forearm Curl"               , ExerciseTag.ARM },
    CRUNCH                      = { "Crunch"                     , ExerciseTag.CORE },
    OBLIQUE_CRUNCH              = { "Oblique Crunch"             , ExerciseTag.CORE }, 
    HIP_ABDUCTION               = { "Hip Abduction"              , ExerciseTag.LEG },
    HIP_ADDUCTION               = { "Hip Adduction"              , ExerciseTag.LEG },
    SQUART                      = { "Squat"                      , ExerciseTag.LEG },
    LEG_EXTENSION               = { "Leg Extension"              , ExerciseTag.LEG },
    LEG_CURL                    = { "Leg Curl"                   , ExerciseTag.LEG },
    SPLIT_SQUAT                 = { "Split Squat"                , ExerciseTag.LEG },
    SHIN_CURL                   = { "Shin Curl"                  , ExerciseTag.LEG },
    CALF_EXTENSION              = { "Calf Extension"             , ExerciseTag.LEG },
}

enum Statistic : ushort(String name, String abrvImperial, String abrvMetric)
{
    WEIGHT          = { "Weight"    , "lb"          , "kg" },
    REPS            = { "reps"      , "reps"        , "reps" },
    DISTANCE        = { "distance"  , "mi"          , "km" },
    TIME            = { "time"      , "sec"         , "sec" }
}

enum Feeling : ushort
{
    NONE,
    DECREASE,
    MAINTAIN,
    INCREASE,
    FAILED,
}

struct ExerciseSet 
{
    RangeOfMotion rom;
    Statistic typeA;
    float statisticA;
    Statistic typeB;
    float statisticB;
    Feeling feeling;
}
def ExerciseSetArray = carray::Array(<ExerciseSet>);

struct ExerciseInstance
{
    String description;
    ExerciseType type;
    ExerciseSetArray sets;
}
def ExerciseInstanceArray = carray::Array(<ExerciseInstance>); 

// module gymcommit::gc;

const int FONT_ID_BODY_16 = 0;

def LayoutFunc = fn void() @local;

struct Popup {
    LayoutFunc layout;
}

Popup[] activePopups;

LayoutFunc currentPage = null;