" ---------------------------------------------------------------------
" translit.vim
"
"  Author:  Einars Lielmanis <einars@gmail.com>
"  Date:    02 Dec 2008
"
"  About:
"
"    This plugin allows you to write texts in transliterated russian (or any
"    other language you'll write a definition for). That means, you write
"    "Cheburashka" and it gets automagically converted to "Чебурашка".
"
"    This plugin is loosely based on russian_plansliterated.vim plugin by
"    Krzystof Goj (http://www.vim.org/scripts/script.php?script_id=2401) and was
"    used as my playground for learning vimscript.
"
"
"  Variables:
"
"    g:cursor_follows_alphabet 0/1
"    Changes cursor background to red when in translit mode.
"
"    g:translit_map "translit.ru"
"    Sets the keyboard mapping scheme. Currently only translit.ru and PLanslit
"    maps are supported.
"
"    g:translit_toggle_keymap "<C-T>"
"    Default keybinding to toggle translit mode, Ctrl-Shift-t.
"
"
"  Usage:
"
"    Drop plugin under ~/.vim/plugins and switch translit mode on/off with
"    Ctrl-Shift-t.
"    Commands :TranslitOn, :TranslitOff and :ToggleTranslit are also available.
"
"
"  Custom Translit Maps:
"
"    use TranslitAddMap(name, table) to set up your own translit mode. The
"    mapping is in format "key1:result1, key2:result2", whitespace is stripped.
"
"
" Maybe TODO:
"
"    — Support for multiple mappings at once, e.g.
"       inoremap something     TranslitUseMap('translit.ru')
"       inoremap somethingelse TranslitUseMap('planslit')
"       inoremap somethingelse TranslitOff()
"    but currently it's not possible.
"

let s:is_translit_on = 0
let s:translit_cursor_bg_save = 'NONE'
let s:translit_maps = []


if !exists("g:cursor_follows_alphabet")
    let g:cursor_follows_alphabet = 1
endif

if !exists("g:translit_map")
    let g:translit_map = 'translit.ru'
endif

if ! exists('g:translit_toggle_keymap')
    let g:translit_toggle_keymap='<C-T>'
endif


command! TranslitOn call TranslitOn()
command! TranslitOff call TranslitOff()
command! ToggleTranslit call ToggleTranslit()

if g:translit_toggle_keymap != ''
    exec 'inoremap ' . g:translit_toggle_keymap . ' <C-r>=ToggleTranslit()<CR>'
    exec 'nnoremap ' . g:translit_toggle_keymap . ' :ToggleTranslit<CR>'
endif

function TranslitAddMapping(name, mapping)
    call insert(s:translit_maps, [a:name, a:mapping])
endfunction


" a minor problem: colon (:) and comma (,) may not be remapped
" all-lowercase mappings are automatically applied to uppercase as well

call TranslitAddMapping("translit.ru",
    \ 'a:а, b:б, v:в, g:г, d:д, e:е, jo:ё, yo:ё, zh:ж, z:з, i:и, j:й, k:к, l:л, m:м, n:н,' .
    \ 'o:о, p:п, r:р, s:с, t:т, u:у, f:ф, h:х, x:х, c:ц, ch:ч, sh:ш, w:ш, shh:щ, y:ы, je:э, ' .
    \ 'ju:ю, yu:ю, ja:я, ya:я, #:ъ, ##:Ъ, '':ь, '''':Ь')

call TranslitAddMapping("planslit",
    \ 'a:а, b:б, w:в, v:в, g:г, d:д, e:е, je:е, jo:ё, z:з, ż:ж, ''e:з, i:и,' .
    \ 'j:й, k:к, l:л, ł:л, m:м, n:н, o:о, p:п, r:р, s:с, t:т, u:у, f:ф, h:х, x:х,' .
    \ 'c:ц, cz:ч, sz:ш, szcz:щ, ~`:Ъ, `:ъ, y:ы, ~'':Ь, '':ь, e'':э, ju:ю, ja:я')


function! ToggleTranslit()
    if s:is_translit_on
        TranslitOff
    else
        TranslitOn
    endif
    return ''
endfunction



function TranslitMapKey(key, result)
    exec 'inoremap ' . a:key . ' ' . a:result
endfunction


function TranslitUnmapKey(key, result)
    exec 'silent! iunmap ' . a:key
endfunction


function TranslitApply(translation_def, callback)
    for def in split(a:translation_def, ',')

        " trim whitespace
        let def = substitute(def, '\s', '', 'g')

        let [str_from, str_to] = split(def, ':')

        exec 'call ' . a:callback . '(str_from, str_to)'

        if str_from !=# toupper(str_from) && str_from ==# tolower(str_from) " case-sensitive comparison
            " shh -> SHH
            let str_from_upper = toupper(str_from)
            let str_to_upper = toupper(str_to)
            exec 'call ' . a:callback . '(str_from_upper, str_to_upper)'

            " and if needed, then map on uppercase-first letter as well
            " shh -> Shh
            let str_from_ucfirst = substitute(str_from, '^.', '\U&', '')

            if str_from_ucfirst !=# str_from && str_from_ucfirst !=# str_from_upper
                exec 'call ' . a:callback . '(str_from_ucfirst, str_to_upper)'
            endif
        endif
    endfor
endfunction


function TranslitGetMapping(name)
    for [name, mapping] in s:translit_maps
        if name ==? a:name
            return mapping
        endif
    endfor
    return ''
endfunction



function TranslitOn()
    let s:is_translit_on = 1
    if g:cursor_follows_alphabet
        let s:translit_cursor_bg_save = synIDattr(synIDtrans(hlID("Cursor")), "bg")
        highlight Cursor guibg = red
    endif
    call TranslitApply(TranslitGetMapping(g:translit_map), 'TranslitMapKey')
endfunction


function! TranslitOff()
    let s:is_translit_on = 0
    if g:cursor_follows_alphabet
        exec 'hi Cursor guibg=' . s:translit_cursor_bg_save
    endif
    call TranslitApply(TranslitGetMapping(g:translit_map), 'TranslitUnmapKey')
endfunction
