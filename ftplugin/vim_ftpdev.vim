" Title:  Vim filetype plugin file
" Author: Marcin Szamotulski
" Email:  mszamot [AT] gmail [DOT] com
" License: vim-license, see ':help license'
" Copyright: © Marcin Szamotulski, 2012
" GetLatestVimScript: 3322 2 :AutoInstall: FTPDEV
" Copyright Statement: {{{1
" 	  This file is a part of Automatic Tex Plugin for Vim.
"
"     Automatic Tex Plugin for Vim is free software: you can redistribute it
"     and/or modify it under the terms of the GNU General Public License as
"     published by the Free Software Foundation, either version 3 of the
"     License, or (at your option) any later version.
" 
"     Automatic Tex Plugin for Vim is distributed in the hope that it will be
"     useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
"     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
"     General Public License for more details.
" 
"     You should have received a copy of the GNU General Public License along
"     with Automatic Tex Plugin for Vim.  If not, see <http://www.gnu.org/licenses/>.
"
"     This licence applies to all files shipped with Automatic Tex Plugin.


"{{{1 GLOBAL VARIABLES
let s:vim_dirs = [ "ftplugin", "plugin", "autoload", "compiler", "syntax",
	\ "indent", "colors", "doc", "keymap", "lang", "macros", "print",
	\ "spell", "tools", "tutor", ]
if !exists("g:ftplugin_dir")
    let dir_path = ''
    for dir in s:vim_dirs
	let dir_path = fnamemodify(finddir(dir, expand("%:p:h").';'), ':p')
	if !empty(dir_path)
	    break
	endif
    endfor
    if !empty(dir_path)
	let g:ftplugin_dir = fnamemodify(dir_path, ':h:h')
    else
	let g:ftplugin_dir = expand("%:p:h")
    endif
endif
if !exists("g:ftplugin_installdir")
    exe 'lcd '.fnameescape(g:ftplugin_dir)
    let file = globpath(&rtp, expand("%"))
    lcd -
    let dir_path = ''
    for dir in s:vim_dirs
	let dir_path = fnamemodify(finddir(dir, fnamemodify(file, ':h').';'), ':p')
	if !empty(dir_path)
	    break
	endif
    endfor
    if !empty(dir)
	let g:ftplugin_installdir = fnamemodify(dir_path, ':h:h')
    else
	let g:ftplugin_installdir = split(&rtp, ',')[0]
    endif
endif
if !exists("g:ftplugin_notinstall")
    let g:ftplugin_notinstall=['Makefile', '\.tar\%(\.\%(bz2\|gz\)\)\?$', '\.vba$', '.*\.vmb$']
endif
if exists("g:ftplugin_ResetPath") && g:ftplugin_ResetPath == 1
    au! BufEnter *.vim exe "setl path=".substitute(g:ftplugin_dir.",".join(filter(split(globpath(g:ftplugin_dir, '**'), "\n"), "isdirectory(v:val)"), ","), " ", '\\\\\\\ ', 'g')
else
    function! FTPLUGIN_AddPath()
	let path=map(split(&path, ','), "fnamemodify(v:val, ':p')")
	if index(path,fnamemodify(g:ftplugin_dir, ":p")) == -1 && g:ftplugin_dir != ""
	    let add = join(filter(split(globpath(g:ftplugin_dir, '**'), "\n"), "isdirectory(v:val)"), ",")
	    let add = substitute(add, " ", '\\\\\\\ ', 'g')
	    exe "setl path+=".add
	endif
    endfunction
    exe "au! BufEnter ".g:ftplugin_dir."* call FTPLUGIN_AddPath()"
    exe "au! VimEnter * call FTPLUGIN_AddPath()"
endif
try
"1}}}

" Vim Settings: 
" vim scripts written on windows works on Linux only if the EOF are dos or unix.
setlocal fileformats=unix,dos

