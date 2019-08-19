let s:circle_conf_idx = ""
let s:circle_conf = {}
let s:circle_bufs = []
let s:circle_idx = -1

function! s:show_buf(buf) abort
  exe "buffer! " . a:buf.bufnr
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
  call s:show_buf(s:circle_bufs[s:circle_idx])
endfunction

function! s:show_prompt() abort
  echohl MoreMsg
  echo printf("Grasshopper maping for \"%s\": ", s:circle_conf_idx)
  echohl None
endfunction

function! grasshopper#circle#start(conf_idx) abort
  if !exists("g:grasshopper_config")
    throw "g:grasshopper_config is not defined"
  endif

  call grasshopper#validate#validate_config(g:grasshopper_config)

  if len(s:circle_conf)
    return
  endif

  if !has_key(g:grasshopper_config, a:conf_idx)
    throw a:conf_idx . " is not present in g:grasshopper_config"
  endif

  let s:circle_conf_idx = a:conf_idx
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
      call s:show_prompt()
      let c = grasshopper#tools#getc()
      if index(s:circle_conf.map, c) != -1
        call s:show_next(1)
      elseif index(s:circle_conf.map_undo, c) != -1
        call s:show_next(-1)
      elseif index(s:circle_conf.map_del, c) != -1
        exe s:circle_conf.delcmd
      else
        let s:circle_conf = {}
        let s:circle_bufs = []
        let s:circle_idx = -1
        call grasshopper#tools#set_accesstick()
        echo ""
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
