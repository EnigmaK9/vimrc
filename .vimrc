"
"
"    SSSSSSSSSSSSSSS                      iiii
"  SS:::::::::::::::S                    i::::i
" S:::::SSSSSS::::::S                     iiii
" S:::::S     SSSSSSS
" S:::::S      vvvvvvv           vvvvvvviiiiiii    mmmmmmm    mmmmmmm
" S:::::S       v:::::v         v:::::v i:::::i  mm:::::::m  m:::::::mm
"  S::::SSSS     v:::::v       v:::::v   i::::i m::::::::::mm::::::::::m
"   SS::::::SSSSS v:::::v     v:::::v    i::::i m::::::::::::::::::::::m
"     SSS::::::::SSv:::::v   v:::::v     i::::i m:::::mmm::::::mmm:::::m
"        SSSSSS::::Sv:::::v v:::::v      i::::i m::::m   m::::m   m::::m
"             S:::::Sv:::::v:::::v       i::::i m::::m   m::::m   m::::m
"             S:::::S v:::::::::v        i::::i m::::m   m::::m   m::::m
" SSSSSSS     S:::::S  v:::::::v        i::::::im::::m   m::::m   m::::m
" S::::::SSSSSS:::::S   v:::::v         i::::::im::::m   m::::m   m::::m
" S:::::::::::::::SS     v:::v          i::::::im::::m   m::::m   m::::m
"  SSSSSSSSSSSSSSS        vvv           iiiiiiiimmmmmm   mmmmmm   mmmmmm
"                       _______________________________
"                           Mi configuración de vim
"

" ##### Variables de configuración #### {{{
" Define que plugins usar.
"   0 = Ninguno
"   1 = Plugins sin dependencias
"   2 = Todos los plugins
let s:usar_plugins = 0

" Indica si las líneas largas salen de la pantalla o la envuelven
let s:envolver_lineas_largas = 1

" Indica si las operaciones de copiar/pegar/eliminar interactúan con el
" portapapeles del sistema o solo con los registros de vim
let s:usar_portapapeles_del_sistema = 1

" Define si vim conserva archivos de respaldo y swapfiles
let s:usar_respaldo_local = 1

" Activar o no la revisión ortográfica / usar inglés o español
" español
let s:activar_revision_ortorgrafica = 1
let s:revision_otrografica_en_espaniol = 0
" ### }}}

" ##### General ##### {{{
set encoding=utf-8     " Codificación para usarse en los archivos
scriptencoding utf-8   " utf-8 para para usar comandos con ñ
set mouse=a            " Usar el ratón para mover/seleccionar/etc...
set exrc               " Usar .vimrc y .exrc locales
set secure             " Suprimir comandos inseguros en .exrc locales

" Caracteres de apertura y cierra
set showmatch         " Resaltar los paréntesis/corchetes correspondientes
set matchpairs+=<:>   " Saltar también entre paréntesis angulares hermanos
" % - Alternar entre inicio y final de (){}[], etc..

let g:mapleader = ','  " La tecla líder es ',' porque '\' no está a la mano

" Descarga automática del manejador de plugins
if s:usar_plugins
    let s:path_manejador_plugins = expand('~/.vim/autoload/plug.vim')

    if !filereadable(s:path_manejador_plugins)
        echomsg 'Se instalará el manejador de plugins Vim-Plug...'
        echomsg 'Creadndo directorio para el plugin'
        call mkdir(expand('~/.vim/autoload/'), 'p')
        if !executable('curl')
            echoerr 'Se requiere instalar curl o instalar vim-plug manualmente'
            quit!
        endif

        echomsg 'Descargando el plugin'
        !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

        if v:shell_error
            echomsg 'No se pudo instalar el manejador de plugins'
            let s:usar_plugins = 0
        endif

        let s:manejador_plugins_recien_instalado = 1
    endif
    execute 'source ' . fnameescape(s:path_manejador_plugins)
endif

" Activar detección del tipo de archivo
filetype plugin indent on

" Vim anterior al 704 no se lleva bien con la shell "fish"
if &shell =~# 'fish$' && (v:version < 704 || v:version == 704 && !has('patch276'))
    set shell=/bin/bash
endif
" ### }}}

" ##### Plugins y sus configuraciones (solo si se han habilitado) ##### {{{
if s:usar_plugins
    " Todos los plugins tienen que ir entre plug#begin() y plug#end()
    call plug#begin('~/.vim/plugged')
endif

