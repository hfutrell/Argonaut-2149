//
//  WeaponStore.m
//  Argonaut
//
//  Created by Holmes Futrell on Sat Oct 18 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "WeaponStore.h"
#import "GameView.h"

@implementation WeaponStore

-(id)initWithSprite:(GLSprite *)windowSprite bigFont:(GLFont *)bigFont smallFont:(GLFont *)smallFont buttonSprite:(GLSprite *)smallButtonSprite listButtonSprite:(GLSprite *)listButtonSprite view:(GameView *)GLView {

    self = [super initWithFrame: NSMakeRect(128+32,132,496,336)
        sprite: windowSprite];

    theView = GLView;
    
    float baseScale = 2.0;
    smallModel  = [[Model alloc] initWithResource:@"data/models/asteroid/high/asteroid1.obj" scale: baseScale * 1.0/3.0];
    mediumModel = [[Model alloc] initWithResource:@"data/models/asteroid/high/asteroid2.obj"scale: baseScale * 2.0/3.0];
    largeModel  = [[Model alloc] initWithResource:@"data/models/asteroid/high/asteroid3.obj" scale: baseScale];        
    
    [self initAsteroids];
    
    if (![self initWeaponsArray]) return nil;
        
    titleField = [[GLTextField alloc] initWithFrame: NSMakeRect(236,22,0,0)
        font: bigFont
        string:@"KillCo Supplies"];
        
    [titleField alignCenter];
        
    subTitleField = [[GLTextField alloc] initWithFrame: NSMakeRect(236,56,0,0)
        font: smallFont
        string:@"For All Your Destructive Needs"];
        
    int textFieldYBase = 164+16;
    	
    nameField = [[GLTextField alloc] initWithFrame: NSMakeRect(236,textFieldYBase,0,0)
        font: smallFont
        string:@"Title"];
    [self addChild: nameField];
    
    descriptionField = [[GLTextField alloc] initWithFrame: NSMakeRect(236,textFieldYBase+16,0,0)
        font: smallFont
        string:@"Some Weapon"];
    [self addChild: descriptionField];
        
    crystalsField = [[GLTextField alloc] initWithFrame: NSMakeRect(236,textFieldYBase+32,0,0)
        font: smallFont
        string:@"Crystals: A Few"];
    [self addChild: crystalsField];

    costField = [[GLTextField alloc] initWithFrame: NSMakeRect(236,textFieldYBase+48,0,0)
        font: smallFont
        string:@"Cost: A Lot"];
    [self addChild: costField];
    
     playerHasField = [[GLTextField alloc] initWithFrame: NSMakeRect(236,textFieldYBase+64,0,0)
        font: smallFont
        string:@"Player Has"];
    [self addChild: playerHasField];

        
    [subTitleField alignCenter];

    [self addChild: titleField];
    [self addChild: subTitleField];
    
    NSRect newButtonRect = NSMakeRect(0,20,0,0);
    NSRect matrixRect = NSMakeRect(24,24,0,0);    
    weaponsMatrix = [GLMatrix new];
    [self addChild: weaponsMatrix];
    [weaponsMatrix setFrame: matrixRect];
    [weaponsMatrix setSelected:@selector(selectWeapon) target: self];
    //[weaponsMatrix setDeselected:@selector(deselect) target: self];

    unsigned int i;
    for (i=0;i<[weaponsArray count];i++){
        
        newButtonRect.origin.y+=32;
        GLListButton *newButton = [[GLListButton alloc] initWithSprite: listButtonSprite
            rect: newButtonRect
            action: nil
            target:self
            view: (NSOpenGLView *)GLView];
        [newButton setTitleText:  [(NSDictionary *)[weaponsArray objectAtIndex: i] objectForKey:@"name"] font: smallFont];
        [weaponsMatrix addChild: newButton];
		[newButton release];
              
    }
        
    GLPushButton *continueButton = [[GLPushButton alloc] initWithSprite: smallButtonSprite
        rect: NSMakeRect(24,i*30+56+matrixRect.origin.y+32,0,0)
        action:@selector(weaponStoreContinuePushed)
        target:self
        view: (NSOpenGLView *)GLView];
        
    [continueButton setTitleText:@"Continue" font:smallFont];
    [self addChild: continueButton];
    [continueButton release];
	
    saveButton = [[GLPushButton alloc] initWithSprite: smallButtonSprite
                        rect: NSMakeRect(24+128,i*30+56+matrixRect.origin.y+32,0,0)
                        action:@selector(save)
                        target:self
                        view: (NSOpenGLView *)GLView];
    
    [saveButton setTitleText:@"Save" font:smallFont];
    [self addChild: saveButton];
    
    buyButton = [[GLPushButton alloc] initWithSprite: smallButtonSprite
        rect: NSMakeRect(24+128+8+128+64,i*30+56+matrixRect.origin.y+32,0,0)
        action:@selector(buyWeapon)
        target:self
        view: (NSOpenGLView *)GLView];
    [buyButton disable];
        
    [buyButton setTitleText:@"Buy" font:smallFont];
    [self addChild: buyButton];

    [self setShouldDisplay: NO];
    
    stationModel = [[Model alloc] initWithResource:@"data/models/weaponStore/shop.obj" scale: 4.5f];
    stationTexture = [GLTexture initWithResource:@"data/models/weaponStore/killco.jpg"];
    background1 = [GLTexture initWithResource:@"data/backgrounds/space5.jpg"];
    background2 = [GLTexture initWithResource:@"data/backgrounds/space7.jpg"];
        
    return self;

}

