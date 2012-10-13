" Title:  Vim filetype plugin file
" Author: Marcin Szamotulski
" Email:  mszamot [AT] gmail [DOT] com
" GitHub: https://github.com/coot/ftpdev_vim.git
" License: vim-license, see ':help license'
" Copyright: © Marcin Szamotulski, 2012

nnoremap <buffer> <silent> ]] :<C-U>call FTPDEV_FunJump(1,1,v:count1)<CR>
vnoremap <buffer> <silent> ]] :<C-U>call FTPDEV_FunJump(1,1,v:count1, 1)<CR>
nnoremap <buffer> <silent> [[ :<C-U>call FTPDEV_FunJump(0,1,v:count1)<CR>
vnoremap <buffer> <silent> [[ :<C-U>call FTPDEV_FunJump(0,1,v:count1, 1)<CR>
nnoremap <buffer> <silent> ][ :<C-U>call FTPDEV_FunJump(1,0,v:count1)<CR>
vnoremap <buffer> <silent> ][ :<C-U>call FTPDEV_FunJump(1,0,v:count1, 1)<CR>
nnoremap <buffer> <silent> [] :<C-U>call FTPDEV_FunJump(0,0,v:count1)<CR>
vnoremap <buffer> <silent> [] :<C-U>call FTPDEV_FunJump(0,0,v:count1, 1)<CR>