" +++ Manejo de versiones y cambios {{{
if s:usar_plugins >= 1
    Plug 'tpope/vim-fugitive', { 'on': ['Git', 'Gstatus'] }     " Manejo de git dentro de vim
    Plug 'airblade/vim-gitgutter', { 'on': 'GitGutterToggle' }  " Mostrar diferencias del archivo al editar
    Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }          " Árbol de cambios gráfico
    Plug 'vim-scripts/DirDiff.vim'                              " Ver diferencias entre directorios completos
    let g:DirDiffExcludes = '*.git,node_modules,package.json'
    nnoremap <F7>         :UndotreeToggle<Return>
    nnoremap <Leader>tgut :UndotreeToggle<Return>
    " :GitGutterToggle - Activar y desactivar gitgutter
    let g:gitgutter_map_keys = 0
    nmap ]h <Plug>GitGutterNextHunk
    nmap [h <Plug>GitGutterPrevHunk


    Plug 'MarcWeber/vim-addon-mw-utils'
    Plug 'tomtom/tlib_vim'
    Plug 'garbas/vim-snipmate'
    imap <C-e> <Plug>snipMateNextOrTrigger

    " Optional:
    Plug 'honza/vim-snippets'
    let g:snipMate = { 'snippet_version' : 1 }
endif
" +++ }}}

" +++ Completado y revisión de código {{{
if s:usar_plugins >= 1
    Plug 'mattn/emmet-vim'
    Plug 'tkhren/vim-fake'          " Texto muestra: faketext, lorems, etc...
    let g:fake_bootstrap = 1        " Cargar definiciones extra de vim-fake
endif

if s:usar_plugins >= 2
    if has('nvim') || (v:version >= 800 && has('python3'))
        if has('nvim')
            if !has('python3')
                echomsg 'No hay proveedor de python 3. Intentando instalar...'
                !pip3 install --upgrade neovim
            endif

            " Completado de código
            Plug 'Shougo/deoplete.nvim', { 'do': 'UpdateRemotePlugins' }
            Plug 'carlitux/deoplete-ternjs', { 'do': 'sudo npm install -g tern' }
            let g:deoplete#sources#ternjs#docs = 1
            let g:deoplete#sources#ternjs#include_keywords = 1
        else
            Plug 'Shougo/deoplete.nvim'
            Plug 'roxma/nvim-yarp'
            Plug 'roxma/vim-hug-neovim-rpc'
        endif
        let g:deoplete#enable_at_startup = 1
        Plug 'w0rp/ale'                   " Revisión de código (con herramientas externas)
        " Véase ":help ale-support" para ver que programas se pueden usar para
        " revisar código en el lenguaje que uses
        nnoremap <leader>tsr :call AlternarRevisionEstatica()<return>
        let s:linters_restringidos = {
                    \   'c': ['gcc'],
                    \   'cpp': ['clang'],
                    \}
        let g:ale_linters = s:linters_restringidos
        function! AlternarRevisionEstatica()
            ALEDisable
            if empty(g:ale_linters)
                let g:ale_linters = s:linters_restringidos
            else
                let g:ale_linters = {}
            endif
            ALEEnable
        endfunction
    else
        if has('lua')                     " Se requiere lúa para neocomplete
            Plug 'Shougo/neocomplete'     " Completado de código
            let g:neocomplete#enable_at_startup = 1
        endif
        Plug 'vim-syntastic/Syntastic'    " Revisión de sintaxis
    endif

    Plug 'Shougo/neosnippet'              " Gestor de plantillas de código
    Plug 'Shougo/neosnippet-snippets'     " Plantillas predefinidas
    " Ctrl-e (e de expand) para expandir plantillas de código
    imap <C-e> <Plug>(neosnippet_expand_or_jump)
    smap <C-e> <Plug>(neosnippet_expand_or_jump)
    xmap <C-e> <Plug>(neosnippet_expand_target)

    "Plug 'vim-scripts/SearchComplete'     " Completado de búsqueda
    Plug 'Shougo/neoinclude.vim', { 'for': ['c', 'cpp', 'python'] }   " Completado de cabeceras
      " emmet_leader + , (coma) - Completar abreviación emmet
      " emmet_leader + n - Saltar al siguiente punto de edición de emmet
    Plug 'Shougo/neco-vim', { 'for': 'vim' }                          " Completado de VimL
    Plug 'artur-shaik/vim-javacomplete2', { 'for': 'java' }           " Completado de Java
    Plug 'saulaxel/jcommenter.vim', { 'for': 'java' }                 " Generar JavaDoc
    nnoremap <Leader>jd :call JCommentWriter()<Return>

    Plug 'Rip-Rip/clang_complete' , { 'for': ['c', 'cpp'] }           " Completado de C/C++
    let g:clang_make_default_keymappings = 0
    if !executable('clang')
        echomsg 'Se debe instalar clang para el completado de c y c++'
    endif

    let g:clang_library_path = '/usr/lib/llvm-3.8/lib/libclang.so.1'

    Plug 'davidhalter/jedi-vim', { 'for': 'python' }                  " Completado de python
    let g:jedi#completions_enabled    = 1
    let g:jedi#auto_vim_configuration = 0
    let g:jedi#smart_auto_mappings    = 0
    let g:jedi#force_py_version       = 3

    Plug 'tkhren/vim-fake'          " Texto muestra: faketext, lorems, etc...
    let g:fake_bootstrap = 1        " Cargar definiciones extra de vim-fake

    " Omnifunciones para completado de código
    augroup OmnifuncionesCompletado
        autocmd!
        autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
        autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
        autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
        autocmd FileType java setlocal omnifunc=javacomplete#Complete
        autocmd FileType python setlocal omnifunc=jedi#completions
        autocmd FileType sql,html,css,javascript,php setlocal omnifunc=syntaxcomplete#Complete
        autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    augroup END
endif
" +++ }}}

    " +++ Navegación y edición de texto {{{
if s:usar_plugins >= 1
    Plug 'farmergreg/vim-lastplace'
    Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle'}             " Árbol de directorios
    nnoremap <Leader>tgnt :NERDTreeToggle<Return>
    nnoremap <F5>         :NERDTreeToggle<Return>

    Plug 'kshenoy/vim-signature'          " Marcas visuales
    Plug 'tpope/vim-repeat'               " Repetir plugins con .
    Plug 'terryma/vim-multiple-cursors'   " Cursores múltiples tipo sublime
    Plug 'godlygeek/Tabular', { 'on': 'Tabularize' }                  " Funciones para alinear texto
    nnoremap <Leader>tb   :Tabularize /
    xnoremap <Leader>tb   :Tabularize /
    nnoremap <Leader>tbox :Tabularize /*<Return>vip<Esc>:substitute/ /=/g<Return>r A/<Esc>vipo<Esc>0r/:substitute/ /=/g<Return>:nohlsearch<Return>

    Plug 'jiangmiao/auto-pairs'           " Completar pares de símbolos
    let g:AutoPairs = {
                \ '(' : ')', '[' : ']', '{' : '}',
                \ '"' : '"', "'" : "'", '`' : '`',
                \ '¿' : '?', '¡' : '!'
                \}
    Plug 'tpope/vim-endwise'              " Completar pares de palabras

    Plug 'KabbAmine/vCoolor.vim', { 'on': 'VCoolor' }                 " Inserción de valores RGB
    " !gpick - Programa para capturar colores
    nnoremap <Leader>vc :VCoolor<Return>
    Plug 'sedm0784/vim-you-autocorrect', { 'on': ['EnableAutoCorrect', 'DisableAutoCorrect']} " Ortografía
    " :EnableAutoCorrect - Activar autocorrección ortográfica
    " :DisableAutoCorrect - Desactivar autocorrección ortográfica
    Plug 'scrooloose/nerdcommenter'       " Utilidades para comentar código
    Plug 'iamcco/markdown-preview.vim'    " Visualizar markdown
endif

if s:usar_plugins >= 2
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " Buscador de archivos

    Plug 'majutsushi/tagbar'              " Árbol de navegación (Requiere ctags)
    nnoremap <Leader>tgtb :TagbarToggle<Return>
    nnoremap <F6>         :TagbarToggle<Return>

    Plug 'xolox/vim-misc'                 " Requerimiento para el siguiente
    Plug 'xolox/vim-easytags'             " Generación y manejo de etiquetas
    let g:easytags_auto_update = 0
endif
    " +++ }}}

    " +++ Objetos de texto y operadores {{{
if s:usar_plugins >= 1
    Plug 't9md/vim-textmanip'
    xmap <Leader>tgtm <Plug>(textmanip-toggle-mode)
    nmap <Leader>tgtm <Plug>(textmanip-toggle-mode)
    "let g:textmanip_hooks = {}
    "function! g:textmanip_hooks.finish(tm)
        "let l:helper = textmanip#helper#get()
        "if a:tm.linewise
            "call l:helper.indent(a:tm)
        "else
            "" En operaciones de bloque se borran los espacios sobrantes
            "call l:helper.remove_trailing_WS(a:tm)
        "endif
    "endfunction

    Plug 'easymotion/vim-easymotion'       " Movimiento rápido caracteres
    map <Leader>em <Plug>(easymotion-prefix)
    Plug 'michaeljsmith/vim-indent-object' " Objeto de texto 'indentado'
    Plug 'PeterRincker/vim-argumentative'  " Objeto de texto 'argumento'
    Plug 'kana/vim-textobj-user'           " Requerimiento de los próximos
    Plug 'kana/vim-textobj-function'       " Objeto de texto 'función'
    Plug 'kana/vim-textobj-line'           " Objeto de texto 'línea'
    Plug 'kana/vim-textobj-entire'         " Objeto de texto 'buffer'
    Plug 'glts/vim-textobj-comment'        " Objeto de texto 'comentario'
    Plug 'saulaxel/vim-next-object'        " Objeto de texto 'siguiente elemento'
    let g:next_object_prev_letter = 'v'
    let g:next_object_wrap_file = 1

    Plug 'tpope/vim-surround'              " Encerrar/liberar secciones
    Plug 'tpope/vim-commentary'            " Operador comentar/des-comentar
    Plug 'vim-scripts/ReplaceWithRegister' " Operador para manejo de registros

    " Estilo visual y reconocimiento de sintaxis
    Plug 'rafi/awesome-vim-colorschemes'  " Paquete de temas de color
    Plug 'vim-airline/vim-airline'        " Línea de estado ligera
    if s:usar_plugins >= 2
        let g:airline_powerline_fonts = 1
    endif
    let g:airline#extensions#tabline#enabled = 1
    Plug 'vim-airline/vim-airline-themes'  " Temas de color para el plugin anterior

    Plug 'Yggdroot/indentLine'             " Marcas de sangría visuales
    Plug 'gregsexton/MatchTag', {'for': ['html', 'xml']}              " Iluminar etiqueta hermana
    Plug 'ap/vim-css-color', {'for': ['css', 'sass']}                 " Colorear valores RGB
    Plug 'sheerun/vim-polyglot'            " Paquete de archivos de sintaxis
    "Plug 'boeckmann/vim-freepascal'        " Sintaxis de freepascal
    "Plug 'dag/vim-fish'                    " Sintaxis de fish
    "Plug 'Beerstorm/vim-brainfuck'         " Sintaxis de brainfuck
    "Plug 'khzaw/vim-conceal'               " <-+
    "Plug 'KeitaNakamura/tex-conceal.vim'   " <-+-Enmascaramiento de
    "Plug 'sethwoodworth/vim-cute-python'   " <-+-palabras clave con
    "Plug 'discoloda/c-conceal'             " <-+-sImbolos unicode
    "Plug 'dkinzer/vim-schemer'             " <-+-
    "Plug 'calebsmith/vim-lambdify'         " <-+
endif

if s:usar_plugins >= 2
    Plug 'ryanoasis/vim-devicons'          " Iconos para los archivos
    if has('mac') || has('win32')
        set guifont=DroidSansMono\ Nerd\ Fond:11
    else
        set guifont=DroidSansMono\ Nerd\ Fond\ 8
    endif
endif
    " +++ }}}

if s:usar_plugins
    call plug#end()

    if exists('s:manejador_plugins_recien_instalado')
        PlugInstall
    endif
endif
" ### }}}

" ##### Titulo de ventana e información varia ##### {{{
" Título e información de la posición y el comando actual
set title             " El título de la consola no será el argumento a vim

set showcmd           " Mostrar comandos incompletos
set showmode          " Mostrar el modo actual
set laststatus=2      " Siempre mostrar la barra de estado
" Línea de estado (cuando los plugins están desactivados)
set statusline=%f\                          " Nombre de archivo
set statusline+=[%Y]\                       " Tipo de archivo
set statusline+=\ %{getcwd()}               " Directorio actual
set statusline+=%=columna:%2c\ linea:%2l    " Línea y columna

" Menú de modo comando
"set path+=**         " Búsqueda recursiva de archivos
set wildmode=longest,full
set wildmenu          " Completado visual de opciones en el comandos :*
set wildignore=*.o,*.obj,*.bak,*.exe,*.py[co],*.swp,*~,*.pyc,.svn

" Mostrar números de línea (posición actual en absoluto + el resto en relativo)
set number            " Mostrar número de línea global
set relativenumber    " Mostrar numeración relativa
" Activar y desactivar relativenumber (toggle relativenumber number)
nnoremap <Leader>trn :setlocal relativenumber!<Return>
nnoremap <F3>        :setlocal relativenumber!<Return>
set numberwidth=3     " Longitud de la sección de números
set ruler             " Mostrar número de fila y columna

" Formato y longitud del texto
set textwidth=80      " La longitud del texto (para formateo y otras cosas)
set colorcolumn=+1    " Resaltar la columna después de &textwidth
augroup LongitudesArchivosEspeciales
    autocmd!
    " Los mensajes de un commit de git solo deben medir 72 caracteres
    autocmd FileType gitcommit setlocal spell textwidth=72
augroup END
" ### }}}

" ##### Sintaxis, indentación y caracteres invisibles ##### {{{
" +++ General +++ {{{
syntax on         " Activar sintaxis
set synmaxcol=200 " Solo resaltar primeros 200 caracteres

" Usar 256 colores cuando sea posible
if (&term =~? 'mlterm\|xterm\|xterm-256\|screen-256') || has('nvim')
    set t_Co=256
endif

let g:tema_actual = 'tender'
if s:usar_plugins
    if has('vim_starting')
        " colorscheme + <Tab> para ver los temas de color disponibles
        colorscheme default
    endif
    let s:lista_colores = [ '256_noir', 'PaperColor',
        \ 'abstract', 'alduin', 'angr', 'apprentice', 'challenger_deep',
        \ 'deus', 'gruvbox', 'gotham256', 'hybrid', 'hybrid_material',
        \ 'jellybeans', 'lightning', 'lucid', 'lucius', 'materialbox',
        \ 'meta5', 'minimalist', 'molokai', 'molokayo', 'nord', 'one',
        \ 'onedark', 'paramount', 'rdark-terminal2', 'scheakur',
        \ 'seoul256-light', 'sierra', 'tender', 'two-firewatch' ]

    let s:posicion_actual = index(s:lista_colores, g:tema_actual)

    nnoremap <leader>cr :call RotarColor()<Return>
    function! RotarColor()
        let s:posicion_actual = (s:posicion_actual + 1) % len(s:lista_colores)
        let g:tema_actual = s:lista_colores[s:posicion_actual]
        execute 'colorscheme ' . g:tema_actual

        for l:color in ['two-firewatch', 'lucid', 'paramount']
            if l:color ==# s:lista_colores[s:posicion_actual]
                set background=dark
            endif
        endfor
        for l:color in ['256_noir']
            if l:color ==# s:lista_colores[s:posicion_actual]
                set background=light
            endif
        endfor
        call ColoresPersonalizados(g:tema_actual)
    endfunction
else
    " Fondo
    "set background=dark

    colorscheme default
endif

" Cuando cambias de tema se resetean los colores aunque vuelvas al original
" Aquí se definen algunos colores personalizados y se define una función que
" permita establecerlos nuevamente si cambias de tema asdf
function! ColoresPersonalizados(tema)
    if a:tema ==# 'tender'
        highlight SpellBad guibg=NONE guifg=#f43753 ctermbg=NONE ctermfg=203
        highlight SpellCap guibg=NONE guifg=#9faa00 ctermbg=NONE ctermfg=142
        highlight SpellRare guibg=NONE guifg=#d3b987 ctermbg=NONE ctermfg=180
        highlight SpellLocal guibg=NONE guifg=#ffc24b ctermbg=NONE ctermfg=215

        highlight ColorColumn guifg=NONE ctermfg=NONE guibg=#000000 ctermbg=0 gui=NONE cterm=NONE
        highlight CursorColumn guifg=NONE ctermfg=NONE guibg=#000000 ctermbg=0 gui=NONE cterm=NONE
        highlight CursorLine guifg=NONE ctermfg=NONE guibg=#000000 ctermbg=0 gui=NONE cterm=NONE
        highlight LineNr guifg=#b3deef ctermfg=153 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
        highlight Comment guifg=#c9d05c ctermfg=185 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
        highlight FoldColumn guifg=#ffffff ctermfg=15 guibg=#202020 ctermbg=234 gui=NONE cterm=NONE
    endif
endfunction
call ColoresPersonalizados(g:tema_actual)

" Cuando y como mostrar caracteres invisibles
set list " Mostrar caracteres invisibles según las reglas de 'listchars'
if has('multi_byte') && &encoding ==# 'utf-8'
    set listchars=tab:»·,trail:·,extends:❯,precedes:❮
else
    set listchars=tab:>·,trail:·,extends:>,precedes:<
endif
if has('conceal')
    set conceallevel=2   " El texto con conceal está oculto o sustituido
    set concealcursor=   " Siempre desactivar conceal en la línea actual
endif
"   +++ }}}

" +++ Resaltado de elementos +++ {{{
" Resaltar la línea y la columna actual
set cursorline
set cursorcolumn

" Crear una clasificación de color llamada "EspaciosEnBlancoExtra"
highlight EspaciosEnBlancoExtra ctermbg=172 guifg=#D78700
" Resalta la expresión regular "\s\+$" como "EspaciosEnBlancoExtra"
match EspaciosEnBlancoExtra /\s\+$/

" Resaltar señales de conflicto en un merge de git
highlight Conflicto ctermbg=1 guifg=#FF2233
2match Conflicto /\v^(\<|\=|\>){7}([^=].+)?$/
"   +++ }}}

" +++ Tabulado y sangría +++ {{{
function! CambiarIndentacion(espacios, ...)
    " Cambia tres opciones por el precio de una llamada a función
    " Ejemplo de uso:
    "    :call CambiarIndentacion(8)<Return>
    " Si se quiere una re-indentación automática de todo el texto ya existente
    " pasar un argumento extra sin importar su valor. Ejemplo:
    "    :call CambiarIndentacion(8, 'reindenta')<Return>
    let &tabstop     = a:espacios
    let &shiftwidth  = a:espacios
    let &softtabstop = a:espacios

    " Reindenta el código existente
    if len(a:000)
        execute "normal! gg=G\<C-o>\<C-o>"
    endif
endfunction
call CambiarIndentacion(4)  " Cantidad de espacios por Tab

" Otras configuraciones con respecto a la sangría
set expandtab     " Se sangra el código con espacios
set autoindent    " Añade la sangría de la línea anterior automáticamente
set smartindent   " Aplicar sangría cuando sea necesario
set shiftround    " Redondear el nivel de sangría
set smarttab      " Usar tabs de acuerdo a 'shiftwidth'
if has('patch-8.1.1564') || has('nvim-0.4.0')
    set signcolumn=number
endif
"   +++ }}}
" ### }}}

" ##### Ventanas, buffers y navegación ##### {{{
" +++ General +++ {{{
set scrolloff=2               " Mínimas líneas por encima/debajo del cursor
set sidescrolloff=5           " Mínimas columnas por la izquierda/derecha
"set scrolljump=3              " Líneas que recorrer al salir de la pantalla
set virtualedit=block,onemore " Mover cursor más allá del fin de línea

" Configuración de las líneas largas
if s:envolver_lineas_largas
    set wrap              " Envolver líneas largas
    set linebreak         " Rompe la línea cuando se llega a la longitud máxima
    set display+=lastline " No mostrar símbolos @ cuando la línea no cabe
    set showbreak=...\    " En lineas largas, se muestran ... de continuación
    if exists('+breakindent')
        set breakindent   " Aplica sangría a la continuación de línea
    endif
else
    set nowrap            " No envolver líneas largas

    " Facilitar la navegación horizontal
    noremap zl zL
    noremap zh zH
endif

" Las flechas y el backspace dan la vuelta a través de las líneas
set whichwrap=b,s,h,l,<,>,[,]
"   +++ }}}

" +++ Ventanas +++ {{{
" Dirección para abrir nuevas ventanas (splits)
set splitright  " Las separaciones verticales se abren a la derecha
set splitbelow  " Las separaciones horizontales se abren hacia abajo
set diffopt+=vertical " :diffsplit prefiere orientación vertical
" :wincmd - Realizar un comando de ventanas

" Comandos para abrir y cerrar nuevas ventanas (splits)
nnoremap <Leader>wo :<C-u>only<Return>
nnoremap <Leader>wh :<C-u>hide<Return>
nnoremap \|   :<C-u>vsplit<Space>
nnoremap \|\| :<C-u>vsplit<Return>
nnoremap _    :<C-u>split<Space>
nnoremap __   :<C-u>split<Return>
" :ball - Convertir todos los buffers en ventanas
" :new - Crear nueva ventana vertical vacía
" :vnew - Crear nueva ventana horizontal vacía

" Comandos para movimiento entre ventanas
" <C-h> - Moverse a la ventana de la izquierda
" <C-l> - Moverse a la ventana de la derecha
" <C-k> - Moverse a la ventana de la arriba
" <C-j> - Moverse a la ventana de la abajo
" <C-w>t - Ir a la primera ventana
" <C-w>b - Ir a la última ventana
" <C-w>w - Ir a la siguiente ventana
" <C-w>W - Ir a la ventana anterior

" Comandos para cambiar la disposición de las ventanas
" <C-w>H - Mover la ventana actual a la derecha
" <C-w>L - Mover la ventana actual a la izquierda
" <C-w>K - Mover la ventana actual hacia arriba
" <C-w>J - Mover la ventana actual hacia abajo
" <C-w>r - Rotar las ventanas en sentido normal
" <C-w>R - Rotar las ventanas en sentido inverso
" <C-w>x - Intercambiar ventana actual con la siguiente

" Redimensionar las ventanas
nnoremap <C-w>- :<C-u>call RepetirRedimensionadoVentana('-', v:count)<Return>
nnoremap <C-w>+ :<C-u>call RepetirRedimensionadoVentana('+', v:count)<Return>
nnoremap <C-w>< :<C-u>call RepetirRedimensionadoVentana('<', v:count)<Return>
nnoremap <C-w>> :<C-u>call RepetirRedimensionadoVentana('>', v:count)<Return>
" <C-w>= - Igualar el tamaño de todas las ventanas
" <C-w>_ - Establecer el tamaño de la ventana (por defecto el máximo)

function! RepetirRedimensionadoVentana(inicial, cuenta)
    let l:tecla = a:inicial
    let l:cuenta = a:cuenta ? a:cuenta : 0
    while stridx('+-><', l:tecla) != -1 || l:tecla =~# '\d'
        if l:tecla =~# '\d'
            let l:cuenta = l:cuenta * 10 + l:tecla
        else
            execute l:cuenta . 'wincmd ' . l:tecla
            let l:cuenta = 0
            redraw
        endif
        let l:tecla = nr2char(getchar())
    endwhile
endfunction

" Hacer diff de las ventanas abiertas
nnoremap <Leader>tdm :call AlternarModoDiff()<Return>
nnoremap <F4> :call AlternarModoDiff()<Return>
let s:modoDiffActivado = 0
function! AlternarModoDiff()
    if s:modoDiffActivado
        windo diffoff
        let s:modoDiffActivado = 0
    else
        windo diffthis
        let s:modoDiffActivado = 1
    endif
endfunction

" Hacer diff entre de cambios no guardados
nnoremap <Leader>do :DiffOrigen<Return>
command! DiffOrigen vert new | set buftype=nofile | read ++edit # | 0d_
            \ | diffthis | wincmd p | diffthis

" vim -d <archivo1> <archivo2> - Abrir archivos en modo diff

" Mantener igualdad de tamaño en ventanas cuando el marco se redimensiona
augroup TamanioVentana
    autocmd!
    autocmd VimResized * :wincmd =
augroup end
"   +++ }}}

" +++ Tabulaciones +++ {{{
set tabpagemax=15    " Solo mostrar 15 tabs
" :tabs - Listar las tabulaciones y sus contenidos
" :tabdo - Ejecutar comando en todas las tabs existentes

" Comandos para abrir y cerrar tabulaciones
nnoremap <Leader>tn :tabnew<Space>
nnoremap <Leader>to :tabonly<Return>
" :tab all - Convertir buffers en tabs
" :tabfind - Intentar abrir archivo en 'path'
" <C-w>gf  - Abrir tab y editar archivo bajo el cursor
" <C-w>T - Convertir ventana actual en tabulación

" Moverse entre tabulaciones
nnoremap <Leader>th :tabfirst<Return>
nnoremap <Leader>tl :tablast<Return>
nnoremap <Leader>tj :tabprevious<Return>
nnoremap <Leader>tk :tabnext<Return>
" gt - Ir a la tabulación N

" Mover la tabulación actual
nnoremap <Leader>t- :tabmove -<Return>
nnoremap <Leader>t+ :tabmove +<Return>
nnoremap <Leader>t< :tabmove 0<Return>
nnoremap <Leader>t> :tabmove $<Return>

" Un "modo" especial que abrevia las operaciones con tabulaciones
nnoremap <silent> <Leader>tm :<C-u>call ModoAccionTabulacion()<Return>

function! ModoAccionTabulacion()
    if tabpagenr('$') == 1
        echomsg 'Modo tab requere más de una tabulación'
        return
    endif

    echomsg 'Modo tab. hljk+->< para controlar tabs, cualquier otra cosa para salir'
    let l:tecla = nr2char(getchar())
    let l:aciones = {
                \'h': 'tabfirst',    'l': 'tablast',
                \'j': 'tabprevious', 'k': 'tabnext',
                \'<': 'tabmove 0',   '>': 'tabmove $'
                \}

    while stridx('hljk+-><', l:tecla) != -1
        if stridx('hljk><', l:tecla) != -1
            execute l:aciones[l:tecla]
        else
            if (l:tecla ==# '+' && tabpagenr() != tabpagenr('$'))
                        \ || (l:tecla ==# '-' && tabpagenr() != 1)
                execute 'tabmove ' . l:tecla
            endif
        endif
        redraw
        let l:tecla = nr2char(getchar())
    endwhile
endfunction
"   +++ }}}

" +++ Buffers +++ {{{
set hidden                       " Permitir buffers ocultos
set switchbuf=useopen,usetab     " Preferencia a tabs/ventanas al cambiar buffer
" bufdo - Ejecutar un comando a través de todos los buffers

" Abrir y moverse entre buffers
nnoremap <Leader>bn :edit<Space>
" gf - Editar el archivo bajo el cursor en un nuevo buffer
nnoremap <Leader>bg :ls<Return>:buffer<Space>
nnoremap <Leader>bh :bfirst<Return>
nnoremap <Leader>bk :bnext<Return>
nnoremap <Leader>bj :bprevious<Return>
nnoremap <Leader>bl :last<Return>

" Cerrar ventana, buffer o tabulaciones
nnoremap <Leader>bd  :bdelete!<Return>

" Cambiar el directorio de trabajo al directorio del buffer actual
nnoremap <Leader>cd :cd %:p:h<Return>:pwd<Return>
"   +++ }}}

" +++ Movimiento en modo normal +++ {{{
" Moverse por líneas visuales en lugar de lineas lógicas
nnoremap <silent> j gj
nnoremap <silent> k gk
nnoremap <silent> gj j
nnoremap <silent> gk k

" Moverse entre inicio/medio/final de la pantalla
nnoremap <C-l> :call AlternarInicioMedioFinalComoEnEmacs()<return>
function! AlternarInicioMedioFinalComoEnEmacs()
    let l:lineas_ventana = (line('$') <= winheight('%') ? line('$') : winheight('%'))
    let l:linea_inicial = winline()

    normal! zb
    let l:linea_ultima = winline()

    if l:linea_inicial == l:linea_ultima
        normal! zt
    elseif l:linea_inicial != l:lineas_ventana / 2
         \ && l:linea_inicial != l:lineas_ventana / 2 + 1
        normal! z.
    endif

    redraw
endfunction
"   +++ }}}

" +++ Movimiento en modo comando +++ {{{
cnoremap <C-a> <Home>
" <C-e> - Ir al final de la línea en modo comando
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <A-b> <S-Left>
cnoremap <A-f> <S-Right>
cnoremap <C-d> <Del>
cnoremap <A-d> <S-Right><C-w>
cnoremap <A-D> <C-e><C-u>

cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

cnoremap <Up>   <C-p>
cnoremap <Down> <C-n>
"   +++ }}}

" +++ Dobleces (folds) +++ {{{
set foldenable           " Habilitar dobleces
set foldcolumn=1         " Una columna para mostrar la extensión de un dobles
set foldopen-=block      " No abrir dobleces al presionar }, ), etc...
set foldnestmax=3        " Máxima profundidad de los dobleces
"set foldmethod=indent    " Crear dobleces según el nivel de sangría
" Crear y eliminar dobleces
" :fold o zf -  sirven para crear dobleces
" zd - elimina el doblez más cercano
" zD - elimina dobleces recursivamente
" zE - elimina todos los dobleces de la ventana

" Abrir y cerrar dobleces
nnoremap <Space>    za
" zO - Abrir dobleces sobre la posición actual recursivamente
" zC - Cerrar dobleces sobre la posición actual recursivamente
" zR - Abrir todos los dobleces del archivo
" zM - Cerrar todos los dobleces del archivo

" Función para doblar funciones automáticamente
nmap <Leader>ff zfaf
nnoremap <Leader>faf :call DoblarFunciones()<Return>
function! DoblarFunciones()
    set foldmethod=syntax
    set foldnestmax=1
endfunction
"   +++ }}}
" ### }}}

" ##### Ayudas en la edición ##### {{{
" +++ General +++ {{{
set backspace=2       " La tecla de borrar funciona como en otros programas
set undolevels=10000  " Poder deshacer cambios hasta el infinito y más allá
set undofile          " Guardar historial de cambios tras salir
if !has('nvim')
    if !isdirectory(expand('~/.vim/undo/'))
        call mkdir(expand('~/.vim/undo/'), 'p')
    endif
    set undodir=~/.vim/undo
endif
set undoreload=10000  " Cantidad de cambios que se preservan
set history=1000      " Un historial de comandos bastante largo
set nrformats-=octal  " El octal es confundible con decimal, así qeu paso

" Alternar formato alfanumérico (toggle alpha format)
nnoremap <Leader>taf :call AlternarFormatoAlfanumerico()<Return>
function! AlternarFormatoAlfanumerico()
    if stridx(&nrformats, 'alpha') == -1
        set nrformats+=alpha  " Bienvenidos sea el conte de letras
    else
        set nrformats-=alpha  " Bye bye conteo de letras
    endif
endfunction

set nojoinspaces      " No insertar dos espacios tras signo de puntuación
set lazyredraw        " No redibujar la interfaz a menos que sea necesario
set updatetime=500    " Tiempo para que vim se actualice
set ttimeout          " ttimeout y ttimeoutlen controlan el retraso de la
set ttimeoutlen=1     " interfaz para que <Esc> no se tarde

" Rotar entre los diferentes modos visuales con v
xnoremap <expr> v
               \ (mode() ==# 'v' ? 'V' : mode() ==# 'V' ?
               \ "\<C-v>" : 'v')
"   +++ }}}

" +++ Copiando, pegando y moviendo texto +++ {{{
set nopaste           " 'paste' estará desactivada por defecto
set pastetoggle=<F2>  " Botón para activar/desactivar 'paste'

" Definir el comportamiento del registro sin nombre
if s:usar_portapapeles_del_sistema && has('clipboard')
    if has('unnamedplus') " Cuando se pueda usar el registro + para copiar-pegar
        set clipboard=unnamed,unnamedplus
    else " En mac y windows se usa el registro * para copiar-pegar
        set clipboard=unnamed
    endif
endif

" Pegando texto respetando la indentación (put under y put over)
nnoremap <Leader>pu ]p
nnoremap <Leader>po [p

" Manejo de registros por medio de la letra ñ
nnoremap ñ "
xnoremap ñ "

" Hacer que Y actúe como C y D
noremap Y y$

" Hacer que Ctrl-c copie cosas al porta-papeles del sistema
xnoremap <C-c> "+y
nnoremap <C-c> "+yy

" Mover lineas visuales hacia arriba y hacia abajo
if !s:usar_plugins
    " Copiar texto por arriba y por debajo
    nnoremap <expr> <A-y> "<Esc>yy" . v:count . 'P'
    vnoremap <expr> <A-y> 'y`>' . v:count . 'pgv'
    nnoremap <expr> <A-Y> "<Esc>yy" . v:count . 'gpge'
    vnoremap <expr> <A-Y> 'y`<' . v:count . 'Pgv'

    nnoremap <expr> <A-j> ':<C-u>move +' . CantMover(0) . "<Return>=="
    vnoremap <expr> <A-j> ":move '>+" . CantMover(0) . "<Return>gv=gv"
    nnoremap <expr> <A-k> ':<C-u>move -' . CantMover(1) . "<Return>=="
    vnoremap <expr> <A-k> ":move '<-" . CantMover(1) . "<Return>gv=gv"

    function! CantMover(abajo)
        return (v:count ? v:count : 1) + a:abajo
    endfunction

    " Mover bloques visuales a la izquierda y a la derecha
    nnoremap <expr> <A-l> '<Esc>x' . (v:count > 1 ? (v:count - 1) . 'l' : '') . 'p'
    vnoremap <expr> <A-l> 'd' . (v:count > 1 ? (v:count - 1) . 'l' : '') . 'p`[<C-v>`]'
    nnoremap <expr> <A-h> '<Esc>x' . (v:count ? v:count : 1) . 'hP'
    vnoremap <expr> <A-h> 'd' . (v:count ? v:count : 1) . 'hP`[<C-v>`]'
else
    nmap <A-y> <Plug>(textmanip-duplicate-up)
    xmap <A-y> <Plug>(textmanip-duplicate-up)
    nmap <A-Y> <Plug>(textmanip-duplicate-down)
    xmap <A-Y> <Plug>(textmanip-duplicate-down)

    nmap <A-j> V<A-j><Esc>
    xmap <A-j> <Plug>(textmanip-move-down)
    nmap <A-k> V<A-k><Esc>
    xmap <A-k> <Plug>(textmanip-move-up)

    nmap <A-h> v<A-h><Esc>
    xmap <A-h> <Plug>(textmanip-move-left)
    nmap <A-l> v<A-l><Esc>
    xmap <A-l> <Plug>(textmanip-move-right)

    xmap <Up>     <Plug>(textmanip-move-up-r)
    xmap <Down>   <Plug>(textmanip-move-down-r)
    xmap <Left>   <Plug>(textmanip-move-left-r)
    xmap <Right>  <Plug>(textmanip-move-right-r)
endif

" Mantener el modo visual después de > y <
xnoremap < <gv
xnoremap > >gv
"   +++ }}}

" +++ Operaciones comunes de modificación de texto +++ {{{
if exists('+formatoptions')
    set formatoptions+=j " Eliminar caracter de comentario al unir líneas
    set formatoptions+=l " Partir líneas cuando se hagan muy largas
endif

" Regresar rápido a modo normal
inoremap kj <Esc>

" Seleccionando texto significativo
" Texto previamente insertado
nnoremap gV `[v`]
" Texto previamente pegado
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'
" gv - Reseleccionar texto previamente seleccionado

" Seleccionar una columna de texto no vacío hacia arriba o hacia abajo en modo
" de selección de columna
xnoremap <leader><C-v>k :<C-u>call <SID>seleccionarColumna('arriba')<CR>
xnoremap <leader><C-v>j :<C-u>call <SID>seleccionarColumna('abajo')<CR>
xnoremap <leader><C-v>a :<C-u>call <SID>seleccionarColumna('ambas-direcciones')<CR>

function! s:seleccionarColumna(direccion)
    normal! gv

    let [l:_, l:num, l:col, l:_, l:_] = getcurpos()
    let l:suapped_position = 0
    if line("'>") == l:num && col("'>") == l:col
        normal! o
        let l:suapped_position = 1
    endif

    if a:direccion ==# 'arriba' || a:direccion ==# 'ambas-direcciones'
        while match(getline(line('.') - 1)[l:col - 1], '\_S') != -1
            normal! k
        endwhile
    endif

    normal! o
    if a:direccion ==# 'abajo' || a:direccion ==# 'ambas-direcciones'
        while match(getline(line('.') + 1)[l:col - 1], '\_S') != -1
            normal! j
        endwhile
    endif

    if !l:suapped_position
        normal! o
    endif
endfunction

" Eliminar texto hacia enfrente con comandos basados en la D
inoremap <C-d> <Del>
inoremap <expr> <A-d> '<Esc>' . (col('.') == 1 ? "" : "l") . 'dwi'
inoremap <expr> <A-D> '<Esc>' . (col('.') == 1 ? "" : "l") . 'C'

" Regresar a modo normal eliminando la línea actual
inoremap <A-k><A-j> <Esc>ddkk
inoremap <A-j><A-k> <Esc>ddj

" Añadir línea vacía por arriba y por debajo
nnoremap <A-o> :call append(line('.'), '')<Return>
nnoremap <A-O> :call append(line('.')-1, '')<Return>

" Emular un par de comandos para rodear texto (de vim surround)
if !s:usar_plugins
    nnoremap ysiw   :call RodearPalabra()<Return>
    xnoremap S <Esc>:call RodearSeleccion()<Return>

    function! RodearPalabra()
        let l:leido = nr2char(getchar())
        let [l:car_apertura, l:car_cierre] = CaracteresHermanos(l:leido)

        execute "normal! viw\<Esc>a"
                    \ . l:car_cierre
                    \ . "\<Esc>"
                    \ . "hviwo\<Esc>i"
                    \ . l:car_apertura
                    \ . "\<Esc>lel"
    endfunction

    function! RodearSeleccion()
        let l:leido = nr2char(getchar())
        let [l:car_apertura, l:car_cierre] = CaracteresHermanos(l:leido)

        execute 'normal! `>a'
                    \ . l:car_cierre
                    \ . "\<Esc>"
                    \ . '`<i'
                    \ . l:car_apertura
                    \ . "\<Esc>"
    endfunction
endif

function! CaracteresHermanos(caracter)
    if a:caracter ==# '(' || a:caracter ==# ')'
        let [l:car_inicial, l:car_final] = ['(', ')']
    elseif a:caracter ==# '{' || a:caracter ==# '}'
        let [l:car_inicial, l:car_final] = ['{', '}']
    elseif a:caracter ==# '<' || a:caracter ==# '>'
        let [l:car_inicial, l:car_final] = ['<', '>']
    else
        let [l:car_final, l:car_inicial] = [a:caracter, a:caracter]
    endif

    return [l:car_inicial, l:car_final]
endfunction

" Alinear (remplazo para Tabularize si los plugins están desactivados)
command! -nargs=1 -range Alinear '<,'>call Alinear(<f-args>)

xnoremap <Leader>al :Alinear<Space>
nnoremap <Leader>al vip:Alinear<Space>

function! Alinear(cadena) range
    let l:columna_inicial = min([virtcol("'<"), virtcol("'>")])
    let l:guardar_pos_cursor = getpos('.')
    let l:columna_maxima = s:columnaMaxima(a:cadena, a:firstline, a:lastline, l:columna_inicial)

    for l:linea in range(a:lastline - a:firstline + 1)
        call cursor(a:firstline + l:linea, l:columna_inicial)
        if search(a:cadena, 'c', line('.')) != 0
            let l:delta_col = (l:columna_maxima - col('.'))
            if l:delta_col > 0
                execute 'normal! ' . l:delta_col . 'i '
            endif
        endif
    endfor

    call setpos('.', l:guardar_pos_cursor)
endfunction

function! s:columnaMaxima(cadena, linea_ini, linea_fin, columna)
    let l:columna_maxima = 0

    for l:linea in range(a:linea_fin - a:linea_ini + 1)
        call cursor(a:linea_ini + l:linea, a:columna)
        call search(a:cadena, 'c', line('.'))

        let l:columna_actual = col('.')
        if l:columna_actual > l:columna_maxima
            let l:columna_maxima = l:columna_actual
        endif
    endfor

    return l:columna_maxima
endfunction

" Comentar (remplazo sencillo de vim-comentary)
if !s:usar_plugins
    let b:inicio_comentario = '//'
    augroup DetectarInicioComentario
        autocmd FileType py,sh   let b:inicio_comentario = '#'
        autocmd FileType fortran let b:inicio_comentario = '!'
        autocmd FileType vim     let b:inicio_comentario = '"'
    augroup END

    nnoremap gc :set operatorfunc=OperadorComentarLineas<Return>g@
    xnoremap gc :<C-u>call OperadorComentarLineas(visualmode(), 1)<Return>

    function! OperadorComentarLineas(tipo, ...)
        let l:marca_inicio = (a:0 ? "'<" : "'[")
        let l:marca_final  = (a:0 ? "'>" : "']")

        let l:primera_liena = getline(line(l:marca_inicio))
        let l:rango = l:marca_inicio . ',' . l:marca_final
        if l:primera_liena =~# '^\s*' . b:inicio_comentario
            execute l:rango . 's/\v(^\s*)' . escape(b:inicio_comentario, '\/') . '\v\s*/\1/e'
        else
            execute l:rango . 's/^\s*/&' . escape(b:inicio_comentario, '\/') . ' /e'
        endif
        execute 'normal! ' . l:marca_inicio
    endfunction
endif

" Extraer variable (variable extract)
nnoremap <Leader>ve viw:call ExtraerVariable()<Return>
xnoremap <Leader>ve :call ExtraerVariable()<Return>
function! ExtraerVariable()
    let l:tipo = input('Tipo variable: ')
    let l:name = input('Nombre variable: ')

    if (visualmode() ==# '')
        normal! viw
    else
        normal! gv
    endif

    exec 'normal! c' . l:name
    let l:selection = @"
    exec 'normal! O' l:tipo . ' ' . l:name . ' = '
    exec 'normal! pa;'
    call feedkeys(':.+1,$s/\V\C' . escape(l:selection, '/\') . '/' . escape(l:name, '/\') . "/gec\<cr>")
endfunction

" Insertar una llave o paréntesis de cierre incluso cuando el plugin
" autopairs esté activo
inoremap <Leader>} <Space><Esc>r}==
nnoremap <Leader>} A<Space><Esc>r}==
inoremap <Leader>) <Space><Esc>r)a
nnoremap <Leader>) i<Space><Esc>r)

