"=============================================================================
" FILE: sf2.vim
" Last Modified: 2012-05-06
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================
let s:save_cpo = &cpo
set cpo&vim

" Variables  "{{{
call unite#util#set_default('g:unite_source_sf2_ignore_pattern',
      \'^\%(/\|\a\+:/\)$\|\%(^\|/\)\.\.\?$\|empty$\|\~$\|\.\%(o|exe|dll|bak|sw[po]\)$')
"}}}
"
function! s:sf2_root()
  let dir = finddir("app", get(g:, 'unite_source_sf2_root_dir', ".;"))
  if dir == "" | return "" | endif
  return  dir . "/../"
endfunction


let s:places = [
      \ {'name' : ''             , 'path' : '/src'                         } ,
      \ {'name' : 'app'          , 'path' : '/app'                         } ,
      \ {'name' : 'app/config'   , 'path' : '/app/config'                  } ,
      \ {'name' : 'app/views'    , 'path' : '/app/Resources/views'         } ,
      \ {'name' : 'web'          , 'path' : '/web'                         } ,
      \ {'name' : 'bundles'      , 'path' : '/src'                         } ,
      \  ]

" Bundles
let s:filelist = glob(s:sf2_root() . '/src/*')
let s:splitted = split(s:filelist, "\n")

let s:commands = [
      \ 'Command', 'Controller', 'DataFixtures', 'DataFixtures', 'Entity',
      \ 'Features', 'Resources', 'Serializer', 'Tests'
      \ ]

if !exists('g:unite_source_sf2_bundles')
  let g:unite_source_sf2_bundles = {}
endif

let s:bundles = keys(g:unite_source_sf2_bundles)
if len(s:bundles) > 0
  for s:bundle in s:bundles
    let s:path = g:unite_source_sf2_bundles[s:bundle]
    call add(s:places, {'name' : s:bundle, 'path' : '/src/' . s:bundle})
    for s:command in s:commands
      call add(s:places,
            \ {'name' : s:bundle . '/' . s:command, 'path' : '/src/' . s:path . '/' . s:command}
            \ )
    endfor
  endfor
else
  " If bundles not exists, just show bundle name.
  for s:file in s:splitted
    let s:bundle = fnamemodify(s:file, ':t:r')
    call add(s:places, {'name' : s:bundle, 'path' : '/src/' . s:bundle})
  endfor
endif

let s:source = {}

function! s:source.gather_candidates(args, context)
  return s:create_sources(self.path)
endfunction

" sf2/command
"   history
"   [command] sf2

let s:source_command = {}

function! unite#sources#sf2#define()
  return map(s:places ,
        \   'extend(copy(s:source),
        \    extend(v:val, {"name": "sf2/" . v:val.name,
        \   "description": "candidates from history of " . v:val.name}))')
endfunction

function! s:create_sources(path)
  let root = s:sf2_root()
  if root == "" | return [] | end
  let files = map(split(globpath(root . a:path , '**') , '\n') , '{
        \ "name" : fnamemodify(v:val , ":t:r") ,
        \ "path" : v:val
        \ }')

  let list = []
  for f in files
    if isdirectory(f.path) | continue | endif

    if g:unite_source_sf2_ignore_pattern != '' &&
          \ f.path =~  string(g:unite_source_sf2_ignore_pattern)
        continue
    endif

    call add(list , {
          \ "abbr" : substitute(f.path , root . a:path . '/' , '' , ''),
          \ "word" : substitute(f.path , root . a:path . '/' , '' , ''),
          \ "kind" : "file" ,
          \ "action__path"      : f.path ,
          \ "action__directory" : fnamemodify(f.path , ':p:h:h') ,
          \ })
  endfor

  return list
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
