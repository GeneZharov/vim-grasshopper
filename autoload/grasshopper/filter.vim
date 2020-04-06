function! grasshopper#filter#by_extension(extensions, bufinfo) abort
  let extension = fnamemodify(a:bufinfo.name, ":e")
  return index(a:extensions, extension) != -1
endfunction