" Borrar todo de la línea de comandos excepto el propio comando
cnoremap <A-w> <C-\>esplit(getcmdline(), " ")[0]<return><space>
cmap <A-BS> <A-BS>

" Aumentar la granularidad del undo
inoremap <C-u> <C-g>u<C-u>
inoremap <Return> <C-g>u<Return>
"   +++ }}}

" +++ Objetos de texto +++ {{{
if !s:usar_plugins
    " Objeto de texto "línea"
    xnoremap il g_o^
    onoremap il :<C-u>normal vil<Return>
    xnoremap al $o0
    onoremap al :<C-u>normal val<Return>

    " Objecto de texto "buffer completo"
    xnoremap i% GoggV
    onoremap i% :<C-u>normal vi%<Return>
    xnoremap a% GoggV
    onoremap a% :<C-u>normal vi%<Return>
endif
"   +++ }}}
" ### }}}

" ##### Búsqueda y reemplazo ##### {{{
" +++ General +++ {{{
set wrapscan           " Las búsquedas dan la vuelta al archivo
set incsearch          " Hacer las búsquedas incrementales
if exists('+inccommand')
    set inccommand=nosplit " Hacer los remplazos incrementales
endif
set ignorecase         " No diferenciar mayúsculas/minúsculas
set smartcase          " Ignorecase si la palabra empieza por minúscula
set hlsearch           " Al buscar texto se resaltan las coincidencias
set magic              " Se usa el modo 'mágico' de búsqueda/reemplazo
set gdefault           " Usar bandera 'g' por defecto en las sustituciones

