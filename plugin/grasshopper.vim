if exists("g:loaded_grasshopper") && g:loaded_grasshopper
  finish
endif
let g:loaded_grasshopper = v:true

autocmd BufWinEnter * call grasshopper#circle#on_buf_enter()

command -nargs=1 Grasshopper call grasshopper#circle#start(<f-args>)