" FUNCTIONS AND COMMANDS AND MAPS:
function! Goto(what,bang,...) "{{{1
    let pattern = (a:0 >= 1 ? 
		\ (a:1 =~ '.*\ze\s\+\d\+$' ? matchstr(a:1, '.*\ze\s\+\d\+$') : a:1)
		\ : 'no_arg') 
    let line	= (a:0 >= 1 ? 
		\ (a:1 =~ '.*\ze\s\+\d\+$' ? matchstr(a:1, '.*\s\+\zs\d\+$') : 0) 
		\ : 0)
    " Go to a:2 lines below
    let grep_flag = ( a:bang == "!" ? 'j' : '' )
    if a:what == 'function'
	let pattern		= '^\s*\%(silent!\=\)\=\s*fu\%[nction]!\=\s\+\%(s:\|<\csid>\|\f\+\#\)\=' .  ( a:0 >=  1 ? pattern : '' )
    elseif a:what == 'command'
	let pattern		= '^\s*\%(silent!\=\)\=\s*com\%[mand]!\=\%(\s*-buffer\s*\|\s*-nargs=[01*?+]\s*\|\s*-complete=\S\+\s*\|\s*-bang\s*\|\s*-range=\=[\d%]*\s*\|\s*-count=\d\+\s*\|\s*-bar\s*\|\s*-register\s*\)*\s*'.( a:0 >= 1 ? pattern : '' )
    elseif a:what == 'variable'
	let pattern 		= '^\s*let\s\+' . ( a:0 >=  1 ? pattern : '' )
    elseif a:what == 'maplhs'
	let pattern		= '^\s*[cilnosvx!]\=\%(nore\)\=m\%[ap]\>\s\+\%(\%(<buffer>\|<silent>\|<unique>\|<expr>\)\s*\)*\(<plug>\)\=' . ( a:0 >= 1 ? pattern : '' )
    elseif a:what == 'maprhs'
	let pattern		= '^\s*[cilnosvx!]\=\%(nore\)\=m\%[ap]\>\s+\%(\%(<buffer>\|<silent>\|<unique>\|<expr>\)\s*\)*\s\+\<\S\+\>\s\+\%(<plug>\)\=' . ( a:0 >= 1 ? pattern : '' )
    else
	let pattern 		= '^\s*[ci]\=\%(\%(nore\|un\)a\%[bbrev]\|ab\%[breviate]\)' . ( a:0 >= 1 ? pattern : '' )
    endif
    let filename		= join(map(split(globpath(g:ftplugin_dir, '**/*vim'), "\n"), "fnameescape(v:val)"))

    let error = 0
    try
	exe 'silent! lvimgrep /'.pattern.'/' . grep_flag . ' ' . filename
    catch /E480:/
	echoerr 'E480: No match: ' . pattern
	let error = 1
    endtry

    if len(getloclist(".")) >= 2
	llist
    endif
    if !error
	exe 'silent! normal zO'
	exe 'normal zt'
    endif

    " Goto lines below
    if line
	exe "normal ".line."j"
    endif
endfunction
catch /E127/
endtry
" Completion is not working for a very simple reason: we are edditing a vim
" script which might not be sourced.
command! -buffer -bang -nargs=? -complete=customlist,FuncCompl Function 	:call Goto('function', <q-bang>, <q-args>) 
function! FuncCompl(A,B,C) "{{{1
    let saved_loclist=getloclist(0)
    let filename	= join(map(split(globpath(g:ftplugin_dir, '**/*vim'), "\n"), "fnameescape(v:val)"))
    try
	exe 'lvimgrep /^\s*fun\%[ction]/gj '.filename
    catch /E480:/
    endtry
    let loclist = getloclist(0)
    call setloclist(0, saved_loclist)
    call map(loclist, 'get(v:val, "text", "")')  
    call map(loclist, 'matchstr(v:val, ''^\s*fun\%[ction]!\=\s*\(<\csid>\|\cs:\)\=\zs.*\ze\s*('')')
    call filter(loclist, "v:val =~ a:A")
    call map(loclist, 'v:val.''\>''')
    return loclist
endfunction
function! CommandCompl(A,B,C) "{{{1
    let saved_loclist=getloclist(0)
    let filename	= join(map(split(globpath(g:ftplugin_dir, '**/*vim'), "\n"), "fnameescape(v:val)"))
    try
	exe 'lvimgrep /^\s*com\%[mand]/gj '.filename
    catch /E480:/
    endtry
    let loclist = getloclist(0)
    call setloclist(0, saved_loclist)
    call map(loclist, 'get(v:val, "text", "")')  
    call map(loclist, 'matchstr(v:val, ''^\s*com\%[mand]!\=\(\s*-buffer\s*\|\s*-nargs=[01*?+]\s*\|\s*-complete=\S\+\s*\|\s*-bang\s*\|\s*-range=\=[\d%]*\s*\|\s*-count=\d\+\s*\|\s*-bar\s*\|\s*-register\s*\)*\s*\zs\w*\>\ze'')')
    call map(loclist, 'v:val.''\>''')
    return join(loclist, "\n")
