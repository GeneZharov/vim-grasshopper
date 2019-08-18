let s:circle_conf = {}
let s:circle_bufs = []
let s:circle_idx = -1

function! s:show_buf(buf) abort
  exe "buffer " . a:buf.bufnr
endfunction

function! s:get_accesstick(buf) abort
  return get(a:buf.variables, "grasshopper_accesstick", -1)
endfunction

function! s:show_next(step) abort
  let s:circle_idx = grasshopper#util#shift_idx(
    \ 0,
    \ len(s:circle_bufs),
    \ a:step,
    \ s:circle_idx
    \ )
  echo "show_next" s:circle_idx
  call s:show_buf(s:circle_bufs[s:circle_idx])
endfunction

function! grasshopper#circle#start(conf_idx) abort
  echo s:circle_conf
  if len(s:circle_conf)
    return
  endif

  echo "init"
  let s:circle_conf = g:grasshopper_config[a:conf_idx]
  let buf_current = bufnr("")
  let bufs = getbufinfo()
  let bufs_visible = tabpagebuflist()

  call filter(bufs, {_, d -> index(bufs, d.bufnr) == -1 || d.bufnr == buf_current})
  call filter(bufs, {_, d -> s:circle_conf.filter(d)})
  call sort(bufs, {a, b -> s:get_accesstick(a) > s:get_accesstick(b)})

  let s:circle_bufs = bufs
  let s:circle_idx = 0

  if len(s:circle_bufs)
    call s:show_next(1)
    while len(s:circle_conf)
      redraw " otherwise vim does not update the window content prior getchar()
      let c = grasshopper#tools#getc()
      if c == s:circle_conf.map
        echo "map"
        call s:show_next(1)
      elseif c == s:circle_conf.map_undo
        echo "map_undo"
        call s:show_next(-1)
      elseif c == s:circle_conf.map_del
        echo "map_del"
        exe s:circle_conf.delcmd
      else
        let s:circle_conf = {}
        let s:circle_bufs = []
        let s:circle_idx = -1
        call grasshopper#tools#set_accesstick()
        call feedkeys(c)
      endif
    endwhile
  endif
endfunction

function! grasshopper#circle#on_buf_enter() abort
  if !len(s:circle_conf)
    call grasshopper#tools#set_accesstick()
  endif
endfunction