-(void)display {
    zoom3 = 0.5f*sin( (3.14 * zoomtime) / (10*60) )-1.0f;
    zoom2 = cos( (3.14 * zoomtime) / (20*60) ); //cosine curve left-right zoom, period = 20 seconds
    zoom = 2.0f*sin( (3.14 * zoomtime) / (10*60) )+5.5f; //sine curve zoom, period = 10 seconds
    float timeSince = [self timeSinceLastRender];
    zoomtime += timeSince; //its technically a GLWindow, so it knows this
    stationrot += timeSince/3.0f;
    displayrot+=timeSince;

    glPushMatrix();
    
        [theView view2D];
        [self drawBackground];
        glClear(GL_DEPTH_BUFFER_BIT);
        [theView view3D];
        
    glPopMatrix();
        
    glPushMatrix();
    
        frustum.CalculateFrustum();
    
        glEnable(GL_LIGHTING);
        glEnable(GL_DEPTH_TEST);
        
        [[Asteroid asteroidTexture] bind];
        int i;
        for (i=0;i<STORE_ASTEROIDS;i++){
            
            asteroid[i]->pos[0]-= 0.03;
            if (frustum.SphereInFrustum(asteroid[i]->pos[0],asteroid[i]->pos[1],asteroid[i]->pos[2],1.0)) {
            
                glPushMatrix();
                
                    glTranslatef(asteroid[i]->pos[0], asteroid[i]->pos[1], asteroid[i]->pos[2]);
                    
					glRotatef(asteroid[i]->rot+=asteroid[i]->rotvel, asteroid[i]->rotaxis[0], asteroid[i]->rotaxis[1], asteroid[i]->rotaxis[2]);
                    [asteroid[i]->model draw];
                                
                glPopMatrix();
                
            }
            else {
                if (asteroid[i]->pos[0] <= 0){
                    [self resetAsteroid: i];
                }
            }
        }
        
        glTranslatef(zoom2,zoom3,-zoom);
        glRotatef(stationrot,0,1,0);
        [stationTexture bind];
        [stationModel draw];
        [theView viewPixel];
    
    glPopMatrix();
        
    //glPopMatrix();
    
    [theView viewPixel];
    
    glPushMatrix();
        glTranslatef([self frame].origin.x+350,[self frame].origin.y+126,100);
        glScalef(5,5,5);
        glRotatef(-30,1,0,0);
        glRotatef(displayrot,0,1,0);
        //glEnable(GL_DEPTH_TEST);
        glDisable(GL_LIGHTING);
        glColor4f(1.0,1.0,1.0,0.5);
        [Powerup drawModelOfID: powerupDrawID];
        glColor4f(1.0,1.0,1.0,1.0);
        glDisable(GL_DEPTH_TEST);
    glPopMatrix();
    
    //glClear(GL_DEPTH_BUFFER_BIT);
    
    [super display];
        
}

-(void)weaponStoreContinuePushed {
    //NSLog(@"Continue Weapon Store");
    [[NSNotificationCenter defaultCenter]
postNotificationName:@"GameShouldUnPause" object: nil];
    [self setShouldDisplay: NO];
}

-(void)save {

    [saveButton disable];
    [[NSNotificationCenter defaultCenter]
postNotificationName:@"GameShouldSave" object: nil];

}

-(void)returnToLevel {
    [[NSNotificationCenter defaultCenter]
postNotificationName:@"GameShouldUnPause" object: nil];
    [self setShouldDisplay: NO];
}

