" hare.vim - Vim bindings to the HaRe haskell refactoring tool
" Maintainer: Griffin Smith <wildgriffin45 at gmail dot com>
" Version:    0.1

" Initialization {{{

if exists('g:loaded_hare') || &cp
  finish
endif
let g:loaded_hare = 1

if !exists('g:hare_executable')
  let g:hare_executable = 'ghc-hare'
endif

if !exists('g:hare_debug')
  let g:hare_debug = 0
endif

" }}}

" Window utilities {{{
function! s:hare_setup_preview()
  30wincmd _
  set buftype=nofile
  set bufhidden=wipe
  set nobuflisted
  set noswapfile
  set readonly
endfunction

" }}}


" Running HaRe {{{

function! s:hare(command, ...)
  let filename = expand('%:p')
  let l:cmd = join([g:hare_executable, a:command, filename] + a:000, ' ')

  " lcd to the parent directory first
  let prev_cwd = getcwd()
  execute 'lcd ' . expand('%:h')

  " Run the command
  if g:hare_debug
    echo system(l:cmd)
  else
    call system(l:cmd)
  endif

  " lcd back
  execute 'lcd ' . prev_cwd

  if v:shell_error > 0
    throw 'HaRe: error running command'
  endif
endfunction

" }}}

" Managing diffs {{{

function! s:hare_newfile(oldfile)
  return substitute(a:oldfile, '\.hs', '.refactored.hs', '')
endfunction


function! s:diff_command(before, after)
  return 'diff -u ' . a:before . ' ' . a:after
endfunction

function! s:preview_diff()
  let curr_file = expand('%:p')
  let curr_buf = bufname('%')

  " Set up preview window
  pedit
  wincmd P
  enew
  set filetype=diff
  let b:target_file = curr_file
  let b:target_buf = curr_buf

  " Read diff into window
  let cmd = s:diff_command(curr_file, s:hare_newfile(curr_file))
  try
    execute 'silent read !' .
          \ s:diff_command(curr_file, s:hare_newfile(curr_file))
  finally
    norm gg
    norm OPress <enter> to apply refactor
    call s:hare_setup_preview()
    nnoremap <buffer> <CR> :execute <SID>ApplyDiff()<CR>
  endtry
endfunction

function! s:ApplyDiff()
  " Switch to target buffer
  let l:target_file = b:target_file
  execute bufwinnr(b:target_buf) . 'wincmd w'
  wincmd z
  " Apply diff
  %delete
  try
    let newfile = s:hare_newfile(l:target_file)
    execute 'silent read' newfile
    call system('rm -f ' . newfile)
    1delete
  finally
    call cursor(b:hare_previous_position[1], b:hare_previous_position[2])
  endtry
endfunction

" }}}

" Core functions {{{

function! s:HareDemote()
  let cursor = getpos('.')
  call s:hare('demote', cursor[1], cursor[2])
  call cursor(cursor[1], cursor[2])
endfunction

function! s:HareDupdef(newname)
  let cursor = getpos('.')
  call s:hare('dupdef', a:newname, cursor[1], cursor[2])
  call cursor(cursor[1], cursor[2])
endfunction

function! s:HareIftocase()
  let cursor = getpos('.')
  let start = getpos("'<")
  let end = getpos("'>")
  call s:hare('iftocase', a:newname, start[1], start[2], end[1], end[2])
endfunction

function! s:HareLiftOneLevel()
  let cursor = getpos('.')
  call s:hare('liftOneLevel', cursor[1], cursor[2])
  call cursor(cursor[1], cursor[2])
endfunction

function! s:HareLiftToTopLevel()
  let cursor = getpos('.')
  call s:hare('liftToTopLevel', a:newname, cursor[1], cursor[2])
  call cursor(cursor[1], cursor[2])
endfunction

function! s:HareRename(newname)
  let b:hare_previous_position = getpos('.')
  echom "Renaming symbols..."
  call s:hare('rename',
        \ a:newname, b:hare_previous_position[1], b:hare_previous_position[2])

  if v:shell_error ==? 0
    call s:preview_diff()
  endif
endfunction

" }}}

" Commands {{{

" TODO
" command!          Hdemote    execute s:HareDemote()
" command! -nargs=1 Hdupdef    execute s:HareDupdef(<f-args>)
" command!          Hiftocase  execute s:HareIftocase()
" command!          Hliftone   execute s:HareLiftOneLevel()
" command!          Hlifttotop execute s:HareLiftToTopLevel()
command! -nargs=1 Hrename    execute s:HareRename(<f-args>)

" }}}

" vim:sw=2 et tw=80 fdm=marker fmr={{{,}}}:
