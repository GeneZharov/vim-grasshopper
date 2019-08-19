function! grasshopper#validate#validate_config(conf) abort
  if type(a:conf) != v:t_dict
    grasshopper#tools#warn("g:grasshopper_config must be a Dictionary")
    finish
  endif

  "for item in a:conf
  "  if type(item.name) != v:t_string
  "    grasshopper#tools#warn('"name" property must be a String')
  "  endif
  "  if type(item.filter) != v:t_func
  "    grasshopper#tools#warn('"filter" property must be a Funcref')
  "  endif
  "endofr
endfunction
