#import "Randomness.h"

@implementation Randomness
   
     +(int) randomInt:(int)min max:(int)max
    {
        return ((rand() % (max-min+1)) + min);
    }
    
    +(float) randomFloat:(float)min max:(float)max
    {
        float number = rand() % (int)((max-min)*1000.0) + min*1000.0;
        return number / 1000.0f;
    }
    
    +(BOOL) randomBool {
        return (rand() % 2);
    }
    
    +(void) initRNG
    {
        //printf("Random number generator initialized\n");
        srand((unsigned)time(NULL));
    }
    
@end

