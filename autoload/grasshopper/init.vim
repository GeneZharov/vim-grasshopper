function! grasshopper#init#create_mappings(conf) abort
  let i = 0
  while i < len(a:conf)
    exe printf(
      \ "nnoremap %s :call grasshopper#circle#start(%d)<CR>",
      \ a:conf[i].map,
      \ i
      \ )
    let i += 1
  endwhile
endfunction
