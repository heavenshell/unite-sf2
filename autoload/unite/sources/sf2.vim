let s:save_cpo = &cpo
set cpo&vim

" Variables  "{{{
call unite#util#set_default('g:unite_source_sf2_ignore_pattern',
      \'^\%(/\|\a\+:/\)$\|\%(^\|/\)\.\.\?$\|empty$\|\~$\|\.\%(o|exe|dll|bak|sw[po]\)$')
"}}}
"
function! s:sf2_root()
  let dir = finddir("app" , ".;")
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

" TODO: Foo/Bundles/Controller..
let s:bundles = [
      \ 'Command', 'Controller', 'DataFixtures', 'DataFixtures', 'Entity',
      \ 'Features', 'Resources', 'Serializer', 'Tests'
      \ ]
for s:file in s:splitted
  let s:bundle = fnamemodify(s:file, ':t:r')
  call add(s:places, {'name' : s:bundle, 'path' : '/src/' . s:bundle})
  " TODO: Foo/Bundles/Controller..
"  for s:command in s:bundles
"    call add(s:places, {'name' : s:bundle . '/' . s:command, 'path' : '/src/' . s:bundle . '/' . s:command})
"  endfor
endfor

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