endfunction
function! MapRhsCompl(A,B,C) "{{{1
    let saved_loclist=getloclist(0)
    let filename	= join(map(split(globpath(g:ftplugin_dir, '**/*vim'), "\n"), "fnameescape(v:val)"))
    try
	exe 'lvimgrep /^\s*[cilnosvx!]\=\%(nore\)\=m\%[ap]\>/gj '.filename
    catch /E480:/
    endtry
    let loclist = getloclist(0)
    call setloclist(0, saved_loclist)
    call map(loclist, 'get(v:val, "text", "")')  
    call map(loclist, 'matchstr(v:val, ''^\s*[cilnosvx!]\=\%(nore\)\=m\%[ap]\>\s\+\%(\%(<buffer>\|<silent>\|<unique>\|<expr>\)\s*\)*\(<plug>\)\=\zs.*'')')
    call map(loclist, 'matchstr(v:val, ''\S\+\s\+\zs.*'')')
    call map(loclist, 'escape(v:val, "[]")')
    return join(loclist, "\n")
endfunction
function! MapLhsCompl(A,B,C) "{{{1
    let saved_loclist=getloclist(0)
    let filename	= join(map(split(globpath(g:ftplugin_dir, '**/*vim'), "\n"), "fnameescape(v:val)"))
    try
	exe 'lvimgrep /^\s*[cilnosvx!]\=\%(nore\)\=m\%[ap]\>/gj '.filename
    catch /E480:/
    endtry
    let loclist = getloclist(0)
    call setloclist(0, saved_loclist)
    call map(loclist, 'get(v:val, "text", "")')  
    call map(loclist, 'matchstr(v:val, ''^\s*[cilnosvx!]\=\%(nore\)\=m\%[ap]\>\s\+\%(\%(<buffer>\|<silent>\|<unique>\|<expr>\)\s*\)*\(<plug>\)\=\zs\S*\ze'')')
    call map(loclist, 'escape(v:val, "[]")')
    return join(loclist, "\n")
endfunction "}}}1
command! -buffer -bang -nargs=? -complete=custom,CommandCompl 	Command 	:call Goto('command', <q-bang>, <q-args>) 
command! -buffer -bang -nargs=?  			     	Variable 	:call Goto('variable', <q-bang>, <q-args>) 
command! -buffer -bang -nargs=? -complete=custom,MapLhsCompl 	MapLhs 		:call Goto('maplhs', <q-bang>, <q-args>) 
command! -buffer -bang -nargs=? -complete=custom,MapRhsCompl 	MapRhs 		:call Goto('maprhs', <q-bang>, <q-args>) 

" Search in current function
function! SearchInFunction(pattern, flag) "{{{1

    let [ cline, ccol ] = [ line("."), col(".") ]
    if a:flag =~# 'b\|w' || &wrapscan
	let begin = searchpairpos('^\s*fun\%[ction]\>', '', '^\s*endfun\%[ction]\>', 'bWn')
    endif
    if a:flag !~# 'b' || a:flag =~# 'w' || &wrapscan
	let end = searchpairpos('^\s*fun\%[ction]\>', '', '^\s*endfun\%[ction]\>', 'Wn')
    endif
    if a:flag !~# 'b'
	let pos = searchpos('\(' . a:pattern . ( a:pattern =~ '\\v' ? '|^\s*endfun%[ction]>)' : '\|^\s*endfun\%[ction]\>\)' ), 'W')
    else
	let pos = searchpos('\(' . a:pattern . ( a:pattern =~ '\\v' ? '|^\s*endfun%[ction]>)' : '\|^\s*endfun\%[ction]\>\)' ), 'Wb')
    endif

    let msg="" 
    if a:flag =~# 'w' || &wrapscan
	if a:flag !~# 'b' && pos == end
	    let msg="search hit BOTTOM, continuing at TOP"
	    call cursor(begin)
	    call search('^\s*fun\%[ction]\zs', '')
	    let pos = searchpos('\(' . a:pattern . ( a:pattern =~ '\\v' ? '|^\s*endfun%[ction]>)' : '\|^\s*endfun\%[ction]\>\)' ), 'W')
	elseif a:flag =~# 'b' && pos == begin 
	    let msg="search hit TOP, continuing at BOTTOM"
	    call cursor(end)
	    let pos = searchpos('\(' . a:pattern . ( a:pattern =~ '\\v' ? '|^\s*endfun%[ction]>)' : '\|^\s*endfun\%[ction]\>\)' ), 'Wb')
	endif
	if pos == end || pos == begin
	    let msg="Pattern: " . a:pattern . " not found." 
	    call cursor(cline, ccol)
	endif
    else
	if pos == end || pos == begin
	    let msg="Pattern: " . a:pattern . " not found." 
    	call cursor(cline, ccol)
	endif
    endif

    if msg != ""
	    echohl WarningMsg
	redraw
	exe "echomsg '".msg."'"
	    echohl Normal
    endif
