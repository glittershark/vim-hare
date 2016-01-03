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
function! s:hare_parse(source)
  " danger, horrible (horrible, horrible) hacks ahead
  let ok = 1
  return eval(substitute(tr(a:source, '() ', '[],'), '\n', '', 'e'))
endfunction

function! s:hare(command, ...)
  let filename = expand('%:p')
  let l:cmd = join([g:hare_executable, a:command, filename] + a:000, ' ')

  " lcd to the parent directory first
  let prev_cwd = getcwd()
  execute 'lcd ' . expand('%:h')

  silent let result = system(l:cmd)

  " Run the command
  if g:hare_debug
    echom l:result
  endif

  " lcd back
  execute 'lcd ' . prev_cwd

  if v:shell_error > 0
    throw 'HaRe: error running command'
  endif

  return s:hare_parse(l:result)
endfunction
" }}}

" Managing diffs {{{
function! s:refactored_filename(oldfile)
  return substitute(a:oldfile, '\.hs', '.refactored.hs', '')
endfunction

function! s:diff_command(before, after)
  return 'diff -u ' . a:before . ' ' . a:after
endfunction

function! s:preview_diff(touched_files)
  let curr_file = expand('%:p')
  let curr_buf = bufname('%')

  " Set up preview window
  pedit
  wincmd P
  enew
  set filetype=diff
  let b:target_file = curr_file
  let b:target_buf = curr_buf
  let b:touched_files = a:touched_files

  " Read diff into window
  try
    for touched in a:touched_files
      echom touched
      let cmd = s:diff_command(touched, s:refactored_filename(touched))
      execute 'silent read !' . cmd
      norm Go
    endfor
  finally
    norm gg
    norm OPress <enter> to apply refactor, 'q' to abort
    call s:hare_setup_preview()
    nnoremap <buffer> <CR> :silent execute <SID>ApplyDiff()<CR>
    nnoremap <buffer> q :silent execute <SID>AbortRefactor()<CR>
    augroup harediff
      autocmd!
      autocmd BufLeave * silent execute <SID>AbortRefactor() | autocmd! harediff
    augroup END
  endtry
endfunction

function! s:ApplyDiff()
  " Switch to original window
  let l:touched_files = b:touched_files
  let l:target_file = b:target_file
  let l:target_buf = b:target_buf
  autocmd! harediff
  execute bufwinnr(b:target_buf) . 'wincmd w'
  wincmd z

  try
    " Apply diff to all files
    for tgt in l:touched_files
      execute 'edit ' . tgt
      %delete
      let newfile = s:refactored_filename(tgt)
      execute 'silent read' newfile
      1delete

      call system('rm -f ' . newfile)
    endfor
  finally
    execute 'buffer' l:target_buf
    " TODO: this doesn't seem to do anything
    call cursor(b:hare_previous_position[1], b:hare_previous_position[2])
    redraw
  endtry
endfunction

function! s:AbortRefactor()
  let l:touched_files = b:touched_files
  for tgt in l:touched_files
    call system('rm -f ' . s:refactored_filename(tgt))
  endfor

  execute bufwinnr(b:target_buf) . 'wincmd w'
  wincmd z
  redraw
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
  let result = s:hare('rename',
        \ a:newname, b:hare_previous_position[1], b:hare_previous_position[2])

  if v:shell_error ==? 0 && result[0] ==? 1
    echo result[1]
    call s:preview_diff(result[1])
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
