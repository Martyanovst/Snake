model tiny
.code
.386
org 100h

start:
    call init_game_settings
    call parse_args
    call init_game_graphics
    call init_walls
    call init_items
    call init_snake  
    call draw_snake  
    call run
    call dispose

include game.asm
include parser.asm
include graphics.asm
include content.asm
end start