endfunction
function! <SID>GetSearchArgs(Arg,flags) "{{{1
    if a:Arg =~ '^\/'
	let pattern 	= matchstr(a:Arg, '^\/\zs.*\ze\/')
	let flag	= matchstr(a:Arg, '\/.*\/\s*\zs['.a:flags.']*\ze\s*$')
    elseif a:Arg =~ '^\i' && a:Arg !~ '^\w'
	let pattern 	= matchstr(a:Arg, '^\(\i\)\zs.*\ze\1')
	let flag	= matchstr(a:Arg, '\(\i\).*\1\s*\zs['.a:flags.']*\ze\s*$')
    else
	let pattern	= matchstr(a:Arg, '^\zs\S*\ze')
	let flag	= matchstr(a:Arg, '^\S*\s*\zs['.a:flags.']*\ze\s*$')
    endif
    return [ pattern, flag ]
endfunction
function! Search(Arg) "{{{1

    let [ pattern, flag ] = <SID>GetSearchArgs(a:Arg, 'bcenpswW')
    let @/ = pattern
    call histadd("search", pattern)

    if pattern == ""
	echohl ErrorMsg
	redraw
	echomsg "Enclose the pattern with /.../"
	echohl Normal
	return
    endif

    call SearchInFunction(pattern, flag)