-(void)buyWeapon {

    [saveButton enable];
    int cost = [(NSNumber *)[(NSDictionary *)[weaponsArray objectAtIndex: [weaponsMatrix selectedIndex]] objectForKey:@"cost"] intValue];
    playerShip->crystals -= cost;
    [playerShip gatherPowerupOfType: [(NSDictionary*)[weaponsArray objectAtIndex: [weaponsMatrix selectedIndex]] objectForKey:@"name"]];
    [self selectWeapon];
    
}

-(void)disableSave {
    [saveButton disable];
}

-(void)resetAsteroid:(int)i {
 
    switch( [ Randomness randomInt: 0 max: 9 ] ){
        
        case 0:
            asteroid[i]->model =  largeModel;
            break;
        case 1:
        case 2:
        case 3:
            asteroid[i]->model = mediumModel;
            break;
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
            asteroid[i]->model =  smallModel;
            break;
        default:
        NSLog(@"Error, invalid asteroid selection case");
            break;
            
    }
    if (asteroid[i]->hasBeenReset == YES){
        asteroid[i]->pos[0] = [Randomness randomFloat: 13 max: 14];
    }
    else {
        asteroid[i]->pos[0] = [Randomness randomFloat: 0 max: 26]-13.0f;  
        asteroid[i]->hasBeenReset = YES;
    }
    asteroid[i]->pos[1] = [Randomness randomFloat: 0 max: 7]-3.5f;
    asteroid[i]->pos[2] = -[Randomness randomFloat: 7 max: 20];
    unsigned int j;
    for (j=0;j<3;j++){
        asteroid[i]->rotaxis[j]= [Randomness randomFloat: -1 max: 1];
    }
	asteroid[i]->rotvel = [Randomness randomFloat: 0 max: 1];

    
    
}

//refresh the display of weapon stats
-(void)selectWeapon {

    BOOL canBuy = TRUE;

    int index = [weaponsMatrix selectedIndex];
    powerupDrawID = [Powerup drawIDForType: [(NSDictionary*)[weaponsArray objectAtIndex: [weaponsMatrix selectedIndex]] objectForKey:@"name"]];

    int cost = [[(NSDictionary *)[weaponsArray objectAtIndex: index] objectForKey:@"cost"] intValue];
    int max = [[(NSDictionary *)[weaponsArray objectAtIndex: index] objectForKey:@"max"] intValue];
    NSString *description = [(NSDictionary *)[weaponsArray objectAtIndex: index] objectForKey:@"description"];
    NSString *name = [(NSDictionary *)[weaponsArray objectAtIndex: index] objectForKey:@"name"];
    int playerHas;
    
    [costField setString:[NSString stringWithFormat:@"%@ %d",@"Cost:",cost]];
    [nameField setString:name];
    [descriptionField setString:description];
    [crystalsField setString:[NSString stringWithFormat:@"%@ %d",@"Crystals:",playerShip->crystals]];
    
    if ([name isEqual:@"Shield Charge"]){
        [playerHasField setString:[NSString stringWithFormat:@"%@ (%0.0f / %0.0f)",@"You Have:",playerShip->shields,[playerShip maxShields]]];
        
        if (playerShip->shields >= [playerShip maxShields]) canBuy = FALSE;
    }
    else {
    
        playerHas = [[[playerShip powerups] objectForKey: name] intValue];
        if (playerHas >= max){
            canBuy=FALSE;
        }
        [playerHasField setString:[NSString stringWithFormat:@"%@ ( %d / %d )",@"You Have: ",playerHas,max]];
        
    }
    
    //don't allow the player to purchase item if the cost is more crystals than he has, or he
    //is ineligable (canBuy) for some reason (ie shields full and wants more shields)
    if (playerShip->crystals >= cost && canBuy == TRUE){
        [buyButton enable];
    }
    else {
        [buyButton disable];
    }
}

//when no weapon is selected, display humourous message
-(void)deselect {

    [nameField setString:@"Welcome To KillCo!"];
    [descriptionField setString:@"If we don't have it,"];
    [crystalsField setString:@"It don't kill stuff."];
    [costField setString: @""];
    [playerHasField setString:@"-KillCo staff"];
    [weaponsMatrix deselect];

}

//Opens the weapon store window
-(void)openWithShip:(Ship *)ship {
    playerShip = ship;
    [saveButton enable];
    //[[NSNotificationCenter defaultCenter]
//postNotificationName:@"GameShouldPause" object: nil];
    [self setShouldDisplay: YES];
    [self deselect];
    [self center: NSMakePoint(horizontalResolution,verticalResolution)];
}

-(void)setShouldDisplay:(BOOL)state {
 
    [super setShouldDisplay: state];
    if (state){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestShowCursor" object: self];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestHideCursor" object: self];
    }
    
}

