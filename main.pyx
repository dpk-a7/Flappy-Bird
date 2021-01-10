# -*- coding: utf-8 -*-
"""
Created on Wed Jan  6 13:47:13 2021

@author: Deepak Avudiappan
"""
import pygame
import random
import sys
from pygame.locals import *

fps = 32
screenW = 289
screenH = 511
screen = pygame.display.set_mode((screenW,screenH))
groundY = screenH * 0.8
gameSprites = {}
gameAudios = {}
player = 'gallery/sprites/bird.png'
background = 'gallery/sprites/background.png'
pipe = 'gallery/sprites/pipe.png'


def welcomeScreen():
    playerX = int(screenW / 5)
    playerY = int((screenH - gameSprites['player'].get_height())/2)
    messageX = int((screenW - gameSprites['message'].get_width())/2)
    messageY = int(screenH* 0.13)
    baseX = 0
    while True:
        for event in pygame.event.get():
            if event.type == QUIT or (event.type == KEYDOWN and event.key == K_ESCAPE):
                pygame.quit()
                sys.exit()
            elif event.type==KEYDOWN and (event.key==K_SPACE or event.key == K_UP):
                return
            else:
                screen.blit(gameSprites['background'],(0, 0))
                screen.blit(gameSprites['player'],(playerX-40, playerY))
                screen.blit(gameSprites['message'],(messageX, messageY))
                screen.blit(gameSprites['base'],(baseX, groundY))
                pygame.display.update()
                fpsClock.tick(fps)

def mainGame():
    score = 0
    playerX = int(screenW/5)
    playerY = int(screenW/2)
    baseX = 0
    newPipe1 = getRandomPipe()
    newPipe2 = getRandomPipe()
    upperPipes = [
        {'x': screenW+200, 'y': newPipe1[0]['y']},
        {'x': screenW+200 + (screenW/2), 'y': newPipe2[0]['y']},
        ]
    lowerPipes = [
        {'x': screenW+200, 'y': newPipe1[1]['y']},
        {'x': screenW+200 + (screenW/2), 'y': newPipe2[1]['y']},
        ]
    pipeVelX = -4
    playerVelY = -9
    playerMaxVelY = 10
    playerMinVelY = -8
    playerAccVelY = 1
    playerFlapAccV = -8
    playerFlapped = False
    
    while True:
        for event in pygame.event.get():
            if event.type == QUIT or (event.type == KEYDOWN and event.key == K_ESCAPE):
                pygame.quit()
                sys.exit()
            if event.type == KEYDOWN and (event.key == K_SPACE or event.key == K_UP):
                if playerY > 0:
                    playerVelY = playerFlapAccV
                    playerFlapped = True
                    gameAudios['wind'].play()
        crashTest = isCollide(playerX,playerY,upperPipes,lowerPipes)
        if crashTest:
            return
        
        playerMidPos = playerX + gameSprites['player'].get_width()/2
        for PIPE in upperPipes:
            pipeMidPos = PIPE['x'] + gameSprites['pipes'][0].get_width()/2
            if pipeMidPos<= playerMidPos < pipeMidPos + 4:
                score +=1
                print(f'Your score is {score}')
                gameAudios['point'].play()
            
        
        if playerVelY < playerMaxVelY and  not playerFlapped:
            playerVelY += playerAccVelY
            
        if playerFlapped:
            playerFlapped = False
        playerHeight = gameSprites['player'].get_height()
        playerY = playerY + min(playerVelY, groundY - playerY - playerHeight)
        for upperPipe , lowerPipe in zip(upperPipes,lowerPipes):
            upperPipe['x'] += pipeVelX
            lowerPipe['x'] += pipeVelX
        
        if 0<upperPipes[0]['x']<5:
            newpipe = getRandomPipe()
            upperPipes.append(newpipe[0])
            lowerPipes.append(newpipe[1])
            
        if upperPipes[0]['x'] < -gameSprites['pipes'][0].get_width():
            upperPipes.pop(0)
            lowerPipes.pop(0)
            
        screen.blit(gameSprites['background'], (0,0))
        for upperPipe , lowerPipe in zip(upperPipes,lowerPipes):
            screen.blit(gameSprites['pipes'][0],(upperPipe['x'], upperPipe['y']))
            screen.blit(gameSprites['pipes'][1],(lowerPipe['x'], lowerPipe['y']))
            
        screen.blit(gameSprites['base'],(baseX, groundY))
        screen.blit(gameSprites['player'],(playerX, playerY))
        myDigits = [int(x) for x in list(str(score))]
        width = 0
        for digit in myDigits:
            width += gameSprites['numbers'][digit].get_width()
        Xoffset = (screenW - width)/2
        
        for digit in myDigits:
            screen.blit(gameSprites['numbers'][digit],(Xoffset, screenH * 0.12))
            Xoffset += gameSprites['numbers'][digit].get_width()
        pygame.display.update()
        fpsClock.tick(fps)
        