endfunction "}}}1
command! -buffer -nargs=*	S 	:call Search(<q-args>) | let v:searchforward = ( <SID>GetSearchArgs(<q-args>, 'bcenpswW')[1] =~# 'b' ? 0 : 1 )

nmap <silent> <buffer> <C-N>				:call SearchInFunction(@/,'')<CR>
nmap <silent> <buffer> <C-P> 				:call SearchInFunction(@/,'b')<CR>
nmap <silent> <buffer> gn 				:call SearchInFunction(@/,( v:searchforward ? '' : 'b'))<CR>
nmap <silent> <buffer> gN				:call SearchInFunction(@/,(!v:searchforward ? '' : 'b'))<CR>
function! PluginDir(...)
    if a:0 == 0 
	echo g:ftplugin_dir
    else
	let g:ftplugin_dir=a:1
    endif
endfunction
command! -nargs=? -complete=file PluginDir	:call PluginDir(<f-args>)

try
function! Pgrep(vimgrep_arg) "{{{1
    let filename	= join(filter(map(split(globpath(g:ftplugin_dir, '**/*'), "\n"), "fnameescape(v:val)"),"!isdirectory(v:val)"))
    try
	execute "lvimgrep " . a:vimgrep_arg . " " . filename 
    catch /E480:/
	echohl ErrorMsg
	redraw
	echo "E480: No match: ".a:vimgrep_arg
	echohl Normal
    endtry
endfunction
catch /E127:/
endtry
command! -nargs=1 Pgrep		:call Pgrep(<q-args>)

function! ListFunctions(bang) "{{{1
    try
	lvimgrep /^\s*fun\%[ction]/gj %
    catch /E480:/
	echohl ErrorMsg
	redraw
	echo "E480: No match: ".a:vimgrep_arg
	echohl Normal
    endtry
    let loclist = getloclist(0)
    call map(loclist, 'get(v:val, "text", "")')  
    call map(loclist, 'matchstr(v:val, ''^\s*fun\%[ction]!\=\s*\zs.*\ze\s*('')')
    if a:bang == "!"
	call sort(loclist)
    endif
    return join(<SID>PrintTable(loclist, 2), "\n")
endfunction
command! -bang ListFunctions 	:echo ListFunctions(<q-bang>)

function! ListCommands(bang) "{{{1
    try
	lvimgrep /^\s*com\%[mmand]/gj %
    catch /E480:/
	echohl ErrorMsg
	redraw
	echo "E480: No match: ".a:vimgrep_arg
	echohl Normal
    endtry
    let loclist = getloclist(0)
    call map(loclist, 'get(v:val, "text", "")')  
    call map(loclist, 'substitute(v:val, ''^\s*'', '''', '''')')
    if a:bang == "!"
	call sort(loclist)
    endif
    let cmds = []
    for raw_cmd in loclist 
	let pattern = '^\s*com\%[mand]!\=\%(\s*-buffer\s*\|\s*-nargs=[01*?+]\s*\|\s*-complete=\S\+\s*\|\s*-bang\s*\|\s*-range=\=[\d%]*\s*\|\s*-count=\d\+\s*\|\s*-bar\s*\|\s*-register\s*\)*\s*\zs\w*\ze'
	call add(cmds, matchstr(raw_cmd, pattern))
    endfor

    return join(cmds, "\n")
endfunction
command! -bang ListCommands 	:echo ListCommands(<q-bang>)

nmap	]#	:call searchpair('^[^"]*\<\zsif\>', '^[^"]*\<\zselse\%(if\)\=\>', '^[^"]*\<\zsendif\>')<CR>
nmap	[#	:call searchpair('^[^"]*\<\zsif\>', '^[^"]*\<\zselse\%(if\)\=\>', '^[^"]*\<\zsendif\>', 'b')<CR>

function! <SID>Install(bang) "{{{1

    exe 'lcd '.fnameescape(g:ftplugin_dir)
    
    if a:bang == "" 
	" Note: this returns non zero list if the buffer is loaded
	" ':h getbufline()'
	let file_name = expand('%:.')
	let file = getbufline('%', '1', '$')
	let install_path = substitute(g:ftplugin_installdir, '\/\s*$', '', '').'/'.file_name
	call writefile(file, install_path)
	echom 'File installed to: "'.install_path.'".'
    else
	let install_path = substitute(g:ftplugin_installdir, '\/\s*$', '', '')
	for file in filter(split(globpath(g:ftplugin_dir, '**'), "\n"), "!isdirectory(v:val) && <SID>Index(g:ftplugin_notinstall, fnamemodify(v:val, ':.')) == -1")
	    if bufloaded(file)
		let file_list = getbufline(file, '1', '$')
	    else
		let file_list = readfile(file)
	    endif
	    let file_name = fnamemodify(file, ':.')
	    echo 'Installing: "'.file_name.'" to "'.install_path.'/'.file_name.'"'
	    call writefile(file_list, install_path.'/'.file_name)
	endfor
    endif
    lcd -
endfunction
function! <SID>Index(list, pattern) "{{{2
    let ind = -1
    for element in a:list
	let ind += 1
	if element =~ a:pattern || element == a:pattern
	    break
	endif
    endfor
    return ind
endfunction "}}}2
command! -bang Install 	:call <SID>Install(<q-bang>)

function! Evaluate(mode) "{{{1
    let saved_pos	= getpos(".")
    let saved_reg	= @e
    if a:mode == "n"
	if strpart(getline(line(".")), col(".")-1) =~ '[bg]:'
	    let end_pos = searchpos('[bg]:\w*\zs\>', 'cW')
	else
	    let end_pos = searchpos('\ze\>', 'cW')
	endif
	let end_pos[1] -= 1 
	call cursor(saved_pos[1], saved_pos[2])
	normal! v
	call cursor(end_pos)
	normal! "ey
	let expr = @e
    elseif a:mode ==? 'v'
	let beg_pos = getpos("'<")
	let end_pos = getpos("'>")
	call cursor(beg_pos[1], beg_pos[2])
	normal! v 
	call cursor(end_pos[1], end_pos[2])
	normal! "ey
	let expr= @e
    endif
    let @e = saved_reg
    try
	echo expr."=".string({expr})
    catch /E121:/
	echomsg "variable ".expr." undefined"
    endtry
endfunction
command! -buffer -range Eval	:call Evaluate(mode())
"}}}1
" Print table tools:
function! <SID>FormatListinColumns(list,s) "{{{1
    " take a list and reformat it into many columns
    " a:s is the number of spaces between columns
    " for example of usage see atplib#PrintTable
    let max_len=max(map(copy(a:list), 'len(v:val)'))
"     let g:list=a:list
"     let g:max_len=max_len+a:s
    let new_list=[]
    let k=&l:columns/(max_len+a:s)
"     let g:k=k
    let len=len(a:list)
    let column_len=len/k
    for i in range(0, column_len)
	let entry=[]
	for j in range(0,k)
	    call add(entry, get(a:list, i+j*(column_len+1), ""))
	endfor
	call add(new_list,entry)
    endfor
    return new_list
endfunction 

function! <SID>PrintTable(list, spaces) "{{{1
" Take list format it with atplib#FormatListinColumns and then with
" atplib#Table (which makes columns of equal width)

    " a:list 	- list to print
    " a:spaces 	- nr of spaces between columns 

    let list = atplib#FormatListinColumns(a:list, a:spaces)
    let nr_of_columns = max(map(copy(list), 'len(v:val)'))
    let spaces_list = ( nr_of_columns == 1 ? [0] : map(range(1,nr_of_columns-1), 'a:spaces') )

    let g:spaces_list=spaces_list
    let g:nr_of_columns=nr_of_columns
    
    return atplib#Table(list, spaces_list)
endfunction