" Desactivar el resaltado de búsqueda
nnoremap // :nohlsearch<Return>
nnoremap <Leader>hsc :nohlsearch<bar>let @/ = ''<Return>
"   +++ }}}

" +++ Hacks para la búsqueda y remplazo +++ {{{
" Hacer que el comando . (repetir edición) funcione en modo visual
xnoremap . :normal .<Return>

" Repitiendo sustituciones con todo y sus banderas
nnoremap & :&&<Return>
xnoremap & :&&<Return>

" Repitiendo el último comando de consola
nnoremap Q @:
xnoremap Q @:

" No moverse cuando se busca con * y #
nnoremap * *N
nnoremap # #N

" Usar * y # en modo visual busca texto seleccionado y no la palabra actual
xnoremap * :<C-u>call SeleccionVisual()<Return>/<C-R>=@/<Return><Return>N
xnoremap # :<C-u>call SeleccionVisual()<Return>?<C-R>=@/<Return><Return>N

function! SeleccionVisual() range
    let l:registro_guardado = @"
    execute 'normal! vgvy'

    let l:patron = escape(@", "\\/.*'$^~[]")
    let l:patron = substitute(l:patron, "\n$", '', '')

    let @/ = l:patron
    let @" = l:registro_guardado
endfunction

" Ver la línea de la palabra buscada en el centro
nnoremap n nzzzv
nnoremap N Nzzzv
"   +++ }}}

" +++ Comandos nuevos (mapeos) +++ {{{
" Buscar una palabra y guardar resultados en una locallist
nnoremap <Leader>gg  :lvimgrep<Space>
nnoremap <Leader>gcw :lvimgrep<Space><C-r><C-w><Space>
nnoremap <Leader>gcd :lvimgrep<Space><Space>./*<Left><Left><Left><Left>
nnoremap <Leader>gwd :lvimgrep<Space><C-r><C-w><Space>./*<Return>

" Buscar texto en todos los buffers abiertos
command! -nargs=1 BuscarBuffers call BuscarBuffers(<q-args>)
nnoremap <Leader>gob :BuscarBuffers<Space>

function! BuscarBuffers(patron)
    let l:archivos = map(filter(range(1, bufnr('$')), 'buflisted(v:val)'),
                \ 'fnameescape(bufname(v:val))')
    try
        silent noautocmd execute 'lvimgrep /' . a:patron . '/gj ' . join(l:archivos)
    catch /^Vim\%((\a\+)\)\=:E480/
        echomsg 'No hubo coincidencias'
    endtry
    lwindow
endfunction

" Ver resultado del comando grep (see result)
nnoremap <Leader>gsr :lopen<Return>

" Reemplazar texto (replace [local | global | current-global])
if !s:usar_plugins
    " Recordar que 'gdefault' está activo, una g extra al final lo desactiva
    nnoremap <Leader>ss :s/
    xnoremap <Leader>ss :s/
    nnoremap <Leader>se :%s/
    xnoremap <Leader>se :<C-u>call SeleccionVisual()<Return>:%s/<C-r>=@/<Return>/
    nnoremap <Leader>sw :%s/\<<C-r><C-w>\>\C/
    nnoremap <Leader>sW :%s/\<<C-r>=expand("<cWORD>")<Return>\>\C/
    xnoremap <Leader>sx :<C-u>call SeleccionVisual()<Return>:s/<C-r>=@/<Return>/
endif

" Saltar entre conflictos merge
nnoremap <silent> <Leader>ml /\v^(\<\|\=\|\>){7}([^=].+)?$<Return>
nnoremap <silent> <Leader>mh ?\v^(\<\|\=\|\>){7}([^=].+)\?$<Return>
"   +++ }}}
" ### }}}

" ##### Guardando, saliendo y regresando a vim ##### {{{
set fileformats=unix,dos,mac " Formato para los saltos de línea
set autowrite         " Guardado automático en ciertas ocasiones
set autoread          " Recargar el archivo si hay cambios

" +++ Respaldos y recuperación en caso de fallos +++ {{{
if s:usar_respaldo_local
    set backup            " Hacer el respaldo
    set backupcopy=yes
    set backupdir=~/.vim/backup,~/tmp/,/var/tmp,/tmp
    if !isdirectory(expand('~/.vim/backup/'))
        call mkdir(expand('~/.vim/backup/'), 'p')
    endif
    set swapfile          " Archivo swap para el buffer
    set directory=~/tmp,/var/tmp,/tmp
else
    set nobackup          " Sin respaldo
    set nowritebackup     " No guardar respaldo (no tiene sentido)
    set noswapfile        " Sin archivo swap para el buffer actual
endif

" Crear sesión (con un nombre específico o con el nombre por defecto)
set sessionoptions-=options
set sessionoptions+=localoptions
set sessionoptions+=unix,slash
nnoremap <Leader>ms  :mksession! ~/.vim/session/
nnoremap <Leader>mds :mksession! ~/.vim/session/default<Return>
nnoremap <Leader>cs  :source ~/.vim/session/
nnoremap <Leader>cfs :source ~/.vim/session/default<Return>
" vim -S <archivo_sesion> - Abrir vim con una sesión

if !isdirectory(expand('~/.vim/session/'))
    call mkdir(expand('~/.vim/session/'), 'p')
endif
"   +++ }}}

" +++ Comandos y acciones automáticas para abrir, guardar y salir +++ {{{
" Comandos para salir de vim desde modo normal
nnoremap ZG :xa<Return>
nnoremap ZA :quitall!<Return>
" ZQ - Eliminar la ventana actual sin guardar
" ZZ - Eliminar la ventana actual guardando

" Para que shift en modo comando no moleste
command! -bang -nargs=* -complete=file E  e<bang> <args>
command! -bang -nargs=* -complete=file W  w<bang> <args>
command! -bang -nargs=* -complete=file Wq wq<bang> <args>
command! -bang -nargs=* -complete=file WQ wq<bang> <args>
command! -bang Wa wa<bang>
command! -bang WA wa<bang>
command! -bang Q q<bang>
command! -bang Qa qa<bang>
command! -bang QA qa<bang>
command! -bang Wqa wqa<bang>
command! -bang WQa wqa<bang>
command! -bang WQA wqa<bang>
command! -bang Xa xa<bang>
command! -bang XA xa<bang>

" Usar Ctrl-s para guardar como en cualquier otro programa
nnoremap <C-s> :update<Return>
inoremap <C-s> <Esc>:update<Return>a

" Guardar con sudo (cuando entraste a vim sin sudo, se pedirá contraseña)
cnoremap w!! w !sudo tee % > /dev/null<Return>

augroup ComandosAutomaticosGuardarLeer
    autocmd!
    " Eliminar espacios sobrantes cada que se guarde el archivo
    " (Si no quieres que esto pase, comenta esta línea con un ")
    autocmd BufWritePre * :%s/\s\+$//e

    " Abrir vim en la última posición editada del archivo
    if !s:usar_plugins
        autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$")
                    \ |           execute "normal! g`\""
                    \ |       endif
    endif

    " Re-Cargar la configuración cuando se guarde
    autocmd BufWritePost $MYVIMRC source $MYVIMRC

    autocmd QuitPre .exrc call AplicarConfiguracion()

    " Si se intenta editar un archivo en un directorio inexistente
    autocmd BufNewFile * call CrearDirectorioSiNoExiste()
augroup END

function! CrearDirectorioSiNoExiste()
    let l:dir_requerido = expand('%:h')
    if !isdirectory(l:dir_requerido)
        let l:respuesta = confirm('El directorio ' . l:dir_requerido
                    \ . ' no existe. ¿Quieres crearlo?',
                    \   "&Si\n&No", 1)

        if l:respuesta != 1
            return
        endif

        try
            call mkdir(l:dir_requerido, 'p')
        catch
            echoerr 'No se ha podido crear ' . l:dir_requerido
        endtry
    endif
endfunction
"   +++ }}}

" +++ Configuración para archivos grandes +++ {{{
augroup ArchivoGrande
    let s:TAMANIO_GRANDE = 10 * 1024 * 1024
    autocmd!
    autocmd BufReadPre * let s:tamanio = getfsize(expand("<afile>"))
                \ | if s:tamanio > s:TAMANIO_GRANDE || s:tamanio == -2
                \ |     call ArchivoGrande()
                \ | endif
augroup END

function! ArchivoGrande()
    " Esta función es llamada cuando el archivo supera 10M de longitud
    syntax off
    set eventignore+=FileType  " Sin resaltado y demás cosas dependientes del tipo
    setlocal bufhidden=unload  " Guardar memoria cuando otro archivo es usado
    setlocal undolevels=-1     " Sin historial de cambios
    setlocal nospell           " Sin revisión ortográfica"
endfunction
"   +++ }}}
" ### }}}

" ##### Compilación, revisión de errores y cosas específicas de un lenguaje ##### {{{
" +++ Comandos de compilación y ejecución +++ {{{
let g:op_compilacion = {}
let g:op_compilacion['archivos'] = '%'
let g:op_compilacion['nombre_ejecutable'] = '%:t:r'
let g:op_compilacion['c'] = {
            \ 'compilador': 'gcc',
            \ 'banderas': '-std=gnu11 -Wall -Wextra -Wno-missing-field-initializers -Wstrict-prototypes',
            \ 'salida': '-o'
            \}
let g:op_compilacion['cpp'] = {
            \ 'compilador': 'g++',
            \ 'banderas': '-std=c++14 -Wall -Wextra',
            \ 'salida': '-o'
            \}
let g:op_compilacion['fortran'] = {
            \ 'compilador': 'gfortran',
            \ 'banderas': '-Wall -Wextra',
            \ 'salida': '-o'
            \}
let g:op_compilacion['java'] = {
            \ 'compilador': 'javac',
            \ 'banderas': '',
            \ 'salida': ''
            \}
let g:op_compilacion['cs'] = {
            \ 'compilador': 'mcs',
            \ 'banderas': '',
            \ 'salida': ''
            \}
let g:op_compilacion['haskell'] = {
            \ 'compilador': 'ghc',
            \ 'banderas': '-dynamic',
            \ 'salida': ''
            \}
" En python/bash/ruby y otros interpretados se revisa el código
let g:op_compilacion['python'] = {
            \ 'compilador': 'flake8',
            \ 'banderas': '',
            \ 'salida': ''
            \}
let g:op_compilacion['sh'] = {
            \ 'compilador': 'bash -n',
            \ 'banderas': '',
            \ 'salida': ''
            \}
let g:comando_compilacion = {}
function! ActualizarComandosCompilacion()
    let l:dict = {}
    for l:el in items(g:op_compilacion)
        let l:op = l:el[1]
        if !exists('g:usar_make_personalizado') || g:usar_make_personalizado == 0
            let l:dict[l:el[0]] = l:op['compilador'] . ' '

            let l:dict[l:el[0]] .= l:op['salida'] . ' '
            if (!empty(l:op['salida']))
                let l:dict[l:el[0]] .= g:op_compilacion['nombre_ejecutable'] . ' '
            endif

            let l:dict[l:el[0]] .= g:op_compilacion['archivos'] . ' '
            let l:dict[l:el[0]] .= l:op['banderas']

            let g:comando_compilacion[l:el[0]] = l:dict[l:el[0]]
        else
            let g:comando_compilacion[l:el[0]] = 'make'
        endif
    endfor
endfunction
call ActualizarComandosCompilacion()

function! GenerarArchivoConfiguracion()
    if &filetype ==# ''
        let g:tipo_archivo = input('Ingresa el lenguaje: ')
    else
        let g:tipo_archivo = &filetype
    endif

    if filereadable(expand('~/.vimtags'))
        silent !rm ~/.vimtags
    endif

    if filereadable('./.exrc')
        tabnew .exrc
        return
    endif

    let l:lineas_archivo = [
            \ '" Opciones locales para vim:',
            \ 'scriptencoding utf-8',
            \ 'call CambiarIndentacion(4) " Espacios por tab',
            \ '',
            \ '" Configuración para el compilador:',
            \ "let g:op_compilacion.archivos = '" . expand('%') . "'",
            \ "let g:op_compilacion.nombre_ejecutable = '" . expand('%:t:r') . "'",
            \ "let g:op_compilacion['" . g:tipo_archivo . "'] = {" ]
    if has_key(g:op_compilacion, g:tipo_archivo)
        let l:ops = g:op_compilacion[g:tipo_archivo]
        let l:lineas_archivo += [
                \ "\\ 'compilador': '" . l:ops.compilador . "',",
                \ "\\ 'banderas': '" . l:ops.banderas . "',",
                \ "\\ 'salida': '" . l:ops.salida . "'" ]
    else
        let l:lineas_archivo += [
                \ "\\ 'compilador': '',",
                \ "\\ 'banderas': '',",
                \ "\\ 'salida': ''" ]
    endif

    let l:lineas_archivo += [
            \ '\}',
            \ '',
            \ 'let g:usar_make_personalizado = 0',
            \ 'call ActualizarComandosCompilacion()' ]

    tabnew .exrc
    call append(0, l:lineas_archivo)
    normal! gg=G
endfunction

function! AplicarConfiguracion()
    update
    tabprevious
    source .exrc
    let &makeprg = g:comando_compilacion['c']
    tabnext
endfunction

augroup makecomnads " Definiendo :make según el tipo de archivo
    autocmd!
    autocmd Filetype c       let &l:makeprg = g:comando_compilacion['c']
    autocmd Filetype cpp     let &l:makeprg = g:comando_compilacion['cpp']
    autocmd Filetype fortran let &l:makeprg = g:comando_compilacion['fortran']
    autocmd Filetype java    let &l:makeprg = g:comando_compilacion['java']
    autocmd Filetype python  let &l:makeprg = g:comando_compilacion['python']
    autocmd Filetype cs      let &l:makeprg = g:comando_compilacion['cs']
    autocmd Filetype sh      let &l:makeprg = g:comando_compilacion['sh']
    autocmd Filetype haskell let &l:makeprg = g:comando_compilacion['haskell']
augroup END

" F9 para compilar y ejecutar
nnoremap <F9> :call EjecutarSiNoHayErrores()<Return>

function! EjecutarSiNoHayErrores()
    if g:usar_make_personalizado || &makeprg !=# 'make'
        make
    endif

    if len(getqflist()) ==# 0
        " Si no hay errores se intenta ejecutar el programa
        if ( &filetype ==# 'c' ||
                    \ &filetype ==# 'cpp' ||
                    \ &filetype ==# 'haskell' ||
                    \ &filetype ==# 'fortran')

            execute '!./' . g:op_compilacion['nombre_ejecutable']
        elseif (&filetype ==# 'java')
            execute '!./' . g:op_compilacion['nombre_ejecutable']
        elseif (&filetype ==# 'python')
            !python3 %
        elseif (&filetype ==# 'sh')
            !bash %
        elseif (&filetype ==# 'html')
            !xdg-open %
        endif
    else
        " Si hay errores se abren en una lista interna
        copen
        setlocal nospell
    endif
endfunction
"   +++ }}}

" +++ Revisión de código +++ {{{
if s:usar_plugins >= 2 && (has('nvim') || (v:version >= 800))
    let g:ale_set_quickfix = 1
    let g:ale_cpp_clangcheck_options = "-extra-arg='" . g:op_compilacion['cpp'].banderas
    let g:ale_cpp_gcc_options = g:op_compilacion['cpp'].banderas
    let g:ale_cpp_clang_options = g:op_compilacion['cpp'].banderas
    let g:ale_cpp_clangtidy_options = g:op_compilacion['cpp'].banderas
    let g:ale_c_gcc_options = g:op_compilacion['c'].banderas
    let g:ale_c_clang_options = g:op_compilacion['c'].banderas
    let g:ale_c_clangtidy_options = g:op_compilacion['c'].banderas
    let g:ale_c_clangtidy_checks = ['*', '-readability-braces-around-statements',
                \'-google-readability-braces-around-statements', '-llvm-header-guard']
    let g:ale_haskell_ghc_options = g:op_compilacion['haskell'].banderas
    let g:ale_fortran_gcc_options = g:op_compilacion['fortran'].banderas
elseif s:usar_plugins
    let g:syntastic_cpp_compiler_options = g:op_compilacion['cpp'].banderas
    let g:syntastic_c_compiler_options = g:op_compilacion['c'].banderas
    let g:syntastic_haskell_compiler_options = g:op_compilacion['haskell'].banderas
    let g:syntastic_fotran_compiler_options = g:op_compilacion['fortran'].banderas
endif
"   +++ }}}

" +++ Detección de tipos de archivo, y configuraciones locales +++ {{{
augroup DeteccionLenguajes
    autocmd!
    autocmd BufNewFile,BufRead *.nasm setlocal filetype=nasm
    autocmd BufNewFile,BufRead *.jade setlocal filetype=pug
    autocmd BufNewFile,BufRead *.h    setlocal filetype=c
augroup END

augroup ConfiguracionesEspecificasLenguaje
    autocmd!
    " autocmd Filetype html,css,scss,sass,pug,php setlocal ts=2 sw=2 sts=2
    " Los guiones normales forman parte del identificador en css
    autocmd Filetype html,css,scss,sass,pug     setlocal iskeyword+=-
    if s:usar_plugins >= 1
        autocmd Filetype html,xml,jade,pug,htmldjango,css,scss,sass,php imap <buffer> <expr> <Tab> emmet#expandAbbrIntelligent("\<Tab>")
    endif
augroup END

" Alternar entre archivo de ayuda y de texto (toggle text and help)
nnoremap <leader>tth :call AlternarAyudaYTexto()<Return>
function! AlternarAyudaYTexto()
    let &filetype = (&filetype ==# 'help' ? 'text' : 'help')
endfunction

augroup ConfiguracionComandoK
    autocmd!
    " Por defecto se usa el comando :Man a su vez llama al man del sistema
    autocmd FileType vim,help setlocal keywordprg=:help
    " Se requiere tener instalado cppman para usar ayuda en c++
    autocmd FileType cpp nnoremap <buffer> K yiw:sp<CR>:terminal<CR>Acppman <C-\><C-n>pA<CR>
augroup end
"   +++ }}}
" ### }}}

" ##### Edición y evaluación de la configuración y comandos ##### {{{
" Modificar y evaluar el archivo de configuración principal y el de plugins
nnoremap <Leader>av :edit $MYVIMRC<Return>
nnoremap <Leader>sv :source $MYVIMRC<Return>

" Evaluar por medio de la consola externa por medio (EValuate Shell)
nnoremap <Leader>evs !!$SHELL<Return>
xnoremap <Leader>evs !$SHELL<Return>

" Configuraciones para el emulador de terminal
if has('nvim')
    " Abrir emulador de terminal (open terminal)
    nnoremap <Leader>ot :5sp<bar>te<CR>:setlocal nospell nonu<Return>A
    " Salir a modo normal en la terminal emulada
    tnoremap <Esc> <C-\><C-n>
elseif has('terminal')
    nnoremap <Leader>ot :terminal<Return>
    tnoremap <Esc> <C-\><C-n>
endif

" Evaluación de un comando de modo normal por medio de <Leader>evn
nnoremap <Leader>evn ^vg_y@"
xnoremap <Leader>evn y@"

" Evaluación de un comando de VimL (modo comando) por medio de <Leader>evv
nnoremap <silent> <Leader>evv :execute getline(".")<Return>
xnoremap <silent> <Leader>evv :<C-u>
            \       for l:linea in getline("'<", "'>")
            \ <bar>     execute l:linea
            \ <bar> endfor
            \ <Return>

" Pegar la salida de un comando de vim en un buffer nuevo
" Modo de uso: SalidaBuffer {comando-normal}
command! -nargs=* -complete=command SalidaBuffer call SalidaBuffer(<q-args>)
function! SalidaBuffer(comando)
    redir => l:salida
    silent exe a:comando
    redir END

    new
    setlocal nonumber
    call setline(1, split(l:salida, "\n"))
    setlocal nomodified
endfunction

" Listar todos los mapeos actualmente activos
function! VerComandosActivos()
    let l:opciones = "Comandos de modo &normal\n"
                 \ . "Comandos de modo &inserción\n"
                 \ . "Comandos se modo &visual\n"
                 \ . "&Todos los comandos\n"
    let l:respuesta = confirm('¿Qué tipo de comandos quiere listar',
                            \ l:opciones, 4)

    if l:respuesta == 0
        return
    elseif l:respuesta == 1
        nmap
    elseif l:respuesta == 2
        imap
    elseif l:respuesta == 3
        vmap
    else
        map
    endif
endfunction
" ### }}}

" ##### Completado, etiquetas, diccionarios y revisión ortográfica ##### {{{
if s:usar_plugins
    set complete-=i        " Dejar que los plugins se encarguen
    set complete-=t
else
    set complete+=i        " Completar palabras de archivos incluidos
endif

" Generar etiquetas de definiciones y comando "go to definition"
set tags=./tags;/,~/.vimtags
if s:usar_plugins >= 2
    if !executable('ctags')
        echoerr 'Se requiere alguna implementación de ctags para generar etiquetas'
        echoerr 'del lenguaje para usar algunos comandos (y posiblemente plugins).'
    endif
    nnoremap <Leader>ut :UpdateTags<Return>
else
    nnoremap <Leader>ut :!ctags -R .&<Return>
endif
  " <C-]> - Ir a la definición del objeto (solo si ya se generaron las etiquetas)

" Algunas abreviaciones para lenguajes como c, c++ y java
if !s:usar_plugins
    " Estas abreviaciones solo son auxiliares para quien tenga desactivados los
    " plugins. En caso de activar plugins, estos son mejores para manejar
    " plantillas de código
    iabbrev fori  for (int i = 0; i <; i++) {<return>}<esc>kf<a
    iabbrev forr for (int i =; i >= 0; --i) {<return>}<esc>kf;i
    iabbrev pf   printf("");<esc>2hi
    iabbrev cl   cout << << endl;<esc>8hi
    iabbrev pl   System.out.println();<esc>hi
endif

" Configuración de la revisión ortográfica
if s:activar_revision_ortorgrafica
    set spell             " Activa la revisión ortográfica
    " Alternar entre revisión activa e inactiva con ,tsp
    nnoremap <Leader>spt :setlocal spell!<Return>
    if s:revision_otrografica_en_espaniol
        set spelllang=es      " El idioma de revisión es español
        " Generalmente los sistemas operativos no cuentan con un diccionario
        " en español. La primera vez que se inicie vim se pedirá permiso
        " para descargar el diccionario necesario. Basta con aceptar
        " para que vim haga el trabajo automáticamente
    else
        set spelllang=en,es
        set dictionary=/usr/share/dict/words " Usa el diccionario del sistema
    endif

    " Recorrer las palabras mal escritas y corregirlas
    nnoremap <Leader>sl ]szzzv
    nnoremap <Leader>sh [szzzv

    " Modificar lista de palabras aceptadas
    " zg - Añadir palabra a la lista blanca
    " zw - Quitar palabra de la lista blanca (marcarla como incorrecta)
    " z= - Mostrar opciones de corrección para una palabra mal escrita
    " 1z= - Elegir la primera opción de la lista
endif

let s:lenguajes = ['en', 'es']

function! CambiarLenguaje()
    let l:index = index(s:lenguajes, &spelllang)
    let l:index = (l:index + 1) % len(s:lenguajes)
    let &spelllang = s:lenguajes[l:index]
endfunction

nnoremap <leader>spr :call CambiarLenguaje()<CR>
" ### }}}

" vim: fdm=marker
