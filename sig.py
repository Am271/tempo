import sys,pygame
from pygame.locals import*
FPS = 60
fpsClock = pygame.time.Clock()
pygame.init()

#creating window for game
gameWindow=pygame.display.set_mode((800,600))
pygame.display.set_caption("MINI SPACE INVADERS")

px=400 #x coordinate of player ship
py=520 #y coordinate of player ship
fire = True #flag varible for displaying shooting animation
fx = px; fy = py #initial co-ordinates of the fire(top-centre of ship)
fire_colour = (249, 245, 4) #colour of the fire(yellow)
e = 1
ec = 0

#Loading the images
bg=pygame.image.load('blackbg.png')
ps=pygame.image.load('player.png')
es=pygame.image.load('enemy_ship_3.png')
fire_rect = pygame.Rect(fx, fy, 3, 40) #yellow rectangle to display fire

def drawEnemy(a):
    ix = a + 15; iy = 15
    for i in range(1, 12):
        gameWindow.blit(es,(ix, iy))
        ix += 68

def draw():
    gameWindow.blit(bg,(0,0))   #it gets the image on the game window
    gameWindow.blit(ps,(px,py))

#main game loop
while True:
    for event in pygame.event.get(): #iterating through all the events
        if event.type==QUIT:
            pygame.quit()
            sys.exit()

    keys=pygame.key.get_pressed( )#variable keys will hold the key when we press them

    if fy <= 15:
        #statement to check whether the fire has reached the end of the screen
        #so that the ship can fire again
        fire = True #flag variable is reset to zero so that ship can fire again

    if keys[pygame.K_LEFT]:
        px=px-2#decreases the velocity by 2

    if keys[pygame.K_RIGHT]:
        px=px+2

    if keys[pygame.K_SPACE]:
        fire = False

    draw()
    if e == 1 and ec < 3:
        drawEnemy(ec*10)
        ec += 1
    elif e == 0 and ec >= 0:
        drawEnemy(ec*10)
        ec -= 1
    if ec == 3:
        e = 0
    elif ec == 0:
        e = 1

    if fire: #statement to check whether to fire or not
        fx = px+36
        fy = py
    else: #fire animation starts once the spacebar is pressed
        #animation takes place at the same speed as the rest of the screen renders
        fire_rect = pygame.Rect(fx, fy, 3, 30) #recreation of the object(yellow reactangle)
        pygame.draw.rect(gameWindow, fire_colour, fire_rect) #draw the yellow rectangle
        fy -= 5 #y co-ordinate is updated so that the fire animation appears to move up

    fpsClock.tick(FPS)
    pygame.display.update()   #compulsory statement,makes all the changes visible
