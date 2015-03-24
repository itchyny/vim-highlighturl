" =============================================================================
" Filename: plugin/highlighturl.vim
" Author: itchyny
" License: MIT License
" Last Change: 2015/03/25 02:53:16.
" =============================================================================

if exists('g:loaded_highlighturl') || v:version < 700 || !exists('*matchadd')
  finish
endif
let g:loaded_highlighturl = 1

let s:save_cpo = &cpo
set cpo&vim

augroup highlighturl
  autocmd!
  autocmd VimEnter,ColorScheme * call highlighturl#set_highlight()
  autocmd VimEnter,FileType,BufEnter,WinEnter * call highlighturl#set_url_match()
  if v:version < 704 || v:version == 704 && !has('patch682')
    autocmd CursorMoved,CursorMovedI * call highlighturl#check_urlcursor()
  endif
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
