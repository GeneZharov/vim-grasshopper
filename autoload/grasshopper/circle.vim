function! s:set_defaults() abort
  let s:circle_conf_idx = ""
  let s:circle_conf = {}
  let s:circle_map = ""
  let s:circle_map_undo = ""
  let s:circle_map_del = ""
  let s:circle_bufs = []
  let s:circle_idx = -1
endfunction!

function! s:get_accesstick(buf) abort
  return get(a:buf.variables, "grasshopper_accesstick", str2float("inf"))
endfunction

function! s:getmap(conf, conf_idx, prop, global) abort
  if has_key(a:conf, a:prop)
    return a:conf[a:prop]
  else
    if exists(a:global)
      return {a:global}
    else
      throw printf(
        \ "\"%s\" binding is not set for the \"%s\" circle",
        \ a:prop,
        \ a:conf_idx
        \ )
    endif
  endif
endfunction

function! s:show_buf(buf) abort
  exe "silent buffer!" a:buf.bufnr
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

  if !empty(s:circle_conf)
    " If some circle is already in action, then user's :map must be suppressed
    return
  endif

  if !has_key(g:grasshopper_config, a:conf_idx)
    throw a:conf_idx . " is not present in g:grasshopper_config"
  endif

  let s:circle_conf_idx = a:conf_idx
  let s:circle_conf = g:grasshopper_config[a:conf_idx]

  let s:circle_map = s:getmap(
    \ s:circle_conf,
    \ s:circle_conf_idx,
    \ "map",
    \ "g:grasshopper_map"
    \ )
  let s:circle_map_undo = s:getmap(
    \ s:circle_conf,
    \ s:circle_conf_idx,
    \ "map_undo",
    \ "g:grasshopper_map_undo"
    \ )
  let s:circle_map_del = s:getmap(
    \ s:circle_conf,
    \ s:circle_conf_idx,
    \ "map_del",
    \ "g:grasshopper_map_del"
    \ )

  let bufs = getbufinfo()
  let bufs_visible = tabpagebuflist()
  let current_buf = filter(
    \ copy(bufs),
    \ {_, d -> d.bufnr == bufnr("") && s:circle_conf.filter(d)}
    \ )

  call filter(bufs, {_, d -> d.listed})
  call filter(bufs, {_, d -> index(bufs_visible, d.bufnr) == -1})
  call filter(bufs, {_, d -> s:circle_conf.filter(d)})
  call sort(bufs, {a, b -> s:get_accesstick(a) < s:get_accesstick(b)})

  let s:circle_bufs = current_buf + bufs
  let s:circle_idx = 0

  "echo map(copy(s:circle_bufs), {_, d -> [d.name, d.variables.grasshopper_accesstick]})
  if empty(s:circle_bufs)
    call s:set_defaults()
  else
    call s:show_next(1)
    call grasshopper#demo#create_demo(
      \ s:circle_conf_idx,
      \ s:circle_bufs,
      \ s:circle_idx
      \ )
    while !empty(s:circle_conf)
      redraw " otherwise vim does not update the window content prior getchar()
      "call s:show_prompt()
      let c = grasshopper#tools#getc()
      if index(s:circle_map, c) != -1
        " Next
        call s:show_next(1)
        call grasshopper#demo#update_demo(s:circle_bufs, s:circle_idx)
      elseif index(s:circle_map_undo, c) != -1
        " Undo
        call s:show_next(-1)
        call grasshopper#demo#update_demo(s:circle_bufs, s:circle_idx)
      elseif index(s:circle_map_del, c) != -1
        " Delete
        Bdelete
        call remove(s:circle_bufs, s:circle_idx)
        let s:circle_idx = grasshopper#util#shift_idx(0, len(s:circle_bufs), 0, s:circle_idx)
        call grasshopper#demo#update_demo(s:circle_bufs, s:circle_idx)
      else
        " Exit
        call s:set_defaults()
        call grasshopper#tools#set_accesstick()
        call grasshopper#demo#close_demo()
        echo ""
        call feedkeys(c)
      endif
    endwhile
  endif
endfunction

function! grasshopper#circle#on_buf_enter() abort
  if empty(s:circle_conf)
    call grasshopper#tools#set_accesstick()
  endif
endfunction

call s:set_defaults()
