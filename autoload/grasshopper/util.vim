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

function! grasshopper#util#prettify_path(path) abort
  let ReplaceHome = {s -> substitute(a:path, "^" . home, "~", "")}
  let ReplaceCwd = {s -> substitute(a:path, "^" . cwd, ".", "")}
  let cwd = getcwd()
  let home = expand("$HOME")
  return cwd == home
    \ ? ReplaceHome(a:path)
    \ : ReplaceHome(ReplaceCwd(a:path))
endfunction

function! grasshopper#util#reverse(list, idx) abort
  let n = len(a:list)
  return [
    \ reverse(copy(a:list)),
    \ n == 0 ? 0 : n - 1 - a:idx
    \ ]
endfunction
