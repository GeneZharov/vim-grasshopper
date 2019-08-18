let s:accesstick = 0

function! grasshopper#tools#set_accesstick() abort
  let s:accesstick += 1
  let b:grasshopper_accesstick = s:accesstick
endfunction

function! grasshopper#tools#getc() abort
  let c = getchar()
  return type(c) == type(0) ? nr2char(c) : c
endfunction

function! grasshopper#tools#warn(msg) abort
  echoerr "Grasshopper: " . a:msg
endfunction
