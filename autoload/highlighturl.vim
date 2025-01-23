" =============================================================================
" Filename: autoload/highlighturl.vim
" Author: itchyny
" License: MIT License
" Last Change: 2022/04/28 09:31:53.
" =============================================================================

let s:save_cpo = &cpo
set cpo&vim

let s:urlcursor = v:version < 704 || v:version == 704 && !has('patch682')

function! s:get(name, default) abort
  return get(b:, 'highlighturl_' . a:name, get(g:, 'highlighturl_' . a:name, a:default))
endfunction

function! highlighturl#default_pattern() abort
  return  '\v\c%(%(h?ttps?|sftp|ftps?|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%('
        \.'[&:#*@~%_\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\-=?!+/0-9a-z]+|:\d+|'
        \.',%(%(%(h?ttps?|sftp|ftps?|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|'
        \.'\([&:#*@~%_\-=?!+;/.0-9a-z]*\)|\[[&:#*@~%_\-=?!+;/.0-9a-z]*\]|'
        \.'\{%([&:#*@~%_\-=?!+;/.0-9a-z]*|\{[&:#*@~%_\-=?!+;/.0-9a-z]*\})\})+'
endfunction

function! highlighturl#get_url_highlight(cursor) abort
  let cursor = a:cursor ? '_cursor' : ''
  let term = s:get('term' . cursor, s:get('term_underline', s:get('underline', 1)) ? 'underline' : 'NONE')
  let cterm = s:get('cterm' . cursor, s:get('cterm_underline', s:get('underline', 1)) ? 'underline' : 'NONE')
  let ctermfg = s:get('ctermfg' . cursor, &background ==# 'dark' ? '44' : '31')
  let gui = s:get('gui' . cursor, s:get('gui_underline', s:get('underline', 1)) ? 'underline' : 'NONE')
  let guifg = s:get('guifg' . cursor, &background ==# 'dark' ? '#00dfdf' : '#002f5f')
  return 'term=' . term . ' cterm=' . cterm . ' ctermfg=' . ctermfg . ' gui=' . gui . ' guifg=' . guifg
endfunction

function! highlighturl#set_highlight() abort
  call highlighturl#set_url_highlight()
  if s:urlcursor
    call highlighturl#set_urlcursor_highlight()
  endif
endfunction

function! highlighturl#set_url_highlight() abort
  execute 'highlight default HighlightUrl' highlighturl#get_url_highlight(0)
endfunction

function! highlighturl#set_urlcursor_highlight() abort
  redir => out
    silent! highlight CursorLine
  redir END
  let outstr = substitute(out, '\n', '', 'g')
  let cbg = matchstr(outstr, 'ctermbg=\S\+')
  let gbg = matchstr(outstr, 'guibg=\S\+')
  execute 'highlight default HighlightUrlCursor' highlighturl#get_url_highlight(1) cbg gbg
endfunction

function! highlighturl#delete_url_match() abort
  for m in getmatches()
    if m.group ==# 'HighlightUrl' || m.group ==# 'HighlightUrlCursor'
      call matchdelete(m.id)
    endif
  endfor
endfunction

function! highlighturl#set_url_match() abort
  call highlighturl#delete_url_match()
  if s:get('enable', get(s:, 'enable', 1))
    if !hlexists('HighlightUrl')
      call highlighturl#set_highlight()
    endif
    let pattern = s:get('pattern', highlighturl#default_pattern())
    call matchadd('HighlightUrl', pattern, s:get('url_priority', 15))
    if s:urlcursor
      call highlighturl#set_urlcursor_match()
    endif
  endif
endfunction

let s:line = {}
let s:cursorline = {}
function! highlighturl#check_urlcursor() abort
  if get(s:line, bufnr('')) != line('.') || get(s:cursorline, bufnr('')) != &l:cursorline
    call highlighturl#set_urlcursor_match()
  endif
endfunction

let s:match_id = {}
function! highlighturl#set_urlcursor_match() abort
  let bufnr = bufnr('')
  let s:line[bufnr] = line('.')
  let s:cursorline[bufnr] = &l:cursorline
  if has_key(s:match_id, bufnr)
    silent! call matchdelete(s:match_id[bufnr])
  endif
  if s:get('enable', get(s:, 'enable', 1))
    let name = &l:cursorline ? 'HighlightUrlCursor': 'HighlightUrl'
    let pattern = '\%' . line('.') . 'l' . s:get('pattern', highlighturl#default_pattern())
    let s:match_id[bufnr] = matchadd(name, pattern, s:get('url_cursor_priority', 20))
  endif
endfunction

function! highlighturl#refresh() abort
  let save_winnr = winnr()
  for winnr in range(1, winnr('$'))
    silent! noautocmd execute winnr 'wincmd w'
    unlet! b:highlighturl_enable
    call highlighturl#set_url_match()
  endfor
  silent! noautocmd execute save_winnr 'wincmd w'
  return ''
endfunction

function! highlighturl#enable() abort
  let s:enable = 1
  call highlighturl#refresh()
  return ''
endfunction

function! highlighturl#disable() abort
  let s:enable = 0
  call highlighturl#refresh()
  return ''
endfunction

function! highlighturl#toggle() abort
  if get(s:, 'enable', 1)
    call highlighturl#disable()
  else
    call highlighturl#enable()
  endif
  return ''
endfunction

function! highlighturl#enable_local() abort
  let b:highlighturl_enable = 1
  call highlighturl#set_url_match()
  return ''
endfunction

function! highlighturl#disable_local() abort
  let b:highlighturl_enable = 0
  call highlighturl#set_url_match()
  return ''
endfunction

function! highlighturl#toggle_local() abort
  if s:get('enable', get(s:, 'enable', 1))
    call highlighturl#disable_local()
  else
    call highlighturl#enable_local()
  endif
  return ''
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
