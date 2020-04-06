let s:content_winid = -1
let s:demo_bufnr = -1
let s:demo_bufnr = -1

function! s:format_line(active, path) abort
  return printf(
    \ "  %s %s",
    \ a:active ? "●" : " ",
    \ grasshopper#util#prettify_path(a:path)
    \ )
endfunction

function! grasshopper#demo#create_demo(conf_idx, bufs, idx) abort
  let s:content_winid = win_getid()
  exe printf(
    \ "silent botright %dnew Grasshopper for “%s”",
    \ len(a:bufs),
    \ a:conf_idx
    \ )
  let s:demo_winid = win_getid()
  let s:demo_bufnr = bufnr("%")
  setlocal
    \ noswapfile
    \ nonumber
    \ nobuflisted
    \ nowrap
    \ nolist
    \ nospell
    \ nocursorcolumn
    \ nocursorline
    \ winfixheight
    \ foldcolumn=0
    \ foldlevel=99
    \ textwidth=0
    \ buftype=nofile
    \ bufhidden=unload
  if v:version > 702
    setlocal norelativenumber noundofile colorcolumn=0
  endif
  let [_bufs, _idx] = grasshopper#util#reverse(a:bufs, a:idx)
  let view = map(_bufs, {i, d -> s:format_line(i == _idx, d.name)})
  call setline(1, copy(view))
  call win_gotoid(s:content_winid)
endfunction

function! grasshopper#demo#update_demo(bufs, idx) abort
  let [_bufs, _idx] = grasshopper#util#reverse(a:bufs, a:idx)
  call win_gotoid(s:demo_winid)
  let view = map(copy(_bufs), {i, d -> s:format_line(i == _idx, d.name)})
  call setline(1, view)
  exe "resize" len(_bufs)
  call win_gotoid(s:content_winid)
endfunction

function! grasshopper#demo#close_demo() abort
  exe "bwipeout" s:demo_bufnr
  let s:content_winid = -1
  let s:demo_bufnr = -1
  let s:demo_bufnr = -1
endfunction
