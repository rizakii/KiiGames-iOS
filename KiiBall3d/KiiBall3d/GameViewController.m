//
//  GameViewController.m
//  KiiBall3d
//
//  Created by Syah Riza on 7/16/14.
//  Copyright (c) 2014 Kii. All rights reserved.
//

#import "GameViewController.h"

@implementation GameViewController
- (SCNNode *)loadNodeWithName:(NSString *)name fromSceneNamed:(NSString *)path
{
    // Load the scene from the specified file
    SCNScene *scene = [SCNScene sceneNamed:path
                               inDirectory:nil
                                   options:@{SCNSceneSourceConvertToYUpKey : @YES,
                                             SCNSceneSourceAnimationImportPolicyKey :SCNSceneSourceAnimationImportPolicyPlayRepeatedly}];
    
    // Retrieve the root node
    SCNNode *node = scene.rootNode;
    
    // Search for the node named "name"
    if (name) {
        node = [node childNodeWithName:name recursively:YES];
    } else {
        node = node.childNodes[0];
    }
    
    return node;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    NSString* hotelPath = @"hotel.scnassets/models/hotel.dae";
    
    
    // create a new scene
    SCNScene *scene = [SCNScene scene];

    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    [scene.rootNode addChildNode:cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, 0, 3);
    
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, 10, 10);
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor darkGrayColor];
    [scene.rootNode addChildNode:ambientLightNode];
    SCNScene *carScene = [SCNScene sceneNamed:@"rc_car"];
    SCNNode *chassisNode = [carScene.rootNode childNodeWithName:@"rccarBody" recursively:NO];
    
    // setup the chassis
    chassisNode.position = SCNVector3Make(0, -1, 1);
    chassisNode.rotation = SCNVector4Make(0, M_PI*0.7, 0, M_PI);
    chassisNode.scale = SCNVector3Make(0.1, 0.1, 0.1);
    
    [scene.rootNode addChildNode:chassisNode];

    // create and add a 3d box to the scene
    SCNNode *boxNode = [SCNNode node];
    boxNode.geometry = [SCNBox boxWithWidth:0.3 height:0.3 length:0.3 chamferRadius:0.02];
    [scene.rootNode addChildNode:boxNode];
    
    //create ball node
    SCNNode *ballNode = [SCNNode node];
    ballNode.geometry = [SCNSphere sphereWithRadius:0.5];
    ballNode.position = SCNVector3Make(0, 1, 0);
    [scene.rootNode addChildNode:ballNode];
    
    // create and configure a material
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [UIImage imageNamed:@"texture"];
    material.specular.contents = [UIColor grayColor];
    material.locksAmbientWithDiffuse = YES;
    
    // set the material to the 3d object geometry
    boxNode.geometry.firstMaterial = material;
    
    SCNMaterial *materialBall = [material copy];
    materialBall.multiply.contents = [UIColor redColor];
    ballNode.geometry.firstMaterial = materialBall;
    
    // animate the 3d object
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(1, 1, 0, M_PI*2)];
    animation.duration = 5;
    animation.repeatCount = MAXFLOAT; //repeat forever
    [boxNode addAnimation:animation forKey:nil];
    
    
    //add particle
    SCNParticleSystem *fire = [SCNParticleSystem particleSystemNamed:@"FireParticle" inDirectory:nil];
    
    [chassisNode addParticleSystem:fire];
    
    
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // set the scene to the view
    scnView.scene = scene;
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = YES;
        
    // show statistics such as fps and timing information
    scnView.showsStatistics = YES;

    // configure the view
    scnView.backgroundColor = [UIColor blackColor];
    
    // add a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:tapGesture];
    [gestureRecognizers addObjectsFromArray:scnView.gestureRecognizers];
    scnView.gestureRecognizers = gestureRecognizers;
}

- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // check what nodes are tapped
    CGPoint p = [gestureRecognize locationInView:scnView];
    NSArray *hitResults = [scnView hitTest:p options:nil];
    
    // check that we clicked on at least one object
    if([hitResults count] > 0){
        // retrieved the first clicked object
        SCNHitTestResult *result = [hitResults objectAtIndex:0];
        
        // get its material
        SCNMaterial *material = result.node.geometry.firstMaterial;
        
        // highlight it
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.5];
        
        // on completion - unhighlight
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            material.emission.contents = [UIColor blackColor];
            
            [SCNTransaction commit];
        }];
        
        material.emission.contents = [UIColor redColor];
        
        [SCNTransaction commit];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
