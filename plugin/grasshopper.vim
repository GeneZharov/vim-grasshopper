if
  \ exists("g:loaded_grasshopper") &&
  \ g:loaded_grasshopper ||
  \ !exists("g:grasshopper_config")
  finish
endif
let g:loaded_grasshopper = v:true

call grasshopper#validation#valid_config(g:grasshopper_config)

autocmd BufWinEnter * call grasshopper#circle#on_buf_enter()

call grasshopper#init#create_mappings(g:grasshopper_config)
