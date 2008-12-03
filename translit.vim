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
"  Configuration:
"
"    g:translit_cursor_bg <color>
"    Cursor color for gvim when in the transliteration mode. Default = red.
"
"    g:translit_map "translit.ru"
"    Sets the initial keyboard mapping scheme. Currently "translit.ru",
"    "PLanslit" and "greek" are supported.
"
"    g:translit_toggle_keymap "<C-T>"
"    Default keybinding to toggle translit mode, Ctrl-Shift-t.
"
"    If you want to use multiple transliteration maps, setup the transliteration
"    map with a call to TranslitAddMapping(name, table), where mapping is in
"    format "keys1:map1, keys2:map2", whitespace is stripped, see end of the
"    source file, and set up the keyboard shortcuts with TranslitSetupShortcut:
"
"    call TranslitSetupShortcut('<C-G>', 'greek')
"
"  Usage:
"
"    Drop plugin under ~/.vim/plugins and switch translit mode on/off with
"    Ctrl-Shift-t.
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

let s:translit_cursor_bg_save = ''
let s:translit_maps = []
let s:translit_keys_remapped = []

if !exists("g:translit_cursor_bg")
    let g:translit_cursor_bg = 'red'
endif

if !exists("g:translit_map")
    let g:translit_map = 'translit.ru'
endif

if ! exists('g:translit_toggle_keymap')
    let g:translit_toggle_keymap='<C-T>'
endif


command! TranslitOff call TranslitOff()
command! ToggleTranslit call ToggleTranslit()



function TranslitMapKey(key, result)
    exec 'inoremap ' . a:key . ' ' . a:result
    call insert(s:translit_keys_remapped, a:key)
endfunction


function TranslitReleaseKeys()
    for key in s:translit_keys_remapped
        exec 'silent! iunmap ' . key
    endfor
    let s:translit_keys_remapped = []
endfunction


function TranslitReleaseCursor()
    if g:cursor_follows_alphabet != 0 && s:translit_cursor_bg_save != '' && g:translit_cursor_bg != ''
        exec 'highlight Cursor guibg=' . s:translit_cursor_bg_save
    endif
endfunction


function TranslitCaptureCursor()
    if g:cursor_follows_alphabet != 0
        if g:translit_cursor_bg != ''
            if s:translit_cursor_bg_save == ''
                let s:translit_cursor_bg_save = synIDattr(synIDtrans(hlID("Cursor")), "bg")
            endif
            exec 'highlight Cursor guibg=' . g:translit_cursor_bg
        endif
    endif
endfunction


function TranslitMapKeys(translation_def)
    for def in split(a:translation_def, ',')

        " trim whitespace
        let def = substitute(def, '\s', '', 'g')

        let [str_from, str_to] = split(def, ':')

        call TranslitMapKey(str_from, str_to)

        if str_from !=# toupper(str_from) && str_from ==# tolower(str_from) " case-sensitive comparison
            " shh -> SHH
            let str_from_upper = toupper(str_from)
            let str_to_upper = toupper(str_to)
            call TranslitMapKey(str_from_upper, str_to_upper)

            " and if needed, then map on uppercase-first letter as well
            " shh -> Shh
            let str_from_ucfirst = substitute(str_from, '^.', '\U&', '')

            if str_from_ucfirst !=# str_from && str_from_ucfirst !=# str_from_upper
                call TranslitMapKey(str_from_ucfirst, str_to_upper)
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
    echom 'translit.vim: mapping "' . name . '" was not found.'
    return ''
endfunction


function! Translit(name)

    if len(s:translit_keys_remapped) > 0
        call TranslitReleaseCursor()
        call TranslitReleaseKeys()

        " act as toggle
        if g:translit_map == a:name
            echom 'Transliteration off'
            return ''
        endif

    endif

    let table = TranslitGetMapping(a:name)
    if table != ''
        echom 'Using ' . a:name . ' transliteration'
        call TranslitCaptureCursor()
        let g:translit_map = a:name
        call TranslitMapKeys(table)
    endif
    return ''
endfunction


function TranslitOff()
    call TranslitReleaseCursor()
    call TranslitReleaseKeys()
endfunction


function! ToggleTranslit()
    call Translit(g:translit_map)
    return ''
endfunction


function! TranslitSetupShortcut(keymap, name)
    if a:keymap != ''
        exec 'inoremap ' . a:keymap . ' <C-r>=Translit("' . a:name . '")<CR>'
        exec 'nnoremap ' . a:keymap . ' :exec Translit("' . a:name . '")<CR>'
    endif
endfunction

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


call TranslitAddMapping("greek",
    \ 'a:α, b:β, v:β, g:γ, d:δ, e:ε, z:ζ, h:η, th:θ, u:θ, i:ι, k:κ, l:λ, m:μ, n:ν, x:ξ,' .
    \ 'o:ο, p:π, r:ρ, s:σ, t:τ, y:υ, f:φ, ch:χ, ps:ψ, w:ω')


call TranslitSetupShortcut(g:translit_toggle_keymap, g:translit_map)
" call TranslitSetupShortcut('<C-G>', 'greek')

