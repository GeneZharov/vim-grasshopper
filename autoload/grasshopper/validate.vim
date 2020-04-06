function! s:valid_map(val) abort
  return type(a:val) == v:t_list &&
    \ grasshopper#util#all(a:val, {_, x -> type(x) == v:t_string})
endfunction

function! s:valid_filter(val) abort
  return type(a:val) == v:t_func
endfunction

function! grasshopper#validate#valid_config(conf) abort
  if type(a:conf) != v:t_dict
    call grasshopper#tools#warn("g:grasshopper_config must be a Dictionary")
    return v:false
  endif

  for [_, item] in items(a:conf)
    if !s:valid_map(item.map)
      call grasshopper#tools#warn('"map" property must be a list of strings')
      return v:false
    endif
    if !s:valid_filter(item.filter)
      call grasshopper#tools#warn('"filter" property must be a either a Funcref either a list of strings')
      return v:false
    endif
  endfor

  return v:true
endfunction