def isCollide(playerX,playerY,upperPipes,lowerPipes):
    if playerY > groundY - 25 or playerY<0:
        gameAudios['hit'].play()
        return True
    for PIPE in upperPipes:
        pipeH = gameSprites['pipes'][0].get_height()
        if(playerY < pipeH + PIPE['y'] and abs(playerX - PIPE['x']) < gameSprites['pipes'][0].get_width()):
            gameAudios['hit'].play()
            return True 
    
    for PIPE in lowerPipes:
        if (playerY + gameSprites['player'].get_height() > PIPE['y']) and  abs(playerX - PIPE['x']) < gameSprites['pipes'][0].get_width():
            gameAudios['hit'].play()
            return True
    
    return False
    
def getRandomPipe():
    pipeH = gameSprites['pipes'][0].get_height()
    offset = screenH/3
    y2 = offset + random.randrange(0, int(screenH - gameSprites['base'].get_height() - 1.2 * offset))
    pipeX = screenW +10 
    y1 = pipeH - y2 + offset
    PIPE = [
        {'x': pipeX, 'y': -y1},
        {'x': pipeX, 'y': y2}
        ]
    return PIPE
    
if __name__ == '__main__':
    pygame.init()
    fpsClock = pygame.time.Clock()
    pygame.display.set_caption('Flappy Bird by Deepak Avudiappan')
    gameSprites['numbers'] = (
        pygame.image.load('gallery/sprites/0.png').convert_alpha(),
        pygame.image.load('gallery/sprites/1.png').convert_alpha(),
        pygame.image.load('gallery/sprites/2.png').convert_alpha(),
        pygame.image.load('gallery/sprites/3.png').convert_alpha(),
        pygame.image.load('gallery/sprites/4.png').convert_alpha(),
        pygame.image.load('gallery/sprites/5.png').convert_alpha(),
        pygame.image.load('gallery/sprites/6.png').convert_alpha(),
        pygame.image.load('gallery/sprites/7.png').convert_alpha(),
        pygame.image.load('gallery/sprites/8.png').convert_alpha(),
        pygame.image.load('gallery/sprites/9.png').convert_alpha(),
    )
    gameSprites['message'] = pygame.image.load('gallery/sprites/1609938392802.png').convert_alpha()
    gameSprites['base'] = pygame.image.load('gallery/sprites/base.png').convert_alpha()
    gameSprites['pipes'] = (
        pygame.transform.rotate(pygame.image.load(pipe).convert_alpha(),180),
        pygame.image.load(pipe).convert_alpha()
        )
    gameAudios['die'] = pygame.mixer.Sound('gallery/audio/die.wav')
    gameAudios['hit'] = pygame.mixer.Sound('gallery/audio/hit.wav')
    gameAudios['point'] = pygame.mixer.Sound('gallery/audio/point.wav')
    gameAudios['swoosh'] = pygame.mixer.Sound('gallery/audio/swoosh.wav')
    gameAudios['wind'] = pygame.mixer.Sound('gallery/audio/wing.wav')
    
    gameSprites['background'] =  pygame.image.load(background).convert()
    gameSprites['player'] =  pygame.image.load(player).convert_alpha()
    
    while(1):
        welcomeScreen()
        mainGame()
