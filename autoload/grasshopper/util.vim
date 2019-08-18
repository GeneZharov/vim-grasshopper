function! grasshopper#util#shift_idx(min, max, step, n) abort
  let len = a:max - a:min
  let m = a:n + a:step
  if (m < a:min)
    return m + len
  elseif (m >= a:max)
    return m - len
  else
    return m
  endif
endfunction
