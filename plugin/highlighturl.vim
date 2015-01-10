" =============================================================================
" Filename: plugin/highlighturl.vim
" Author: itchyny
" License: MIT License
" Last Change: 2015/01/10 18:48:18.
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
  autocmd CursorMoved,CursorMovedI * call highlighturl#check_urlcursor()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