//init the array of availible items from the weapons.txt file
-(BOOL)initWeaponsArray {

    char oneline[80];
    //NSLog(@"Initializing weapons array");
    NSString *filePath =  [ NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"data/Weapons.txt" ];
    if ([[NSFileManager defaultManager] fileExistsAtPath: filePath]){

        weaponsArray = [NSMutableArray new];
        FILE *filein = fopen([filePath fileSystemRepresentation], "rt");
        while (!feof(filein)) {
            fgets(oneline, 80, filein);
            if (strncmp(oneline,"<New Powerup>",13)==0) { //if strings are equal
            
                //NSLog(@"ooh, new powerup");
                char nameString[80];
                char descriptionString[80];
                int cost;
                int max;
                
                fgets(nameString, 80, filein);
                [self removeEndLine: nameString];
                fgets(descriptionString, 80, filein);
                [self removeEndLine: descriptionString];
                fgets(oneline, 80, filein);
                sscanf(oneline, "%d", &cost);
                fgets(oneline, 80, filein);
                sscanf(oneline, "%d", &max);
                
                NSString *name = [NSString stringWithCString: nameString];
                NSString *description = [NSString stringWithCString: descriptionString];
                NSNumber *weaponCost = [NSNumber numberWithInt: cost];
                NSNumber *weaponMax = [NSNumber numberWithInt: max];
                
                NSMutableDictionary *newWeaponDict = [[NSMutableDictionary alloc] init];
                [newWeaponDict setObject: name forKey:@"name"];
                [newWeaponDict setObject: description forKey:@"description"];
                [newWeaponDict setObject: weaponCost forKey:@"cost"];
                [newWeaponDict setObject: weaponMax forKey:@"max"];
                [weaponsArray addObject: newWeaponDict];
				[newWeaponDict release];
            }
        }
        
        return TRUE;
    }
    
    NSLog(@"Couldn't find weapons file %@", filePath);
    return FALSE;

}

-(void)dealloc {

    [smallModel release];
    [mediumModel release];
    [largeModel release];
    [weaponsArray release];
    [stationModel release];
    [stationTexture release];
    [background1 release];
    [background2 release];
	
	[nameField release];
	[descriptionField release];
	[crystalsField release];
	[costField release];
	[playerHasField release];
	[titleField release];
	[subTitleField release];
	[weaponsMatrix release];
	[saveButton release];
	[buyButton release];
	
    int i;
    for (i=0;i<STORE_ASTEROIDS;i++){        
        free(asteroid[i]);
    }
    [super dealloc];

}

//for use with sscanf, since the function unfortunately leaves the \n characters on the ends of my strings
-(void)removeEndLine:(char *)string {
    
    unsigned int i;
    for (i=0;i<strlen(string);i++){
        if (string[i] == '\n'){
            string[i] = '\0';
        }
    }
}

//draws the neat scrolling background
-(void)drawBackground {
    
    scroll[0]+=0.5f;
    scroll[1]+=0.05f;
    
    glPushMatrix();
    
        glDisable(GL_LIGHTING);
        glTranslatef(0,0,-900);
        [background1 bind];
        
        glBegin(GL_QUADS);
        
            //top left
            glTexCoord2f(scroll[0]/2400,scroll[1]/1800);
            glVertex2d(0,0);
            glTexCoord2f((scroll[0]/2400)+1,scroll[1]/1800);
            glVertex2d(800,0);
            glTexCoord2f((scroll[0]/2400)+1,(scroll[1]/1800)+1);
            glVertex2d(800,600);
            glTexCoord2f((scroll[0]/2400),(scroll[1]/1800)+1);
            glVertex2d(0,600);
        
        glEnd();
        
        [background2 bind];
        
        glBlendFunc(GL_SRC_ALPHA, GL_ONE);  
        
        glBegin(GL_QUADS);
        
            //top left
            glTexCoord2f(scroll[0]/800,scroll[1]/600);
            glVertex2d(0,0);
            glTexCoord2f((scroll[0]/800)+1,scroll[1]/600);
            glVertex2d(800,0);
            glTexCoord2f((scroll[0]/800)+1,(scroll[1]/600)+1);
            glVertex2d(800,600);
            glTexCoord2f((scroll[0]/800),(scroll[1]/600)+1);
            glVertex2d(0,600);
        
        glEnd();
        
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glPopMatrix();
    
    //glEnable(GL_LIGHTING);
}

-(void)initAsteroids {
 
    unsigned int i;
    for (i=0;i<STORE_ASTEROIDS;i++){
        
        asteroid[i] = (StoreAsteroid *)malloc(sizeof(StoreAsteroid));
        [self resetAsteroid: i];

    }
}

@end
